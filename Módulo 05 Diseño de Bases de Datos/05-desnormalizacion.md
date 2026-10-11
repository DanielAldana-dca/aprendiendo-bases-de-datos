# 05 - Desnormalización

## 🎯 Objetivos

- Entender por qué a veces **conviene** desnormalizar
- Conocer patrones de desnormalización
- Saber cuándo NO hacerlo

## 📚 ¿Qué es la desnormalización?

Agregar **redundancia controlada** para mejorar el rendimiento de lectura, a cambio de:
- Más espacio
- Actualizaciones más complejas
- Riesgo de inconsistencia (que hay que gestionar)

## 🤔 ¿Por qué desnormalizar?

La normalización optimiza **escritura** (no duplicar).  
La desnormalización optimiza **lectura** (evitar JOINs pesados).

**Ejemplo:** un dashboard que suma ventas por categoría cada 5 segundos.
- Normalizado: JOIN + GROUP BY cada vez
- Desnormalizado: tabla `resumen_ventas_categoria` actualizada por trigger

## 📊 Cuándo desnormalizar

✅ **Sí:**
- Consultas lentas con muchos JOINs
- Reportes analíticos frecuentes
- Datos históricos que no cambian (facturas)
- Aplicaciones read-heavy

❌ **No:**
- Datos transaccionales que cambian mucho
- Sin haber medido antes (¡no optimices a ciegas!)
- Por moda o "por si acaso"
- Sin tener un plan para mantener consistencia

## 🎯 Patrones de desnormalización

### 1. Columna precalculada

**Antes (normalizado):**
```sql
-- Cada vez que se consulta:
SELECT p.id, SUM(lp.cantidad * lp.precio) AS total
FROM pedidos p
JOIN lineas_pedido lp ON p.id = lp.pedido_id
GROUP BY p.id;
```

**Después:**
```sql
ALTER TABLE pedidos ADD COLUMN total DECIMAL(10,2);

-- Al insertar líneas:
UPDATE pedidos SET total = (
    SELECT SUM(cantidad * precio)
    FROM lineas_pedido WHERE pedido_id = pedidos.id
) WHERE id = NEW.pedido_id;
```

**Ventaja:** `SELECT total FROM pedidos` es instantáneo.  
**Riesgo:** si olvidas actualizar, queda desincronizado.

### 2. Contadores

En lugar de `COUNT(*)` cada vez:

```sql
ALTER TABLE productos ADD COLUMN veces_vendido INTEGER DEFAULT 0;
```

Actualizar con trigger en cada venta.

### 3. Tablas de resumen

Tabla que guarda agregados por período.

```sql
CREATE TABLE resumen_ventas_mes (
    anio INTEGER,
    mes INTEGER,
    categoria VARCHAR(50),
    total_ingresos DECIMAL(12,2),
    unidades_vendidas INTEGER,
    PRIMARY KEY (anio, mes, categoria)
);

-- Actualizar por job nocturno
REFRESH MATERIALIZED VIEW resumen_ventas_mes;
```

### 4. Duplicar columnas para evitar JOIN

**Antes:**
```sql
SELECT p.id, p.fecha, c.nombre AS cliente
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id;
```

**Después:**
```sql
ALTER TABLE pedidos ADD COLUMN cliente_nombre VARCHAR(100);

SELECT id, fecha, cliente_nombre FROM pedidos;  -- sin JOIN
```

**Cuándo:** si el nombre casi nunca cambia y el JOIN es cuello de botella.

**Riesgo:** si el cliente cambia de nombre → hay que actualizar pedidos.

### 5. Vistas materializadas

Alternativa "limpia" a duplicar: el motor mantiene la copia.

```sql
CREATE MATERIALIZED VIEW resumen_clientes AS
SELECT 
    c.id,
    c.nombre,
    COUNT(p.id) AS num_pedidos,
    SUM(p.cantidad * pr.precio) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
LEFT JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre;

REFRESH MATERIALIZED VIEW resumen_clientes;
```

**Ventaja:** declarativo, menos errores.  
**Desventaja:** datos "congelados" hasta refrescar.

## ⚖️ Normalización vs Desnormalización

| Aspecto | Normalizado | Desnormalizado |
|---------|-------------|----------------|
| Escritura | Rápida | Más lenta |
| Lectura | JOINs | Directa |
| Espacio | Mínimo | Redundante |
| Consistencia | Automática | Manual |
| Complejidad | Alta (muchas tablas) | Baja (pocas tablas) |
| Uso típico | OLTP | OLAP, reportes |

## 🎯 Estrategia recomendada

```
1. Empieza normalizado (3FN)
2. Mide rendimiento real (EXPLAIN, benchmarks)
3. Si hay cuello de botella:
   a. Prueba índices
   b. Prueba reescribir consulta
   c. Prueba vista materializada
   d. Solo entonces: desnormalizar
4. Documenta la redundancia y cómo se mantiene
```

## 💡 Ejemplo real: e-commerce

**Normalizado:**
```
pedidos(id, cliente_id, fecha)
lineas_pedido(pedido_id, producto_id, cantidad, precio)
productos(id, nombre, precio)
```

`total` se calcula al vuelo.

**Desnormalizado para dashboard:**
```
pedidos(id, cliente_id, fecha, total, num_lineas)
lineas_pedido(pedido_id, producto_id, cantidad, precio, producto_nombre)
```

**Razones:**
- El dashboard muestra `total` en cada fila → sin JOIN
- `producto_nombre` se guarda con el precio histórico (por si cambia el nombre del producto)

## ⚠️ Errores comunes

- Desnormalizar sin medir
- Olvidar actualizar la columna duplicada
- Duplicar datos que cambian mucho
- No documentar la redundancia
- Confundir desnormalización con mal diseño

## ✅ Ejercicios

1. Diseña una tabla `pedidos` con columna `total` desnormalizada. ¿Cómo la mantendrías actualizada?
2. ¿Cuándo usarías una vista materializada en vez de duplicar columnas?
3. Crea un contador `veces_comprado` en `productos` con un trigger.
4. ¿Qué riesgos tiene duplicar `cliente_nombre` en `pedidos`?
5. Analiza el dataset de la tienda: ¿qué desnormalizarías para un dashboard rápido?
6. Escribe el plan: medir → optimizar → desnormalizar para un caso real.

## 🔗 Recursos

- [Denormalization - Martin Fowler](https://martinfowler.com/bliki/Denormalization.html)