-- ============================================
-- Consultas útiles - E-commerce
-- ============================================

-- ============ VENTAS ============

-- 1. Ventas por mes
SELECT 
    TO_CHAR(fecha, 'YYYY-MM') AS mes,
    COUNT(*) AS num_pedidos,
    SUM(total) AS ingresos,
    ROUND(AVG(total), 2) AS ticket_promedio
FROM pedidos
WHERE estado NOT IN ('cancelado')
GROUP BY mes
ORDER BY mes;

-- 2. Productos más vendidos
SELECT 
    lp.producto_nombre,
    SUM(lp.cantidad) AS unidades_vendidas,
    SUM(lp.subtotal) AS ingresos
FROM lineas_pedido lp
JOIN pedidos p ON lp.pedido_id = p.id
WHERE p.estado NOT IN ('cancelado')
GROUP BY lp.producto_nombre
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 3. Top clientes por gasto
SELECT 
    u.id,
    u.nombre || ' ' || u.apellido AS cliente,
    COUNT(p.id) AS num_pedidos,
    SUM(p.total) AS total_gastado,
    ROUND(AVG(p.total), 2) AS ticket_promedio
FROM usuarios u
JOIN pedidos p ON u.id = p.usuario_id
WHERE p.estado NOT IN ('cancelado')
GROUP BY u.id, u.nombre, u.apellido
ORDER BY total_gastado DESC
LIMIT 10;

-- 4. Categorías más rentables
WITH ventas_categoria AS (
    SELECT 
        c.id,
        c.nombre AS categoria,
        SUM(lp.subtotal) AS ingresos,
        SUM(lp.cantidad) AS unidades
    FROM categorias c
    JOIN productos pr ON c.id = pr.categoria_id
    JOIN variantes v ON pr.id = v.producto_id
    JOIN lineas_pedido lp ON v.id = lp.variante_id
    JOIN pedidos p ON lp.pedido_id = p.id
    WHERE p.estado NOT IN ('cancelado')
    GROUP BY c.id, c.nombre
)
SELECT 
    categoria,
    ingresos,
    unidades,
    ROUND(100.0 * ingresos / SUM(ingresos) OVER (), 2) AS porcentaje
FROM ventas_categoria
ORDER BY ingresos DESC;

-- ============ CLIENTES ============

-- 5. Clientes con más de 3 pedidos
SELECT 
    u.email,
    u.nombre || ' ' || u.apellido AS cliente,
    COUNT(p.id) AS num_pedidos
FROM usuarios u
JOIN pedidos p ON u.id = p.usuario_id
WHERE p.estado NOT IN ('cancelado')
GROUP BY u.id, u.email, u.nombre, u.apellido
HAVING COUNT(p.id) > 3
ORDER BY num_pedidos DESC;

-- 6. Clientes que no han comprado nunca
SELECT 
    u.id,
    u.email,
    u.nombre || ' ' || u.apellido AS cliente,
    u.fecha_registro
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
WHERE p.id IS NULL
ORDER BY u.fecha_registro;

-- 7. Ranking de clientes por gasto (con window function)
WITH gastos AS (
    SELECT 
        u.id,
        u.nombre || ' ' || u.apellido AS cliente,
        SUM(p.total) AS total_gastado
    FROM usuarios u
    JOIN pedidos p ON u.id = p.usuario_id
    WHERE p.estado NOT IN ('cancelado')
    GROUP BY u.id, u.nombre, u.apellido
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY total_gastado DESC) AS pos,
    cliente,
    total_gastado,
    NTILE(4) OVER (ORDER BY total_gastado DESC) AS cuartil
FROM gastos
ORDER BY total_gastado DESC;

-- ============ STOCK ============

-- 8. Productos con bajo stock
SELECT 
    p.nombre AS producto,
    v.sku,
    v.stock,
    v.precio
FROM variantes v
JOIN productos p ON v.producto_id = p.id
WHERE v.stock < 10 AND v.activa = TRUE
ORDER BY v.stock ASC;

-- 9. Productos sin ventas en el último mes
SELECT 
    p.nombre,
    p.precio_base,
    p.fecha_alta
FROM productos p
WHERE p.activo = TRUE
  AND NOT EXISTS (
    SELECT 1
    FROM variantes v
    JOIN lineas_pedido lp ON v.id = lp.variante_id
    JOIN pedidos pe ON lp.pedido_id = pe.id
    WHERE v.producto_id = p.id
      AND pe.fecha >= CURRENT_DATE - INTERVAL '30 days'
      AND pe.estado NOT IN ('cancelado')
  );

-- ============ ANÁLISIS ============

-- 10. Ticket promedio global
SELECT 
    ROUND(AVG(total), 2) AS ticket_promedio,
    MIN(total) AS min_ticket,
    MAX(total) AS max_ticket,
    COUNT(*) AS total_pedidos
FROM pedidos
WHERE estado NOT IN ('cancelado');

-- 11. Distribución de pedidos por estado
SELECT 
    estado,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 2) AS porcentaje
FROM pedidos
GROUP BY estado
ORDER BY total DESC;

-- 12. Tasa de conversión mensual (pedidos / usuarios nuevos)
WITH usuarios_mes AS (
    SELECT 
        TO_CHAR(fecha_registro, 'YYYY-MM') AS mes,
        COUNT(*) AS nuevos_usuarios
    FROM usuarios
    GROUP BY mes
),
pedidos_mes AS (
    SELECT 
        TO_CHAR(fecha, 'YYYY-MM') AS mes,
        COUNT(*) AS pedidos
    FROM pedidos
    WHERE estado NOT IN ('cancelado')
    GROUP BY mes
)
SELECT 
    COALESCE(u.mes, p.mes) AS mes,
    COALESCE(u.nuevos_usuarios, 0) AS nuevos_usuarios,
    COALESCE(p.pedidos, 0) AS pedidos,
    ROUND(100.0 * COALESCE(p.pedidos, 0) / NULLIF(u.nuevos_usuarios, 0), 2) AS tasa_conversion
FROM usuarios_mes u
FULL OUTER JOIN pedidos_mes p ON u.mes = p.mes
ORDER BY mes;

-- 13. Productos que necesitan reabastecimiento (stock bajo y ventas altas)
WITH ventas_producto AS (
    SELECT 
        v.producto_id,
        SUM(lp.cantidad) AS unidades_vendidas
    FROM lineas_pedido lp
    JOIN variantes v ON lp.variante_id = v.id
    JOIN pedidos p ON lp.pedido_id = p.id
    WHERE p.fecha >= CURRENT_DATE - INTERVAL '90 days'
      AND p.estado NOT IN ('cancelado')
    GROUP BY v.producto_id
)
SELECT 
    p.nombre,
    SUM(v.stock) AS stock_actual,
    vp.unidades_vendidas,
    ROUND(vp.unidades_vendidas / NULLIF(SUM(v.stock), 0), 2) AS ratio_venta_stock
FROM productos p
JOIN variantes v ON p.id = v.producto_id
LEFT JOIN ventas_producto vp ON p.id = vp.producto_id
WHERE p.activo = TRUE
GROUP BY p.id, p.nombre, vp.unidades_vendidas
HAVING SUM(v.stock) < 20 OR vp.unidades_vendidas > 100
ORDER BY ratio_venta_stock DESC NULLS LAST;

-- 14. Crecimiento mes a mes
WITH ventas AS (
    SELECT 
        DATE_TRUNC('month', fecha) AS mes,
        SUM(total) AS ingresos
    FROM pedidos
    WHERE estado NOT IN ('cancelado')
    GROUP BY mes
)
SELECT 
    mes,
    ingresos,
    LAG(ingresos) OVER (ORDER BY mes) AS mes_anterior,
    ROUND(100.0 * (ingresos - LAG(ingresos) OVER (ORDER BY mes)) 
          / NULLIF(LAG(ingresos) OVER (ORDER BY mes), 0), 2) AS crecimiento_pct
FROM ventas
ORDER BY mes;

-- 15. Productos más vendidos por categoría
WITH ranking AS (
    SELECT 
        c.nombre AS categoria,
        p.nombre AS producto,
        SUM(lp.cantidad) AS unidades,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY SUM(lp.cantidad) DESC) AS rn
    FROM categorias c
    JOIN productos p ON c.id = p.categoria_id
    JOIN variantes v ON p.id = v.producto_id
    JOIN lineas_pedido lp ON v.id = lp.variante_id
    JOIN pedidos pe ON lp.pedido_id = pe.id
    WHERE pe.estado NOT IN ('cancelado')
    GROUP BY c.id, c.nombre, p.id, p.nombre
)
SELECT categoria, producto, unidades
FROM ranking
WHERE rn <= 3
ORDER BY categoria, unidades DESC;

-- 16. Cupones más usados
SELECT 
    c.codigo,
    c.tipo,
    c.valor,
    c.usos_actuales,
    c.usos_max,
    COALESCE(SUM(p.descuento), 0) AS descuento_total_aplicado
FROM cupones c
LEFT JOIN pedidos p ON c.id = p.cupon_id
GROUP BY c.id, c.codigo, c.tipo, c.valor, c.usos_actuales, c.usos_max
ORDER BY c.usos_actuales DESC;

-- 17. Valor del inventario
SELECT 
    c.nombre AS categoria,
    SUM(v.stock * v.precio) AS valor_inventario,
    SUM(v.stock) AS unidades_totales
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
JOIN variantes v ON p.id = v.producto_id
WHERE v.activa = TRUE
GROUP BY c.id, c.nombre
ORDER BY valor_inventario DESC;

-- 18. Retención de clientes (compran en varios meses)
WITH clientes_mes AS (
    SELECT DISTINCT 
        usuario_id,
        DATE_TRUNC('month', fecha) AS mes
    FROM pedidos
    WHERE estado NOT IN ('cancelado')
)
SELECT 
    mes,
    COUNT(DISTINCT usuario_id) AS clientes_activos,
    COUNT(DISTINCT CASE 
        WHEN usuario_id IN (
            SELECT usuario_id FROM clientes_mes cm2 
            WHERE cm2.mes = cm.mes - INTERVAL '1 month'
        ) THEN usuario_id 
    END) AS clientes_recurrentes
FROM clientes_mes cm
GROUP BY mes
ORDER BY mes;