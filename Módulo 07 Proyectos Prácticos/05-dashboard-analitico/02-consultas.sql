-- ============================================
-- Dashboard Analítico - Consultas KPI
-- ============================================

-- ============ VENTAS ============

-- 1. Ingresos por período (hoy, semana, mes, año)
SELECT 
    SUM(CASE WHEN fecha::date = CURRENT_DATE THEN cantidad * precio ELSE 0 END) AS hoy,
    SUM(CASE WHEN fecha >= CURRENT_DATE - INTERVAL '7 days' THEN cantidad * precio ELSE 0 END) AS semana,
    SUM(CASE WHEN fecha >= DATE_TRUNC('month', CURRENT_DATE) THEN cantidad * precio ELSE 0 END) AS mes,
    SUM(CASE WHEN fecha >= DATE_TRUNC('year', CURRENT_DATE) THEN cantidad * precio ELSE 0 END) AS anio
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
WHERE p.fecha >= DATE_TRUNC('year', CURRENT_DATE);

-- 2. Crecimiento mes a mes (MoM)
WITH mensual AS (
    SELECT 
        DATE_TRUNC('month', fecha) AS mes,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY mes
)
SELECT 
    mes,
    ingresos,
    LAG(ingresos) OVER (ORDER BY mes) AS mes_anterior,
    ROUND(100.0 * (ingresos - LAG(ingresos) OVER (ORDER BY mes)) 
          / NULLIF(LAG(ingresos) OVER (ORDER BY mes), 0), 2) AS crecimiento_mom
FROM mensual
ORDER BY mes DESC;

-- 3. Crecimiento año a año (YoY)
WITH anual AS (
    SELECT 
        EXTRACT(YEAR FROM fecha) AS anio,
        EXTRACT(MONTH FROM fecha) AS mes,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY anio, mes
)
SELECT 
    anio,
    mes,
    ingresos,
    LAG(ingresos, 12) OVER (ORDER BY anio, mes) AS mismo_mes_anio_anterior,
    ROUND(100.0 * (ingresos - LAG(ingresos, 12) OVER (ORDER BY anio, mes))
          / NULLIF(LAG(ingresos, 12) OVER (ORDER BY anio, mes), 0), 2) AS crecimiento_yoy
FROM anual
ORDER BY anio DESC, mes DESC;

-- 4. Ticket promedio por mes
SELECT 
    DATE_TRUNC('month', fecha) AS mes,
    COUNT(DISTINCT p.id) AS num_pedidos,
    ROUND(AVG(subtotal_pedido), 2) AS ticket_promedio
FROM pedidos p
JOIN (
    SELECT id AS pedido_id, SUM(cantidad * precio) AS subtotal_pedido
    FROM pedidos p2
    JOIN productos pr ON p2.producto_id = pr.id
    GROUP BY p2.id
) sub ON p.id = sub.pedido_id
GROUP BY mes
ORDER BY mes DESC;

-- ============ PRODUCTOS ============

-- 5. Top 10 productos más vendidos
SELECT 
    pr.nombre,
    pr.categoria,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.id, pr.nombre, pr.categoria
ORDER BY ingresos DESC
LIMIT 10;

-- 6. Productos con stock bajo (necesitan reabastecimiento)
SELECT 
    nombre,
    categoria,
    stock,
    precio
FROM productos
WHERE stock < 10
ORDER BY stock ASC;

-- 7. Productos sin movimiento (últimos 30 días)
SELECT 
    pr.id,
    pr.nombre,
    pr.categoria,
    pr.stock
FROM productos pr
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.producto_id = pr.id
      AND p.fecha >= CURRENT_DATE - INTERVAL '30 days'
)
ORDER BY pr.stock DESC;

-- ============ CATEGORÍAS ============

-- 8. Categorías más rentables con % del total
WITH ventas_categoria AS (
    SELECT 
        pr.categoria,
        SUM(p.cantidad * pr.precio) AS ingresos,
        SUM(p.cantidad) AS unidades
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY pr.categoria
)
SELECT 
    categoria,
    ingresos,
    unidades,
    ROUND(100.0 * ingresos / SUM(ingresos) OVER (), 2) AS porcentaje
FROM ventas_categoria
ORDER BY ingresos DESC;

-- ============ CLIENTES ============

-- 9. Clientes nuevos vs recurrentes por mes
WITH primeros_pedidos AS (
    SELECT 
        cliente_id,
        MIN(fecha) AS primer_pedido
    FROM pedidos
    GROUP BY cliente_id
)
SELECT 
    DATE_TRUNC('month', p.fecha) AS mes,
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', pp.primer_pedido) = DATE_TRUNC('month', p.fecha) 
        THEN p.cliente_id 
    END) AS nuevos,
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', pp.primer_pedido) < DATE_TRUNC('month', p.fecha) 
        THEN p.cliente_id 
    END) AS recurrentes
FROM pedidos p
JOIN primeros_pedidos pp ON p.cliente_id = pp.cliente_id
GROUP BY mes
ORDER BY mes DESC;

-- 10. Top 10 clientes por gasto (con ranking y cuartil)
WITH gastos AS (
    SELECT 
        c.id,
        c.nombre,
        c.ciudad,
        COUNT(p.id) AS num_pedidos,
        SUM(p.cantidad * pr.precio) AS total_gastado,
        ROUND(AVG(p.cantidad * pr.precio), 2) AS ticket_promedio
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre, c.ciudad
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY total_gastado DESC) AS ranking,
    nombre,
    ciudad,
    num_pedidos,
    total_gastado,
    ticket_promedio,
    NTILE(4) OVER (ORDER BY total_gastado DESC) AS cuartil
FROM gastos
ORDER BY total_gastado DESC
LIMIT 10;

-- 11. Retención por cohorte
WITH cohortes AS (
    SELECT 
        cliente_id,
        DATE_TRUNC('month', MIN(fecha)) AS cohorte
    FROM pedidos
    GROUP BY cliente_id
),
actividad_mensual AS (
    SELECT DISTINCT
        p.cliente_id,
        c.cohorte,
        DATE_TRUNC('month', p.fecha) AS mes,
        EXTRACT(EPOCH FROM (DATE_TRUNC('month', p.fecha) - c.cohorte)) / 2629800 AS meses_despues
    FROM pedidos p
    JOIN cohortes c ON p.cliente_id = c.cliente_id
)
SELECT 
    cohorte,
    meses_despues::int AS mes_n,
    COUNT(DISTINCT cliente_id) AS clientes_activos
FROM actividad_mensual
GROUP BY cohorte, meses_despues
ORDER BY cohorte, mes_n;

-- 12. Ciudades más rentables
WITH ventas_ciudad AS (
    SELECT 
        c.ciudad,
        COUNT(DISTINCT c.id) AS clientes,
        SUM(p.cantidad * pr.precio) AS ingresos
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.ciudad
)
SELECT 
    ciudad,
    clientes,
    ingresos,
    ROUND(ingresos / NULLIF(clientes, 0), 2) AS ingreso_por_cliente,
    RANK() OVER (ORDER BY ingresos DESC) AS ranking
FROM ventas_ciudad
ORDER BY ingresos DESC;

-- ============ ANÁLISIS TEMPORAL ============

-- 13. Ventas por día de la semana
SELECT 
    TO_CHAR(fecha, 'Day') AS dia_semana,
    EXTRACT(DOW FROM fecha) AS dia_num,
    COUNT(*) AS num_pedidos,
    SUM(cantidad * precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY dia_semana, dia_num
ORDER BY dia_num;

-- 14. Ventas por hora del día
SELECT 
    EXTRACT(HOUR FROM fecha) AS hora,
    COUNT(*) AS num_pedidos,
    SUM(cantidad * precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY hora
ORDER BY hora;

-- 15. Media móvil de ventas (7 días)
WITH ventas_diarias AS (
    SELECT 
        fecha::date AS dia,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY dia
)
SELECT 
    dia,
    ingresos,
    ROUND(AVG(ingresos) OVER (
        ORDER BY dia 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS media_movil_7d
FROM ventas_diarias
ORDER BY dia DESC;

-- 16. Total acumulado del año
WITH ventas_diarias AS (
    SELECT 
        fecha::date AS dia,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY dia
)
SELECT 
    dia,
    ingresos,
    SUM(ingresos) OVER (ORDER BY dia) AS acumulado_anio
FROM ventas_diarias
ORDER BY dia DESC;

-- ============ ANÁLISIS AVANZADO ============

-- 17. Segmentación RFM (Recency, Frequency, Monetary)
WITH rfm AS (
    SELECT 
        c.id,
        c.nombre,
        CURRENT_DATE - MAX(p.fecha) AS recencia_dias,
        COUNT(p.id) AS frecuencia,
        SUM(p.cantidad * pr.precio) AS monetario
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
)
SELECT 
    nombre,
    recencia_dias,
    frecuencia,
    monetario,
    CASE
        WHEN recencia_dias <= 30 AND frecuencia >= 2 AND monetario > 500 THEN 'VIP'
        WHEN recencia_dias <= 60 AND frecuencia >= 1 THEN 'Activo'
        WHEN recencia_dias > 90 THEN 'En riesgo'
        ELSE 'Regular'
    END AS segmento
FROM rfm
ORDER BY monetario DESC;

-- 18. Análisis de cesta (productos que se compran juntos)
SELECT 
    p1.producto_id AS producto_a,
    p2.producto_id AS producto_b,
    COUNT(*) AS veces_juntos
FROM pedidos p1
JOIN pedidos p2 
    ON p1.cliente_id = p2.cliente_id 
    AND p1.fecha = p2.fecha
    AND p1.producto_id < p2.producto_id
GROUP BY producto_a, producto_b
HAVING COUNT(*) >= 2
ORDER BY veces_juntos DESC
LIMIT 10;

-- 19. Comparativa mes actual vs anterior por categoría
WITH comparativa AS (
    SELECT 
        pr.categoria,
        SUM(CASE WHEN DATE_TRUNC('month', p.fecha) = DATE_TRUNC('month', CURRENT_DATE)
                 THEN p.cantidad * pr.precio ELSE 0 END) AS mes_actual,
        SUM(CASE WHEN DATE_TRUNC('month', p.fecha) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
                 THEN p.cantidad * pr.precio ELSE 0 END) AS mes_anterior
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.fecha >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY pr.categoria
)
SELECT 
    categoria,
    mes_actual,
    mes_anterior,
    mes_actual - mes_anterior AS diferencia,
    ROUND(100.0 * (mes_actual - mes_anterior) / NULLIF(mes_anterior, 0), 2) AS variacion_pct
FROM comparativa
ORDER BY variacion_pct DESC NULLS LAST;

-- 20. Predicción simple (media móvil como proxy)
WITH ventas_diarias AS (
    SELECT 
        fecha::date AS dia,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE fecha >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY dia
)
SELECT 
    ROUND(AVG(ingresos), 2) AS ingreso_promedio_diario,
    ROUND(AVG(ingresos) * 30, 2) AS proyeccion_mensual,
    ROUND(AVG(ingresos) * 365, 2) AS proyeccion_anual
FROM ventas_diarias;