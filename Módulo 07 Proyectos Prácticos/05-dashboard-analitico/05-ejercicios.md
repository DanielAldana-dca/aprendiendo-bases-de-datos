# 🧪 Ejercicios - Dashboard Analítico

## Nivel 🟢 Fácil

### 1. Total de ventas
Ingresos totales históricos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    SUM(cantidad * precio) AS ingresos_totales,
    COUNT(*) AS num_pedidos,
    ROUND(AVG(cantidad * precio), 2) AS ticket_promedio
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id;
```
</details>

### 2. Ventas por categoría
Ingresos agrupados por categoría.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    pr.categoria,
    COUNT(*) AS num_pedidos,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.categoria
ORDER BY ingresos DESC;
```
</details>

### 3. Top 5 productos
Los 5 más vendidos por unidades.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    pr.nombre,
    SUM(p.cantidad) AS unidades,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.id, pr.nombre
ORDER BY unidades DESC
LIMIT 5;
```
</details>

---

## Nivel 🟡 Intermedio

### 4. Ventas por mes
Ingresos mensuales con conteo de pedidos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    TO_CHAR(fecha, 'YYYY-MM') AS mes,
    COUNT(DISTINCT p.id) AS pedidos,
    SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY mes
ORDER BY mes;
```
</details>

### 5. Crecimiento MoM
Variación mes a mes.

<details>
<summary>💡 Solución</summary>

```sql
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
          / NULLIF(LAG(ingresos) OVER (ORDER BY mes), 0), 2) AS mom_pct
FROM mensual
ORDER BY mes;
```
</details>

### 6. Top 3 por categoría
Los 3 productos más vendidos de cada categoría.

<details>
<summary>💡 Solución</summary>

```sql
WITH ranking AS (
    SELECT 
        pr.categoria,
        pr.nombre,
        SUM(p.cantidad) AS unidades,
        ROW_NUMBER() OVER (PARTITION BY pr.categoria ORDER BY SUM(p.cantidad) DESC) AS rn
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY pr.categoria, pr.id, pr.nombre
)
SELECT categoria, nombre, unidades
FROM ranking
WHERE rn <= 3
ORDER BY categoria, unidades DESC;
```
</details>

### 7. Ventas por día de la semana
¿Qué día se vende más?

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    TO_CHAR(fecha, 'Day') AS dia,
    EXTRACT(DOW FROM fecha) AS num_dia,
    COUNT(*) AS pedidos,
    SUM(cantidad * precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
GROUP BY dia, num_dia
ORDER BY num_dia;
```
</details>

---

## Nivel 🔴 Difícil

### 8. Clientes RFM
Segmentación Recency, Frequency, Monetary.

<details>
<summary>💡 Solución</summary>

```sql
WITH rfm AS (
    SELECT 
        c.id,
        c.nombre,
        CURRENT_DATE - MAX(p.fecha) AS recencia,
        COUNT(DISTINCT p.id) AS frecuencia,
        SUM(p.cantidad * pr.precio) AS monetario
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
)
SELECT 
    nombre,
    recencia,
    frecuencia,
    monetario,
    CASE
        WHEN recencia <= 30 AND frecuencia >= 2 AND monetario > 500 THEN 'VIP'
        WHEN recencia <= 60 AND frecuencia >= 1 THEN 'Activo'
        WHEN recencia > 90 THEN 'En riesgo'
        ELSE 'Regular'
    END AS segmento
FROM rfm
ORDER BY monetario DESC;
```
</details>

### 9. Media móvil de 7 días
Suavizar la serie temporal.

<details>
<summary>💡 Solución</summary>

```sql
WITH diario AS (
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
FROM diario
ORDER BY dia DESC;
```
</details>

### 10. Análisis de cohortes
Retención mensual por cohorte.

<details>
<summary>💡 Solución</summary>

```sql
WITH cohortes AS (
    SELECT 
        cliente_id,
        DATE_TRUNC('month', MIN(fecha)) AS cohorte
    FROM pedidos
    GROUP BY cliente_id
),
actividad AS (
    SELECT DISTINCT 
        p.cliente_id,
        c.cohorte,
        DATE_TRUNC('month', p.fecha) AS mes,
        EXTRACT(EPOCH FROM (DATE_TRUNC('month', p.fecha) - c.cohorte)) / 2629800 AS mes_n
    FROM pedidos p
    JOIN cohortes c ON p.cliente_id = c.cliente_id
)
SELECT 
    cohorte,
    mes_n::int AS mes_n,
    COUNT(DISTINCT cliente_id) AS clientes_activos
FROM actividad
GROUP BY cohorte, mes_n
ORDER BY cohorte, mes_n;
```
</details>

### 11. Total acumulado del año
Running total de ingresos.

<details>
<summary>💡 Solución</summary>

```sql
WITH diario AS (
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
    SUM(ingresos) OVER (ORDER BY dia) AS acumulado
FROM diario
ORDER BY dia DESC;
```
</details>

### 12. Productos que se compran juntos
Análisis de cesta.

<details>
<summary>💡 Solución</summary>

```sql
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
```
</details>

### 13. Comparativa mes actual vs anterior
Por categoría.

<details>
<summary>💡 Solución</summary>

```sql
WITH comp AS (
    SELECT 
        pr.categoria,
        SUM(CASE 
            WHEN DATE_TRUNC('month', p.fecha) = DATE_TRUNC('month', CURRENT_DATE)
            THEN p.cantidad * pr.precio ELSE 0 END) AS actual,
        SUM(CASE 
            WHEN DATE_TRUNC('month', p.fecha) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
            THEN p.cantidad * pr.precio ELSE 0 END) AS anterior
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.fecha >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY pr.categoria
)
SELECT 
    categoria,
    actual,
    anterior,
    actual - anterior AS diferencia,
    ROUND(100.0 * (actual - anterior) / NULLIF(anterior, 0), 2) AS variacion_pct
FROM comp
ORDER BY variacion_pct DESC NULLS LAST;
```
</details>

---

## 🎯 Desafíos integradores

### Desafío 1: Dashboard completo en una query

Devuelve en una sola fila: ingresos mes, pedidos, ticket promedio, cliente top, producto top, categoría top.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    (SELECT SUM(cantidad * precio) 
     FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
     WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE)) AS ingresos_mes,
    (SELECT COUNT(DISTINCT id) FROM pedidos
     WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE)) AS pedidos_mes,
    (SELECT ROUND(AVG(subtotal), 2) FROM (
        SELECT SUM(cantidad * precio) AS subtotal
        FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
        GROUP BY p.id
     ) t) AS ticket_promedio,
    (SELECT c.nombre
     FROM clientes c
     JOIN pedidos p ON c.id = p.cliente_id
     JOIN productos pr ON p.producto_id = pr.id
     GROUP BY c.id, c.nombre
     ORDER BY SUM(p.cantidad * pr.precio) DESC LIMIT 1) AS cliente_top,
    (SELECT pr.nombre
     FROM productos pr
     JOIN pedidos p ON pr.id = p.producto_id
     GROUP BY pr.id, pr.nombre
     ORDER BY SUM(p.cantidad) DESC LIMIT 1) AS producto_top,
    (SELECT pr.categoria
     FROM productos pr
     JOIN pedidos p ON pr.id = p.producto_id
     GROUP BY pr.categoria
     ORDER BY SUM(p.cantidad * pr.precio) DESC LIMIT 1) AS categoria_top;
```
</details>

### Desafío 2: Detección de anomalías

Encuentra los días donde las ventas se desvían más de 2 desviaciones estándar del promedio.

<details>
<summary>💡 Solución</summary>

```sql
WITH diario AS (
    SELECT 
        fecha::date AS dia,
        SUM(cantidad * precio) AS ingresos
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY dia
),
stats AS (
    SELECT 
        AVG(ingresos) AS promedio,
        STDDEV(ingresos) AS desviacion
    FROM diario
)
SELECT 
    d.dia,
    d.ingresos,
    s.promedio,
    s.desviacion,
    ROUND((d.ingresos - s.promedio) / NULLIF(s.desviacion, 0), 2) AS z_score,
    CASE
        WHEN ABS((d.ingresos - s.promedio) / NULLIF(s.desviacion, 0)) > 2 THEN 'Anomalía'
        ELSE 'Normal'
    END AS estado
FROM diario d
CROSS JOIN stats s
WHERE ABS((d.ingresos - s.promedio) / NULLIF(s.desviacion, 0)) > 2
ORDER BY ABS((d.ingresos - s.promedio) / NULLIF(s.desviacion, 0)) DESC;
```
</details>

### Desafío 3: Predicción simple

Usando la media móvil de los últimos 30 días, proyecta los ingresos del próximo mes.

<details>
<summary>💡 Solución</summary>

```sql
WITH diario AS (
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
    ROUND(AVG(ingresos) * 365, 2) AS proyeccion_anual,
    COUNT(*) AS dias_con_datos
FROM diario;
```
</details>

### Desafío 4: Cliente VIP en riesgo

Clientes que eran VIP pero llevan más de 30 días sin comprar.

<details>
<summary>💡 Solución</summary>

```sql
WITH clientes_stats AS (
    SELECT 
        c.id,
        c.nombre,
        SUM(p.cantidad * pr.precio) AS monetario,
        CURRENT_DATE - MAX(p.fecha) AS dias_sin_comprar
    FROM clientes c
    JOIN pedidos p ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
)
SELECT 
    nombre,
    monetario,
    dias_sin_comprar
FROM clientes_stats
WHERE monetario > 500
  AND dias_sin_comprar > 30
ORDER BY monetario DESC;
```
</details>

### Desafío 5: Estacionalidad

Compara las ventas del mismo mes entre años (YoY).

<details>
<summary>💡 Solución</summary>

```sql
WITH mensual AS (
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
    LAG(ingresos, 12) OVER (ORDER BY anio, mes) AS mismo_mes_anterior,
    ROUND(100.0 * (ingresos - LAG(ingresos, 12) OVER (ORDER BY anio, mes))
          / NULLIF(LAG(ingresos, 12) OVER (ORDER BY anio, mes), 0), 2) AS yoy_pct
FROM mensual
ORDER BY anio DESC, mes DESC;
```
</details>

---

## 🚀 Retos avanzados

### Reto 1: Vista materializada optimizada

Crea una vista materializada para el dashboard principal y programa su refresco cada hora.

<details>
<summary>💡 Pista</summary>

```sql
CREATE MATERIALIZED VIEW mv_dashboard AS
SELECT 
    CURRENT_DATE AS fecha,
    SUM(CASE WHEN fecha = CURRENT_DATE THEN cantidad * precio ELSE 0 END) AS ingresos_hoy,
    SUM(CASE WHEN DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE) 
             THEN cantidad * precio ELSE 0 END) AS ingresos_mes,
    COUNT(DISTINCT CASE WHEN fecha = CURRENT_DATE THEN p.id END) AS pedidos_hoy,
    COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE) 
                        THEN p.id END) AS pedidos_mes
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id;

CREATE UNIQUE INDEX ON mv_dashboard(fecha);
```

Luego programa el refresco con pg_cron o cron del sistema.
</details>

### Reto 2: Sistema de alertas

Diseña una tabla `alertas` y los triggers/jobs que generen alertas automáticas:

- Stock crítico
- Caída de ventas > 15% MoM
- Cliente VIP inactivo > 45 días
- Producto top sin stock

<details>
<summary>💡 Pista</summary>

```sql
CREATE TABLE alertas (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    mensaje TEXT NOT NULL,
    datos JSONB,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha TIMESTAMP DEFAULT NOW()
);

-- Ejemplo de job
CREATE OR REPLACE FUNCTION generar_alertas_stock()
RETURNS void AS $$
BEGIN
    INSERT INTO alertas (tipo, mensaje, datos)
    SELECT 
        'stock_bajo',
        'Producto ' || nombre || ' con stock ' || stock,
        jsonb_build_object('producto_id', id, 'stock', stock)
    FROM productos
    WHERE stock < 5;
END;
$$ LANGUAGE plpgsql;
```
</details>

### Reto 3: Análisis de cesta avanzado

Encuentra las reglas de asociación con soporte y confianza:

- **Soporte:** % de pedidos con A y B juntos
- **Confianza:** P(B|A) = P(A∩B) / P(A)
- **Lift:** confianza / P(B)

<details>
<summary>💡 Pista</summary>

```sql
WITH total AS (SELECT COUNT(*)::float AS n FROM pedidos),
combinaciones AS (
    SELECT p1.producto_id AS a, p2.producto_id AS b, COUNT(*)::float AS juntos
    FROM pedidos p1
    JOIN pedidos p2 ON p1.cliente_id = p2.cliente_id AND p1.fecha = p2.fecha
    WHERE p1.producto_id < p2.producto_id
    GROUP BY a, b
),
conteos AS (
    SELECT producto_id, COUNT(*)::float AS freq FROM pedidos GROUP BY producto_id
)
SELECT 
    c.a, c.b, c.juntos,
    c.juntos / t.n AS soporte,
    c.juntos / ca.freq AS confianza,
    (c.juntos / ca.freq) / (cb.freq / t.n) AS lift
FROM combinaciones c
CROSS JOIN total t
JOIN conteos ca ON c.a = ca.producto_id
JOIN conteos cb ON c.b = cb.producto_id
WHERE c.juntos >= 2
ORDER BY lift DESC;
```
</details>