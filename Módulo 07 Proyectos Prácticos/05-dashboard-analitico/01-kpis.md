# 📊 Definición de KPIs

Cada KPI con su fórmula, granularidad y consulta asociada.

## 🎯 KPIs de Ventas

### 1. Ingresos Totales

**Fórmula:** `SUM(cantidad * precio)`  
**Granularidad:** día, semana, mes, año  
**Uso:** métrica principal de negocio

```sql
SELECT SUM(cantidad * precio) AS ingresos
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
WHERE fecha >= DATE_TRUNC('month', CURRENT_DATE);
```

### 2. Crecimiento MoM (Month over Month)

**Fórmula:** `(ingresos_mes_actual - ingresos_mes_anterior) / ingresos_mes_anterior * 100`  
**Uso:** medir aceleración/deceleración

```sql
WITH mensual AS (
    SELECT DATE_TRUNC('month', fecha) AS mes, SUM(cantidad * precio) AS ingresos
    FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
    GROUP BY mes
)
SELECT 
    mes, ingresos,
    ROUND(100.0 * (ingresos - LAG(ingresos) OVER (ORDER BY mes)) 
          / NULLIF(LAG(ingresos) OVER (ORDER BY mes), 0), 2) AS mom_pct
FROM mensual;
```

### 3. Crecimiento YoY (Year over Year)

**Fórmula:** `(ingresos_año_actual - ingresos_año_anterior) / ingresos_año_anterior * 100`  
**Uso:** elimina estacionalidad

```sql
LAG(ingresos, 12) OVER (ORDER BY anio, mes)
```

### 4. Ticket Promedio (AOV)

**Fórmula:** `SUM(ingresos) / COUNT(pedidos)`  
**Uso:** medir valor por transacción

```sql
SELECT ROUND(AVG(total_pedido), 2) AS ticket_promedio
FROM (
    SELECT p.id, SUM(cantidad * precio) AS total_pedido
    FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
    GROUP BY p.id
) t;
```

### 5. Número de Pedidos

**Fórmula:** `COUNT(DISTINCT pedido_id)`  
**Granularidad:** día, semana, mes

### 6. Tasa de Conversión

**Fórmula:** `pedidos / visitas * 100`  
**Nota:** requiere tracking de visitas (no en este dataset)

---

## 🛍️ KPIs de Productos

### 7. Top Productos

**Fórmula:** ranking por `SUM(cantidad * precio)`  
**Uso:** identificar best-sellers

```sql
SELECT pr.nombre, SUM(p.cantidad) AS unidades, SUM(p.cantidad * pr.precio) AS ingresos
FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.id, pr.nombre
ORDER BY ingresos DESC
LIMIT 10;
```

### 8. Categorías Más Rentables

**Fórmula:** `SUM(cantidad * precio)` agrupado por categoría  
**Uso:** decidir dónde invertir

```sql
SELECT pr.categoria, SUM(p.cantidad * pr.precio) AS ingresos,
       ROUND(100.0 * SUM(p.cantidad * pr.precio) / SUM(SUM(p.cantidad * pr.precio)) OVER (), 2) AS pct
FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
GROUP BY pr.categoria
ORDER BY ingresos DESC;
```

### 9. Productos con Stock Bajo

**Fórmula:** `stock < umbral` (ej: 10)  
**Uso:** alertas de reabastecimiento

```sql
SELECT nombre, stock, categoria
FROM productos
WHERE stock < 10
ORDER BY stock ASC;
```

### 10. Rotación de Inventario

**Fórmula:** `unidades_vendidas / stock_promedio`  
**Uso:** eficiencia del inventario

### 11. Productos Sin Movimiento

**Fórmula:** productos sin ventas en N días  
**Uso:** detectar productos obsoletos

```sql
SELECT pr.nombre
FROM productos pr
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.producto_id = pr.id AND p.fecha >= CURRENT_DATE - INTERVAL '30 days'
);
```

---

## 👥 KPIs de Clientes

### 12. Clientes Nuevos

**Fórmula:** clientes cuyo primer pedido es del período

```sql
WITH primeros AS (
    SELECT cliente_id, MIN(fecha) AS primer_pedido
    FROM pedidos GROUP BY cliente_id
)
SELECT COUNT(*) FROM primeros
WHERE DATE_TRUNC('month', primer_pedido) = DATE_TRUNC('month', CURRENT_DATE);
```

### 13. Clientes Recurrentes

**Fórmula:** clientes con > 1 pedido

```sql
SELECT COUNT(*) FROM (
    SELECT cliente_id FROM pedidos
    GROUP BY cliente_id
    HAVING COUNT(*) > 1
) t;
```

### 14. Tasa de Retención

**Fórmula:** `clientes_que_repiten / clientes_totales * 100`  
**Granularidad:** por cohorte

### 15. Customer Lifetime Value (CLV)

**Fórmula:** `ticket_promedio * frecuencia * duración_vida`  
**Uso:** cuánto vale un cliente

```sql
SELECT 
    ROUND(AVG(total_gastado), 2) AS clv_promedio
FROM (
    SELECT cliente_id, SUM(cantidad * precio) AS total_gastado
    FROM pedidos p JOIN productos pr ON p.producto_id = pr.id
    GROUP BY cliente_id
) t;
```

### 16. Segmentación RFM

**Recency, Frequency, Monetary:**
- R: días desde último pedido
- F: número de pedidos
- M: gasto total

```sql
SELECT 
    c.nombre,
    CURRENT_DATE - MAX(p.fecha) AS recencia,
    COUNT(p.id) AS frecuencia,
    SUM(p.cantidad * pr.precio) AS monetario,
    CASE
        WHEN CURRENT_DATE - MAX(p.fecha) <= 30 AND COUNT(p.id) >= 2 AND SUM(p.cantidad * pr.precio) > 500 THEN 'VIP'
        WHEN CURRENT_DATE - MAX(p.fecha) <= 60 THEN 'Activo'
        WHEN CURRENT_DATE - MAX(p.fecha) > 90 THEN 'En riesgo'
        ELSE 'Regular'
    END AS segmento
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre;
```

### 17. Churn Rate

**Fórmula:** `clientes_perdidos / clientes_totales * 100`  
**Definición:** clientes sin compras en N días (ej: 90)

---

## ⚙️ KPIs Operativos

### 18. Pedidos por Estado

**Uso:** ver cuellos de botella

### 19. Tiempo Promedio de Entrega

**Fórmula:** `AVG(fecha_entrega - fecha_pedido)`  
**Nota:** requiere tabla de envíos

### 20. Tasa de Cancelación

**Fórmula:** `pedidos_cancelados / pedidos_totales * 100`

---

## 📈 KPIs de Crecimiento

### 21. Nuevos Clientes vs Recurrentes

**Fórmula:** comparación mes a mes

### 22. Retención por Cohorte

**Uso:** ver cómo retienen los clientes mes a mes

```sql
WITH cohortes AS (
    SELECT cliente_id, DATE_TRUNC('month', MIN(fecha)) AS cohorte
    FROM pedidos GROUP BY cliente_id
),
actividad AS (
    SELECT DISTINCT p.cliente_id, c.cohorte, DATE_TRUNC('month', p.fecha) AS mes
    FROM pedidos p JOIN cohortes c ON p.cliente_id = c.cliente_id
)
SELECT 
    cohorte,
    EXTRACT(EPOCH FROM (mes - cohorte))/2629800 AS mes_n,
    COUNT(DISTINCT cliente_id) AS activos
FROM actividad
GROUP BY cohorte, mes_n
ORDER BY cohorte, mes_n;
```

### 23. Media Móvil de Ventas

**Fórmula:** promedio de últimos N días  
**Uso:** suavizar tendencias

```sql
AVG(ingresos) OVER (ORDER BY dia ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
```

### 24. Proyección de Ingresos

**Fórmula simple:** `promedio_diario * dias_del_mes`  
**Fórmula avanzada:** regresión lineal (no en SQL puro)

---

## 🎯 KPIs del Dashboard

### Panel principal

| KPI | Frecuencia | Fuente |
|-----|-----------|--------|
| Ingresos hoy | Tiempo real | mv_kpis_diarios |
| Ingresos mes | Cada hora | mv_ventas_mensual |
| Pedidos hoy | Tiempo real | mv_kpis_diarios |
| Ticket promedio | Cada hora | mv_ventas_mensual |
| Crecimiento MoM | Diario | mv_ventas_mensual |
| Top 5 productos | Cada hora | mv_top_productos |
| Clientes nuevos | Diario | mv_resumen_clientes |
| Stock bajo | Tiempo real | productos |

### Panel secundario

| KPI | Frecuencia |
|-----|-----------|
| Cohortes | Diario |
| RFM | Semanal |
| Retención | Semanal |
| Media móvil | Diario |
| Proyección | Diario |

---

## 📊 Sistema de alertas

| Alerta | Condición | Acción |
|--------|-----------|--------|
| Stock crítico | stock < 5 | Notificar a compras |
| Caída de ventas | MoM < -10% | Revisar campañas |
| Cliente VIP inactivo | > 30 días sin comprar | Enviar cupón |
| Producto estrella sin stock | top 10 + stock = 0 | Reabastecer urgente |
| Pico de cancelaciones | > 5% | Revisar operaciones |

---

## ✅ Checklist de KPIs

- [ ] Ingresos (día, semana, mes, año)
- [ ] Crecimiento MoM
- [ ] Crecimiento YoY
- [ ] Ticket promedio
- [ ] Top 10 productos
- [ ] Categorías rentables
- [ ] Stock bajo
- [ ] Clientes nuevos vs recurrentes
- [ ] RFM
- [ ] Cohortes
- [ ] Retención
- [ ] Media móvil
- [ ] Proyecciones simples