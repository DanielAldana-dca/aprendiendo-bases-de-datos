# 🧪 Ejercicios - GROUP BY y Funciones Agregadas

## Nivel 🟢 Fácil

### 1. Clientes por ciudad
¿Cuántos clientes hay en cada ciudad?

<details>
<summary>💡 Solución</summary>

```sql
SELECT ciudad, COUNT(*) AS total
FROM clientes
GROUP BY ciudad
ORDER BY total DESC;
```
</details>

### 2. Productos por categoría
¿Cuántos productos hay en cada categoría?

<details>
<summary>💡 Solución</summary>

```sql
SELECT categoria, COUNT(*) AS total
FROM productos
GROUP BY categoria;
```
</details>

---

## Nivel 🟡 Intermedio

### 3. Precio promedio por categoría
Precio promedio y stock total por categoría, ordenado por precio descendente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    categoria,
    ROUND(AVG(precio), 2) AS precio_promedio,
    SUM(stock) AS stock_total
FROM productos
GROUP BY categoria
ORDER BY precio_promedio DESC;
```
</details>

### 4. Pedidos por cliente
Muestra cada cliente con el número de pedidos. Incluye clientes sin pedidos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    c.nombre,
    COUNT(p.id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
ORDER BY total_pedidos DESC;
```
</details>

### 5. Categorías con más de 3 productos
Muestra las categorías que tienen más de 3 productos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT categoria, COUNT(*) AS total
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 3;
```
</details>

---

## Nivel 🔴 Difícil

### 6. Top 3 productos más vendidos
Los 3 productos con más unidades vendidas.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    pr.nombre,
    SUM(p.cantidad) AS unidades_vendidas
FROM productos pr
JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre
ORDER BY unidades_vendidas DESC
LIMIT 3;
```
</details>

### 7. Ciudades rentables
Ciudades con más de 1 cliente y edad promedio mayor a 28.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    ciudad,
    COUNT(*) AS clientes,
    ROUND(AVG(edad), 1) AS edad_promedio
FROM clientes
GROUP BY ciudad
HAVING COUNT(*) > 1 AND AVG(edad) > 28
ORDER BY edad_promedio DESC;
```
</details>

### 8. Valor de inventario por categoría
Muestra el valor total del inventario por categoría (`SUM(precio * stock)`) y el porcentaje sobre el total.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    categoria,
    SUM(precio * stock) AS valor_categoria,
    ROUND(100.0 * SUM(precio * stock) / 
          (SELECT SUM(precio * stock) FROM productos), 2) AS porcentaje
FROM productos
GROUP BY categoria
ORDER BY valor_categoria DESC;
```
</details>

### 9. Clientes que más gastaron
Top 3 clientes por dinero gastado.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    c.nombre,
    SUM(p.cantidad * pr.precio) AS total_gastado
FROM clientes c
JOIN pedidos p   ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre
ORDER BY total_gastado DESC
LIMIT 3;
```
</details>

### 10. Ventas por mes
Número de pedidos y unidades vendidas por mes.

<details>
<summary>💡 Solución (PostgreSQL)</summary>

```sql
SELECT 
    DATE_TRUNC('month', fecha) AS mes,
    COUNT(*) AS pedidos,
    SUM(cantidad) AS unidades
FROM pedidos
GROUP BY mes
ORDER BY mes;
```

En SQLite:
```sql
SELECT 
    strftime('%Y-%m', fecha) AS mes,
    COUNT(*) AS pedidos,
    SUM(cantidad) AS unidades
FROM pedidos
GROUP BY mes
ORDER BY mes;
```
</details>