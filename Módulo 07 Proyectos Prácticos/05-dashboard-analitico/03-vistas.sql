-- ============================================
-- Vistas Materializadas para Dashboard
-- PostgreSQL
-- ============================================

-- ============ VISTA: RESUMEN VENTAS POR MES ============

CREATE MATERIALIZED VIEW mv_ventas_mensual AS
SELECT 
    DATE_TRUNC('month', p.fecha) AS mes,
    COUNT(DISTINCT p.id) AS num_pedidos,
    COUNT(DISTINCT p.cliente_id) AS clientes_unicos,
    SUM(p.cantidad) AS unidades_vendidas,
    SUM(p.cantidad * pr.precio) AS ingresos,
    ROUND(AVG(p.cantidad * pr.precio), 2) AS ticket_promedio
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY mes
ORDER BY mes;

CREATE UNIQUE INDEX ON mv_ventas_mensual(mes);

-- ============ VISTA: TOP PRODUCTOS ============

CREATE MATERIALIZED VIEW mv_top_productos AS
SELECT 
    pr.id,
    pr.nombre,
    pr.categoria,
    SUM(p.cantidad) AS unidades_vendidas,
    SUM(p.cantidad * pr.precio) AS ingresos,
    COUNT(DISTINCT p.cliente_id) AS clientes_unicos
FROM productos pr
JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre, pr.categoria
ORDER BY ingresos DESC;

-- ============ VISTA: RESUMEN CLIENTES ============

CREATE MATERIALIZED VIEW mv_resumen_clientes AS
SELECT 
    c.id,
    c.nombre,
    c.ciudad,
    COUNT(DISTINCT p.id) AS num_pedidos,
    SUM(p.cantidad * pr.precio) AS total_gastado,
    ROUND(AVG(p.cantidad * pr.precio), 2) AS ticket_promedio,
    MAX(p.fecha) AS ultimo_pedido,
    CURRENT_DATE - MAX(p.fecha) AS dias_sin_comprar
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
LEFT JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre, c.ciudad;

CREATE UNIQUE INDEX ON mv_resumen_clientes(id);

-- ============ VISTA: CATEGORÍAS ============

CREATE MATERIALIZED VIEW mv_ventas_categoria AS
SELECT 
    pr.categoria,
    COUNT(DISTINCT p.id) AS num_pedidos,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos,
    COUNT(DISTINCT p.cliente_id) AS clientes_unicos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.categoria
ORDER BY ingresos DESC;

-- ============ VISTA: KPIs DIARIOS ============

CREATE MATERIALIZED VIEW mv_kpis_diarios AS
SELECT 
    p.fecha::date AS dia,
    COUNT(DISTINCT p.id) AS pedidos,
    COUNT(DISTINCT p.cliente_id) AS clientes,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY dia
ORDER BY dia;

CREATE UNIQUE INDEX ON mv_kpis_diarios(dia);

-- ============ REFRESCAR ============

-- Manual
REFRESH MATERIALIZED VIEW mv_ventas_mensual;
REFRESH MATERIALIZED VIEW mv_top_productos;
REFRESH MATERIALIZED VIEW mv_resumen_clientes;
REFRESH MATERIALIZED VIEW mv_ventas_categoria;
REFRESH MATERIALIZED VIEW mv_kpis_diarios;

-- Concurrente (sin bloquear lecturas, requiere índice único)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ventas_mensual;

-- ============ AUTOMATIZAR REFRESCO ============

-- Con pg_cron (extensión de PostgreSQL)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Refrescar cada hora
SELECT cron.schedule(
    'refresh-dashboard-views',
    '0 * * * *',
    $$
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ventas_mensual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_resumen_clientes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpis_diarios;
    $$
);