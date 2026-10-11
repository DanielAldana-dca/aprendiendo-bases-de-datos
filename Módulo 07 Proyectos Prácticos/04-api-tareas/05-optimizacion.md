# ⚡ Optimización - API de Tareas

## 🎯 Objetivos

- Identificar consultas lentas
- Crear índices apropiados
- Usar paginación eficiente
- Optimizar full-text search

## 📊 Índices de la API

### Índices ya creados

```sql
-- Básicos
CREATE INDEX idx_tareas_proyecto ON tareas(proyecto_id);
CREATE INDEX idx_tareas_padre ON tareas(padre_id);
CREATE INDEX idx_tareas_asignado ON tareas(asignado_id);
CREATE INDEX idx_tareas_fecha_limite ON tareas(fecha_limite) WHERE fecha_limite IS NOT NULL;
CREATE INDEX idx_tareas_estado ON tareas(estado);
CREATE INDEX idx_tareas_usuario ON tareas(usuario_id);
```

### Índices adicionales recomendados

```sql
-- Filtro muy común: tareas de un proyecto por estado y prioridad
CREATE INDEX idx_tareas_proyecto_estado_prioridad 
ON tareas(proyecto_id, estado, prioridad);

-- Filtro: mis tareas pendientes ordenadas por fecha
CREATE INDEX idx_tareas_asignado_estado_fecha 
ON tareas(asignado_id, estado, fecha_limite) 
WHERE estado != 'completada';

-- Búsqueda por etiqueta + estado
CREATE INDEX idx_tarea_etiqueta_estado 
ON tarea_etiqueta(etiqueta_id, tarea_id);

-- Proyectos compartidos conmigo
CREATE INDEX idx_proyecto_miembro_usuario 
ON proyecto_miembro(usuario_id);
```

## 🔍 Full-text search

### Configuración

```sql
-- Índice GIN para búsqueda
CREATE INDEX idx_tareas_fts ON tareas 
USING GIN(to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, '')));

-- Verificar que se usa
EXPLAIN ANALYZE
SELECT * FROM tareas
WHERE to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, '')) 
      @@ to_tsquery('spanish', 'comprar');
```

### Mejora: columna generada

```sql
ALTER TABLE tareas ADD COLUMN busqueda tsvector 
GENERATED ALWAYS AS (
    to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, ''))
) STORED;

CREATE INDEX idx_tareas_busqueda ON tareas USING GIN(busqueda);

-- Ahora la query es más simple
SELECT * FROM tareas WHERE busqueda @@ to_tsquery('spanish', 'comprar');
```

## 📄 Paginación

### Offset (simple pero lento)

```sql
-- Página 5, 20 por página
SELECT * FROM tareas
WHERE asignado_id = 1
ORDER BY fecha_limite
LIMIT 20 OFFSET 80;
```

**Problema:** a partir de la página 100+, PostgreSQL debe leer y descartar muchas filas.

### Keyset (recomendado)

```sql
-- Primera página
SELECT id, titulo, fecha_limite
FROM tareas
WHERE asignado_id = 1
ORDER BY fecha_limite, id
LIMIT 20;

-- Página siguiente (usando el último registro)
SELECT id, titulo, fecha_limite
FROM tareas
WHERE asignado_id = 1
  AND (fecha_limite, id) > ('2024-03-15 10:00:00', 100)
ORDER BY fecha_limite, id
LIMIT 20;
```

**Ventaja:** siempre O(log n) independiente de la página.

### API con cursor

```
GET /tasks?limit=20&cursor=eyJmIjoiMjAyNC0wMy0xNSIsImlkIjoxMDB9

# El cursor es base64 de {"f": "2024-03-15", "id": 100}
```

## ⚡ Consultas optimizadas

### Evitar N+1

**❌ Malo:**
```python
tareas = db.query("SELECT * FROM tareas WHERE proyecto_id = 1")
for t in tareas:
    t.etiquetas = db.query("SELECT * FROM tarea_etiqueta WHERE tarea_id = %s", t.id)
```

**✅ Bueno:**
```sql
SELECT 
    t.id,
    t.titulo,
    t.estado,
    COALESCE(
        array_agg(e.nombre) FILTER (WHERE e.id IS NOT NULL),
        ARRAY[]::VARCHAR[]
    ) AS etiquetas
FROM tareas t
LEFT JOIN tarea_etiqueta te ON t.id = te.tarea_id
LEFT JOIN etiquetas e ON te.etiqueta_id = e.id
WHERE t.proyecto_id = 1
GROUP BY t.id, t.titulo, t.estado;
```

### Evitar SELECT *

```sql
-- ❌
SELECT * FROM tareas WHERE id = 1;

-- ✅ Solo lo que necesitas
SELECT id, titulo, estado, prioridad, fecha_limite
FROM tareas WHERE id = 1;
```

### EXISTS vs IN

**Para verificar existencia:**
```sql
-- ✅ Mejor
SELECT 1 FROM tareas WHERE id = 1 AND EXISTS (
    SELECT 1 FROM tarea_etiqueta WHERE tarea_id = 1 AND etiqueta_id = 5
);

-- ❌ Peor con subconsultas grandes
SELECT 1 FROM tareas WHERE id = 1 AND id IN (
    SELECT tarea_id FROM tarea_etiqueta WHERE etiqueta_id = 5
);
```

### CTEs para legibilidad + performance

```sql
WITH mis_proyectos AS (
    SELECT proyecto_id 
    FROM proyecto_miembro 
    WHERE usuario_id = 1
),
tareas_activas AS (
    SELECT * FROM tareas
    WHERE estado IN ('pendiente', 'en_progreso')
      AND proyecto_id IN (SELECT proyecto_id FROM mis_proyectos)
)
SELECT 
    proyecto_id,
    COUNT(*) AS pendientes,
    COUNT(*) FILTER (WHERE prioridad = 1) AS urgentes
FROM tareas_activas
GROUP BY proyecto_id;
```

## 🔥 Consultas comunes optimizadas

### 1. Dashboard del usuario

```sql
SELECT 
    (SELECT COUNT(*) FROM tareas WHERE asignado_id = 1 AND estado = 'pendiente') AS pendientes,
    (SELECT COUNT(*) FROM tareas WHERE asignado_id = 1 AND estado = 'en_progreso') AS en_progreso,
    (SELECT COUNT(*) FROM tareas WHERE asignado_id = 1 
        AND fecha_limite < CURRENT_DATE AND estado NOT IN ('completada','archivada')) AS vencidas,
    (SELECT COUNT(*) FROM tareas WHERE asignado_id = 1 
        AND fecha_limite::date = CURRENT_DATE AND estado != 'completada') AS hoy;
```

**Optimización:** 4 subconsultas con índices en `asignado_id` + filtros. Alternativa con una sola pasada:

```sql
SELECT 
    COUNT(*) FILTER (WHERE estado = 'pendiente') AS pendientes,
    COUNT(*) FILTER (WHERE estado = 'en_progreso') AS en_progreso,
    COUNT(*) FILTER (WHERE fecha_limite < CURRENT_DATE 
                     AND estado NOT IN ('completada','archivada')) AS vencidas,
    COUNT(*) FILTER (WHERE fecha_limite::date = CURRENT_DATE 
                     AND estado != 'completada') AS hoy
FROM tareas
WHERE asignado_id = 1;
```

### 2. Tareas de un proyecto con subtareas

```sql
WITH raiz AS (
    SELECT * FROM tareas
    WHERE proyecto_id = 1 AND padre_id IS NULL
    ORDER BY orden, fecha_creacion
    LIMIT 20
)
SELECT 
    r.id,
    r.titulo,
    r.estado,
    r.prioridad,
    (SELECT COUNT(*) FROM tareas WHERE padre_id = r.id) AS num_subtareas,
    (SELECT COUNT(*) FROM tareas WHERE padre_id = r.id AND estado = 'completada') AS subtareas_ok
FROM raiz r
ORDER BY r.orden;
```

### 3. Búsqueda con filtros dinámicos

```sql
-- Construir dinámicamente en la app
SELECT id, titulo, estado, prioridad
FROM tareas
WHERE proyecto_id = $1
  AND ($2::text IS NULL OR estado = $2)
  AND ($3::int IS NULL OR prioridad <= $3)
  AND ($4::text IS NULL OR busqueda @@ to_tsquery('spanish', $4))
  AND ($5::int IS NULL OR asignado_id = $5)
ORDER BY fecha_limite ASC NULLS LAST
LIMIT 20;
```

> 💡 **Truco:** usa parámetros opcionales con `IS NULL OR` para una sola query que sirve a múltiples filtros.

### 4. Árbol completo con CTE recursiva

```sql
WITH RECURSIVE arbol AS (
    SELECT id, titulo, padre_id, 1 AS nivel, ARRAY[id] AS path
    FROM tareas
    WHERE id = 1
    
    UNION ALL
    
    SELECT t.id, t.titulo, t.padre_id, a.nivel + 1, a.path || t.id
    FROM tareas t
    JOIN arbol a ON t.padre_id = a.id
)
SELECT 
    REPEAT('  ', nivel - 1) || titulo AS jerarquia,
    nivel
FROM arbol
ORDER BY path;
```

**Optimización:** el índice en `padre_id` es esencial.

## 📊 EXPLAIN ANALYZE - Ejemplos

### Consulta lenta

```sql
EXPLAIN ANALYZE
SELECT * FROM tareas
WHERE estado = 'pendiente'
  AND prioridad = 1
  AND fecha_limite < CURRENT_DATE;

-- Resultado:
-- Seq Scan on tareas  (cost=0.00..1234.56 rows=... width=...)
--   Filter: (estado = 'pendiente' AND prioridad = 1 AND fecha_limite < ...)
-- Planning Time: 0.5 ms
-- Execution Time: 450 ms  ← LENTO
```

### Añadir índice

```sql
CREATE INDEX idx_tareas_estado_prioridad_fecha
ON tareas(estado, prioridad, fecha_limite);
```

### Volver a analizar

```sql
EXPLAIN ANALYZE
SELECT * FROM tareas
WHERE estado = 'pendiente'
  AND prioridad = 1
  AND fecha_limite < CURRENT_DATE;

-- Resultado:
-- Index Scan using idx_tareas_estado_prioridad_fecha
-- Execution Time: 12 ms  ← 37x más rápido
```

## 🎯 Índices parciales (ahorran espacio)

```sql
-- Solo indexa tareas activas (las completadas no se consultan)
CREATE INDEX idx_tareas_activas ON tareas(asignado_id, fecha_limite)
WHERE estado IN ('pendiente', 'en_progreso');

-- Solo recordatorios pendientes
CREATE INDEX idx_recordatorios_pendientes ON recordatorios(fecha)
WHERE enviado = FALSE;
```

**Ventajas:**
- Ocupan menos espacio
- Más rápidos de mantener
- Ideales para "estados activos"

## 🧹 Mantenimiento

### ANALYZE periódico

```sql
-- Actualizar estadísticas
ANALYZE tareas;
ANALYZE proyecto_miembro;

-- O todas las tablas
VACUUM ANALYZE;
```

### Reindex

```sql
REINDEX INDEX idx_tareas_fts;
```

Si las búsquedas full-text se vuelven lentas.

### Monitoreo

```sql
-- Consultas lentas (requiere pg_stat_statements)
SELECT 
    query,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_ms
FROM pg_stat_statements
WHERE query LIKE '%tareas%'
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## 📈 Benchmarks esperados

| Consulta | Sin índice | Con índice | Mejora |
|----------|------------|------------|--------|
| Mis tareas pendientes | 450 ms | 8 ms | 56x |
| Búsqueda full-text | 800 ms | 15 ms | 53x |
| Dashboard usuario | 1.2 s | 25 ms | 48x |
| Árbol de subtareas | 300 ms | 5 ms | 60x |

## ✅ Checklist de optimización

- [ ] Todas las FK tienen índice
- [ ] Índices compuestos para filtros comunes
- [ ] Full-text con columna generada + GIN
- [ ] Índices parciales para estados activos
- [ ] Paginación con keyset (no offset en páginas grandes)
- [ ] Sin N+1 queries
- [ ] Sin `SELECT *` en producción
- [ ] ANALYZE periódico
- [ ] Monitoreo con `pg_stat_statements`
- [ ] EXPLAIN ANALYZE antes/después de cada cambio

## ⚠️ Errores comunes

- Índice en cada columna (ralentiza escrituras)
- No usar índices parciales donde aplican
- OFFSET grande sin keyset
- Full-text sin GIN (lento)
- No medir antes de optimizar
- Ignorar el plan de ejecución