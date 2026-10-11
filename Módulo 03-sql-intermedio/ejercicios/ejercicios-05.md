# 🎯 Soluciones Completas - Desafíos Módulo 03

> ⚠️ **Solo mira después de intentarlo.**

## Desafío 1: Análisis de ventas

### 1.1 Ranking de clientes

```sql
SELECT 
    c.nombre,
    COUNT(DISTINCT p.id) AS num_pedidos,
    SUM(p.cantidad * pr.precio) AS total_gastado
FROM clientes c
JOIN pedidos p   ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre
ORDER BY total_gastado DESC;
```

### 1.2 Ranking de productos por ingresos

```sql
SELECT 
    pr.nombre,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM productos pr
JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre
ORDER BY ingresos DESC;
```

### 1.3 Ventas por categoría con porcentaje

```sql
SELECT 
    pr.categoria,
    SUM(p.cantidad * pr.precio) AS ingresos,
    ROUND(100.0 * SUM(p.cantidad * pr.precio) / 
          (SELECT SUM(p2.cantidad * pr2.precio)
           FROM pedidos p2
           JOIN productos pr2 ON p2.producto_id = pr2.id), 2) AS porcentaje
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.categoria
ORDER BY ingresos DESC;
```

### 1.4 Ticket promedio por cliente

```sql
SELECT 
    c.nombre,
    COUNT(p.id) AS pedidos,
    SUM(p.cantidad * pr.precio) AS total,
    ROUND(AVG(p.cantidad * pr.precio), 2) AS ticket_promedio
FROM clientes c
JOIN pedidos p   ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre
ORDER BY ticket_promedio DESC;
```

---

## Desafío 2: Análisis de comportamiento

### 2.1 Clientes fieles

```sql
SELECT c.nombre, COUNT(*) AS pedidos
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
HAVING COUNT(*) > 1;
```

### 2.2 Clientes dormidos

```sql
SELECT c.nombre, c.fecha_registro
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.fecha_registro < '2023-06-01' AND p.id IS NULL;
```

### 2.3 Productos estrella

**Top 3 más vendidos:**
```sql
SELECT pr.nombre, SUM(p.cantidad) AS unidades
FROM productos pr
JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre
ORDER BY unidades DESC
LIMIT 3;
```

**Top 3 menos vendidos (incluyendo no vendidos):**
```sql
SELECT pr.nombre, COALESCE(SUM(p.cantidad), 0) AS unidades
FROM productos pr
LEFT JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre
ORDER BY unidades ASC
LIMIT 3;
```

### 2.4 Ciudades top por ingresos

```sql
SELECT 
    c.ciudad,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM clientes c
JOIN pedidos p   ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.ciudad
ORDER BY ingresos DESC;
```

---

## Desafío 3: Reportes avanzados

### 3.1 Evolución mensual (PostgreSQL)

```sql
SELECT 
    DATE_TRUNC('month', fecha) AS mes,
    COUNT(*) AS pedidos,
    SUM(cantidad) AS unidades
FROM pedidos
GROUP BY mes
ORDER BY mes;
```

### 3.2 Clientes por rango de gasto

```sql
SELECT 
    c.nombre,
    SUM(p.cantidad * pr.precio) AS total,
    CASE 
        WHEN SUM(p.cantidad * pr.precio) < 100 THEN 'Bajo'
        WHEN SUM(p.cantidad * pr.precio) BETWEEN 100 AND 500 THEN 'Medio'
        ELSE 'Alto'
    END AS segmento
FROM clientes c
JOIN pedidos p   ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre
ORDER BY total DESC;
```

### 3.3 Productos sin movimiento

```sql
SELECT pr.nombre, pr.stock
FROM productos pr
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.producto_id = pr.id
);
```

### 3.4 Categorías más rentables

```sql
SELECT 
    pr.categoria,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.categoria
ORDER BY ingresos DESC
LIMIT 3;
```

---

## Desafío 4: Análisis cruzado

### 4.1 Clientes que compran en varias categorías

```sql
SELECT 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT cliente_id) FROM pedidos), 2) AS porcentaje
FROM (
    SELECT p.cliente_id
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY p.cliente_id
    HAVING COUNT(DISTINCT pr.categoria) > 1
) AS multicategoria;
```

### 4.2 Producto más vendido por categoría

```sql
SELECT pr.categoria, pr.nombre, SUM(p.cantidad) AS unidades
FROM productos pr
JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.categoria, pr.id, pr.nombre
HAVING SUM(p.cantidad) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(p2.cantidad) AS total
        FROM pedidos p2
        JOIN productos pr2 ON p2.producto_id = pr2.id
        WHERE pr2.categoria = pr.categoria
        GROUP BY pr2.id
    ) AS sub
);
```

### 4.3 Clientes que compran electrónica y ropa

```sql
SELECT c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.cliente_id = c.id AND pr.categoria = 'Electrónica'
)
AND EXISTS (
    SELECT 1 FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.cliente_id = c.id AND pr.categoria = 'Ropa'
);
```

### 4.4 Día de la semana con más ventas (PostgreSQL)

```sql
SELECT 
    TO_CHAR(fecha, 'Day') AS dia,
    COUNT(*) AS pedidos
FROM pedidos
GROUP BY dia, EXTRACT(DOW FROM fecha)
ORDER BY pedidos DESC;
```