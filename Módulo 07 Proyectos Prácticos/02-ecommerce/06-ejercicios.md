# 🧪 Ejercicios - E-commerce

## Nivel 🟢 Fácil

### 1. Listar productos por categoría
Muestra todos los productos con su categoría, ordenados por categoría y nombre.

<details>
<summary>💡 Solución</summary>

```sql
SELECT p.nombre AS producto, c.nombre AS categoria, p.precio_base
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = TRUE
ORDER BY c.nombre, p.nombre;
```

</details>

### 2. Stock total por producto
Para cada producto, suma el stock de todas sus variantes.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    p.nombre,
    COUNT(v.id) AS num_variantes,
    COALESCE(SUM(v.stock), 0) AS stock_total
FROM productos p
LEFT JOIN variantes v ON p.id = v.producto_id AND v.activa = TRUE
GROUP BY p.id, p.nombre
ORDER BY stock_total DESC;
```

</details>

---

## Nivel 🟡 Intermedio

### 3. Productos con más de una variante
Lista productos que tienen múltiples variantes.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    p.nombre,
    COUNT(v.id) AS num_variantes
FROM productos p
JOIN variantes v ON p.id = v.producto_id
GROUP BY p.id, p.nombre
HAVING COUNT(v.id) > 1
ORDER BY num_variantes DESC;
```

</details>

### 4. Pedidos por estado
Cuenta cuántos pedidos hay en cada estado.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    estado,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 2) AS porcentaje
FROM pedidos
GROUP BY estado
ORDER BY total DESC;
```

</details>

### 5. Clientes que nunca han comprado
Lista usuarios sin pedidos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT u.id, u.email, u.nombre || ' ' || u.apellido AS cliente
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
WHERE p.id IS NULL;
```

</details>

---

## Nivel 🔴 Difícil

### 6. Ranking de clientes con window functions
Top 5 clientes por gasto, mostrando posición y porcentaje.

<details>
<summary>💡 Solución</summary>

```sql
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
    ROUND(100.0 * total_gastado / SUM(total_gastado) OVER (), 2) AS porcentaje
FROM gastos
ORDER BY total_gastado DESC
LIMIT 5;
```

</details>

### 7. Categorías con jerarquía
Muestra la jerarquía completa de categorías (padre > hijo).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    COALESCE(padre.nombre, '—') AS padre,
    hijo.nombre AS subcategoria
FROM categorias hijo
LEFT JOIN categorias padre ON hijo.padre_id = padre.id
ORDER BY padre.nombre NULLS FIRST, hijo.nombre;
```

</details>

### 8. Productos más vendidos por categoría
Top 3 productos por ingresos en cada categoría.

<details>
<summary>💡 Solución</summary>

```sql
WITH ranking AS (
    SELECT 
        c.nombre AS categoria,
        p.nombre AS producto,
        SUM(lp.subtotal) AS ingresos,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY SUM(lp.subtotal) DESC) AS rn
    FROM lineas_pedido lp
    JOIN pedidos pe ON lp.pedido_id = pe.id
    JOIN variantes v ON lp.variante_id = v.id
    JOIN productos p ON v.producto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    WHERE pe.estado NOT IN ('cancelado')
    GROUP BY c.id, c.nombre, p.id, p.nombre
)
SELECT categoria, producto, ingresos
FROM ranking
WHERE rn <= 3
ORDER BY categoria, ingresos DESC;
```

</details>

### 9. Análisis de cupones
Muestra cuántos pedidos usaron cada cupón y el descuento total aplicado.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    c.codigo,
    c.tipo,
    c.valor,
    c.usos_actuales,
    c.usos_max,
    COALESCE(SUM(p.descuento), 0) AS descuento_total,
    COALESCE(AVG(p.descuento), 0) AS descuento_promedio
FROM cupones c
LEFT JOIN pedidos p ON c.id = p.cupon_id
GROUP BY c.id, c.codigo, c.tipo, c.valor, c.usos_actuales, c.usos_max
ORDER BY descuento_total DESC;
```

</details>

### 10. Análisis temporal
Ventas por mes con crecimiento MoM.

<details>
<summary>💡 Solución</summary>

```sql
WITH ventas AS (
    SELECT 
        DATE_TRUNC('month', fecha) AS mes,
        SUM(total) AS ingresos,
        COUNT(*) AS num_pedidos
    FROM pedidos
    WHERE estado NOT IN ('cancelado')
    GROUP BY mes
)
SELECT 
    mes,
    num_pedidos,
    ingresos,
    LAG(ingresos) OVER (ORDER BY mes) AS mes_anterior,
    ROUND(100.0 * (ingresos - LAG(ingresos) OVER (ORDER BY mes)) 
          / NULLIF(LAG(ingresos) OVER (ORDER BY mes), 0), 2) AS crecimiento_pct
FROM ventas
ORDER BY mes;
```

</details>

---

## 🎯 Desafíos integradores

### Desafío 1: Reporte ejecutivo
Crea una sola query que devuelva:
- Total de ingresos del mes
- Número de pedidos
- Ticket promedio
- Cliente top
- Producto top

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    (SELECT SUM(total) FROM pedidos 
     WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE)
       AND estado NOT IN ('cancelado')) AS ingresos_mes,
    (SELECT COUNT(*) FROM pedidos 
     WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', CURRENT_DATE)) AS pedidos_mes,
    (SELECT ROUND(AVG(total), 2) FROM pedidos 
     WHERE estado NOT IN ('cancelado')) AS ticket_promedio,
    (SELECT u.nombre || ' ' || u.apellido 
     FROM usuarios u
     JOIN pedidos p ON u.id = p.usuario_id
     WHERE p.estado NOT IN ('cancelado')
     GROUP BY u.id, u.nombre, u.apellido
     ORDER BY SUM(p.total) DESC LIMIT 1) AS cliente_top,
    (SELECT p.nombre 
     FROM productos p
     JOIN variantes v ON p.id = v.producto_id
     JOIN lineas_pedido lp ON v.id = lp.variante_id
     JOIN pedidos pe ON lp.pedido_id = pe.id
     WHERE pe.estado NOT IN ('cancelado')
     GROUP BY p.id, p.nombre
     ORDER BY SUM(lp.subtotal) DESC LIMIT 1) AS producto_top;
```

</details>

### Desafío 2: Análisis de cohortes
Clientes agrupados por mes de registro, con su gasto promedio.

<details>
<summary>💡 Solución</summary>

```sql
WITH cohortes AS (
    SELECT 
        id,
        DATE_TRUNC('month', fecha_registro) AS cohorte
    FROM usuarios
),
gastos AS (
    SELECT 
        u.id,
        c.cohorte,
        COALESCE(SUM(p.total), 0) AS total
    FROM usuarios u
    JOIN cohortes c ON u.id = c.id
    LEFT JOIN pedidos p ON u.id = p.usuario_id AND p.estado NOT IN ('cancelado')
    GROUP BY u.id, c.cohorte
)
SELECT 
    cohorte,
    COUNT(*) AS clientes,
    ROUND(AVG(total), 2) AS gasto_promedio,
    SUM(total) AS ingresos_totales
FROM gastos
GROUP BY cohorte
ORDER BY cohorte;
```

</details>

### Desafío 3: Carrito con Redis
Diseña el flujo completo para:
1. Usuario añade producto
2. Usuario actualiza cantidad
3. Usuario aplica cupón
4. Usuario hace checkout

Escribe los comandos de Redis y las queries SQL necesarias.

<details>
<summary>💡 Solución</summary>

```redis
# 1. Añadir
HSET cart:1 variante:1:cantidad 1
EXPIRE cart:1 604800

# 2. Actualizar
HSET cart:1 variante:1:cantidad 2

# 3. Aplicar cupón
HSET cart:1:meta cupon "VERANO24"

# 4. Ver carrito
HGETALL cart:1
```

```sql
-- 3b. Validar cupón
SELECT * FROM cupones 
WHERE codigo = 'VERANO24' 
  AND activo = TRUE
  AND CURRENT_DATE BETWEEN valido_desde AND valido_hasta
  AND (usos_max IS NULL OR usos_actuales < usos_max);

-- 4. Checkout (transacción)
BEGIN;

INSERT INTO pedidos (usuario_id, direccion_id, cupon_id, subtotal, descuento, total)
VALUES (1, 1, 2, 100.00, 15.00, 85.00) RETURNING id;

INSERT INTO lineas_pedido (pedido_id, variante_id, producto_nombre, cantidad, precio_unitario, subtotal)
VALUES (10, 1, 'Laptop Pro 15', 1, 100.00, 100.00);

COMMIT;
```

```redis
DEL cart:1 cart:1:meta
```

</details>

### Desafío 4: Productos en riesgo
Productos con stock bajo Y alta demanda en los últimos 30 días.

<details>
<summary>💡 Solución</summary>

```sql
WITH demanda AS (
    SELECT 
        v.producto_id,
        SUM(lp.cantidad) AS unidades_vendidas
    FROM lineas_pedido lp
    JOIN variantes v ON lp.variante_id = v.id
    JOIN pedidos p ON lp.pedido_id = p.id
    WHERE p.fecha >= CURRENT_DATE - INTERVAL '30 days'
      AND p.estado NOT IN ('cancelado')
    GROUP BY v.producto_id
)
SELECT 
    p.nombre,
    SUM(v.stock) AS stock_actual,
    COALESCE(d.unidades_vendidas, 0) AS vendidas_30d,
    CASE 
        WHEN SUM(v.stock) = 0 THEN 'AGOTADO'
        WHEN SUM(v.stock) < COALESCE(d.unidades_vendidas, 0) THEN 'CRÍTICO'
        WHEN SUM(v.stock) < COALESCE(d.unidades_vendidas, 0) * 2 THEN 'RIESGO'
        ELSE 'OK'
    END AS estado
FROM productos p
JOIN variantes v ON p.id = v.producto_id
LEFT JOIN demanda d ON p.id = d.producto_id
WHERE p.activo = TRUE
GROUP BY p.id, p.nombre, d.unidades_vendidas
HAVING SUM(v.stock) < COALESCE(d.unidades_vendidas, 0) * 2
ORDER BY stock_actual ASC;
```

</details>