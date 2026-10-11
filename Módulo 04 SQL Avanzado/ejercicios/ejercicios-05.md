# 🎯 Soluciones - Desafíos Módulo 04

> ⚠️ Solo mira después de intentarlo.

## Desafío 1: Reporte ejecutivo

```sql
WITH ingresos_mes AS (
    SELECT 
        DATE_TRUNC('month', p.fecha) AS mes,
        SUM(p.cantidad * pr.precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY mes
),
con_variacion AS (
    SELECT 
        mes,
        ingresos,
        LAG(ingresos) OVER (ORDER BY mes) AS ingresos_anteriores
    FROM ingresos_mes
)
SELECT 
    mes,
    ingresos,
    ingresos_anteriores,
    ROUND(100.0 * (ingresos - ingresos_anteriores) / NULLIF(ingresos_anteriores, 0), 2) AS variacion_pct,
    RANK() OVER (ORDER BY ingresos DESC) AS ranking
FROM con_variacion
ORDER BY mes;
```

---

## Desafío 2: Análisis de cohortes

```sql
WITH cohortes AS (
    SELECT 
        id,
        nombre,
        DATE_TRUNC('month', fecha_registro) AS cohorte
    FROM clientes
),
gastos AS (
    SELECT 
        c.id,
        c.cohorte,
        COALESCE(SUM(p.cantidad * pr.precio), 0) AS total
    FROM cohortes c
    LEFT JOIN pedidos p    ON c.id = p.cliente_id
    LEFT JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.cohorte
)
SELECT 
    cohorte,
    COUNT(*) AS clientes,
    ROUND(AVG(total), 2) AS gasto_promedio
FROM gastos
GROUP BY cohorte
ORDER BY cohorte;
```

---

## Desafío 3: Top performers

```sql
WITH 
top_clientes AS (
    SELECT 'Cliente' AS tipo, c.nombre AS nombre, SUM(p.cantidad * pr.precio) AS valor
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
    ORDER BY valor DESC
    LIMIT 3
),
top_productos AS (
    SELECT 'Producto' AS tipo, pr.nombre, SUM(p.cantidad * pr.precio) AS valor
    FROM productos pr
    JOIN pedidos p ON pr.id = p.producto_id
    GROUP BY pr.id, pr.nombre
    ORDER BY valor DESC
    LIMIT 3
),
top_categorias AS (
    SELECT 'Categoría' AS tipo, pr.categoria AS nombre, SUM(p.cantidad * pr.precio) AS valor
    FROM productos pr
    JOIN pedidos p ON pr.id = p.producto_id
    GROUP BY pr.categoria
    ORDER BY valor DESC
    LIMIT 3
),
top_ciudades AS (
    SELECT 'Ciudad' AS tipo, c.ciudad AS nombre, SUM(p.cantidad * pr.precio) AS valor
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.ciudad
    ORDER BY valor DESC
    LIMIT 3
)
SELECT * FROM top_clientes
UNION ALL SELECT * FROM top_productos
UNION ALL SELECT * FROM top_categorias
UNION ALL SELECT * FROM top_ciudades
ORDER BY tipo, valor DESC;
```

---

## Desafío 4: Análisis temporal

```sql
-- 4.1 Días entre primer y último pedido
SELECT 
    c.nombre,
    MIN(p.fecha) AS primer_pedido,
    MAX(p.fecha) AS ultimo_pedido,
    MAX(p.fecha) - MIN(p.fecha) AS dias_entre
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
HAVING COUNT(*) > 1;
```

```sql
-- 4.3 Ticket promedio por mes
WITH tickets AS (
    SELECT 
        DATE_TRUNC('month', p.fecha) AS mes,
        p.id,
        SUM(p.cantidad * pr.precio) AS ticket
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY mes, p.id
)
SELECT 
    mes,
    ROUND(AVG(ticket), 2) AS ticket_promedio,
    COUNT(*) AS pedidos
FROM tickets
GROUP BY mes
ORDER BY mes;
```

---

## Desafío 5: Dashboard de negocio

```sql
SELECT 
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(DISTINCT cliente_id) FROM pedidos) AS clientes_activos,
    (SELECT COUNT(*) FROM clientes WHERE id NOT IN (SELECT DISTINCT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL)) AS clientes_inactivos,
    (SELECT ROUND(AVG(cantidad * precio), 2) 
     FROM pedidos p JOIN productos pr ON p.producto_id = pr.id) AS ticket_promedio,
    (SELECT pr.nombre 
     FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
     GROUP BY pr.id, pr.nombre 
     ORDER BY SUM(p.cantidad) DESC LIMIT 1) AS producto_top,
    (SELECT pr.categoria 
     FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
     GROUP BY pr.categoria 
     ORDER BY SUM(p.cantidad * pr.precio) DESC LIMIT 1) AS categoria_top,
    (SELECT DATE_TRUNC('month', fecha) 
     FROM pedidos 
     GROUP BY DATE_TRUNC('month', fecha)
     ORDER BY COUNT(*) DESC LIMIT 1) AS mes_top;
```

---

## Desafío 6: Optimización

Ejemplo de análisis:

```sql
-- Antes: full scan
EXPLAIN ANALYZE 
SELECT * FROM pedidos WHERE cliente_id = 1 AND fecha > '2024-01-01';
-- Resultado: Seq Scan on pedidos (cost=0.00..1.19 rows=1 width=36)

-- Crear índice
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha);

-- Después: index scan
EXPLAIN ANALYZE 
SELECT * FROM pedidos WHERE cliente_id = 1 AND fecha > '2024-01-01';
-- Resultado: Index Scan using idx_pedidos_cliente_fecha
```

**Documenta:**
| Consulta | Antes | Después | Mejora |
|----------|-------|---------|--------|
| Pedidos por cliente + fecha | Seq Scan | Index Scan | ~10x |