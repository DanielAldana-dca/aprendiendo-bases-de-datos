# ⚡ Optimización del Dashboard

## 🎯 Estrategias

### 1. Vistas materializadas

**Problema:** el dashboard consulta los mismos agregados cada 5 segundos.

**Solución:** precalcular y refrescar periódicamente.

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ventas_mensual;
```

- `CONCURRENTLY`: no bloquea lecturas
- Requiere índice único
- Más lento de refrescar

**Frecuencia recomendada:**
| Vista | Frecuencia |
|-------|------------|
| KPIs diarios | Cada 15 min |
| Ventas mensuales | Cada hora |
| Top productos | Cada hora |
| Resumen clientes | Cada 6 horas |

### 2. Índices específicos

```sql
-- Índice para filtrar por fecha + cliente
CREATE INDEX idx_pedidos_fecha_cliente ON pedidos(fecha, cliente_id);

-- Índice parcial para pedidos del año actual
CREATE INDEX idx_pedidos_anio_actual ON pedidos(fecha) 
WHERE fecha >= '2024-01-01';

-- Índice para búsquedas por producto + fecha
CREATE INDEX idx_pedidos_producto_fecha ON pedidos(producto_id, fecha);
```

### 3. Particionado por fecha

Cuando `pedidos` tiene millones de filas:

```sql
CREATE TABLE pedidos (
    id SERIAL,
    cliente_id INTEGER,
    fecha DATE NOT NULL,
    ...
) PARTITION BY RANGE (fecha);

CREATE TABLE pedidos_2024_01 PARTITION OF pedidos
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE pedidos_2024_02 PARTITION OF pedidos
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

**Ventajas:**
- Consultas por rango solo escanean la partición relevante
- Se pueden archivar/borrar particiones viejas
- Índices más pequeños

### 4. Caché en Redis

Para KPIs que no cambian cada segundo:

```
kpi:ventas:hoy      →  15234.50
kpi:pedidos:hoy     →  42
kpi:top:productos   →  [...]
```

TTL: 5 minutos.

### 5. Consultas optimizadas

**Evitar:**
```sql
-- ❌ Subconsulta correlacionada en cada fila
SELECT 
    c.nombre,
    (SELECT SUM(cantidad * precio) FROM pedidos WHERE cliente_id = c.id) AS total
FROM clientes c;
```

**Preferir:**
```sql
-- ✅ JOIN + GROUP BY
SELECT 
    c.nombre,
    COALESCE(SUM(p.cantidad * pr.precio), 0) AS total
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
LEFT JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre;
```

### 6. LIMIT en pruebas

Mientras desarrollas consultas:
```sql
SELECT ... FROM pedidos ... LIMIT 100;
```

Luego quítalo y mide con datos reales.

### 7. EXPLAIN ANALYZE

Siempre antes de optimizar:

```sql
EXPLAIN (ANALYZE, BUFFERS) 
SELECT ...;
```

**Busca:**
- `Seq Scan` en tablas grandes → falta índice
- `Nested Loop` con muchas filas → quizás un hash join
- `Sort` costoso → índice en el ORDER BY

### 8. Estadísticas actualizadas

```sql
ANALYZE pedidos;
ANALYZE productos;
```

O configurar autovacuum.

## 📊 Benchmarks comparativos

| Consulta | Sin optimizar | Con índices | Con MV |
|----------|---------------|-------------|--------|
| Top 10 productos | 850ms | 120ms | 5ms |
| Ingresos por mes | 1200ms | 400ms | 10ms |
| Resumen cliente | 2500ms | 800ms | 15ms |

## 🎯 Estrategia general

```
1. Medir con EXPLAIN ANALYZE
2. Crear índices apropiados
3. Si sigue lento → vistas materializadas
4. Si aún lento → particionar
5. Cachear en Redis si aplica
6. Re-medir y documentar
```

## ⚠️ Errores comunes

- Índices en todo (ralentiza escrituras)
- Refrescar MVs en horario pico
- No usar `CONCURRENTLY` (bloquea lecturas)
- Consultas sin LIMIT en exploración
- Ignorar el plan de ejecución
- No particionar tablas históricas

## ✅ Checklist

- [ ] Todas las FK tienen índice
- [ ] EXPLAIN ANALYZE de las 10 consultas más lentas
- [ ] Vistas materializadas para KPIs
- [ ] Refresco programado (pg_cron o cron)
- [ ] Redis cache para KPIs en tiempo real
- [ ] Particionado si > 10M filas
- [ ] Autovacuum configurado
- [ ] Documentar cambios y mejoras