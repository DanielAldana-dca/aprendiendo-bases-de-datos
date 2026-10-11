# 🧪 Ejercicios - JOINs

## Nivel 🟢 Fácil

### 1. Cliente y pedido
Muestra el nombre del cliente y la fecha de cada pedido.

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre, p.fecha
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
ORDER BY p.fecha;
```
</details>

### 2. Pedido con nombre del producto
Muestra el id del pedido, el nombre del producto y la cantidad.

<details>
<summary>💡 Solución</summary>

```sql
SELECT p.id AS pedido_id, pr.nombre AS producto, p.cantidad
FROM pedidos p
JOIN productos pr ON p.producto_id = pr.id
ORDER BY p.id;
```
</details>

---

## Nivel 🟡 Intermedio

### 3. Todo junto
Muestra: nombre del cliente, nombre del producto, cantidad y fecha.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    c.nombre AS cliente,
    pr.nombre AS producto,
    p.cantidad,
    p.fecha
FROM pedidos p
JOIN clientes c  ON p.cliente_id = c.id
JOIN productos pr ON p.producto_id = pr.id
ORDER BY p.fecha;
```
</details>

### 4. Clientes sin pedidos
Lista los clientes que **nunca** han hecho un pedido.

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL;
```
</details>

### 5. Productos no vendidos
¿Qué productos nunca se han vendido?

<details>
<summary>💡 Solución</summary>

```sql
SELECT pr.nombre
FROM productos pr
LEFT JOIN pedidos p ON pr.id = p.producto_id
WHERE p.id IS NULL;
```
</details>

---

## Nivel 🔴 Difícil

### 6. Pedidos de Madrid
Muestra todos los pedidos hechos por clientes de Madrid (nombre, producto, fecha).

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre, pr.nombre AS producto, p.fecha
FROM pedidos p
JOIN clientes c  ON p.cliente_id = c.id
JOIN productos pr ON p.producto_id = pr.id
WHERE c.ciudad = 'Madrid'
ORDER BY p.fecha;
```
</details>

### 7. Total gastado por cliente
Muestra el nombre del cliente y el total gastado (suma de `cantidad * precio`).

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
ORDER BY total_gastado DESC;
```
</details>

### 8. Clientes que compraron electrónica
Lista los clientes que han comprado al menos un producto de categoría 'Electrónica'.

<details>
<summary>💡 Solución</summary>

```sql
SELECT DISTINCT c.nombre
FROM clientes c
JOIN pedidos p    ON c.id = p.cliente_id
JOIN productos pr ON p.producto_id = pr.id
WHERE pr.categoria = 'Electrónica';
```
</details>

### 9. Clientes sin pedidos del mes actual
Muestra los clientes que no han hecho pedidos en marzo de 2024.

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p 
    ON c.id = p.cliente_id 
   AND p.fecha BETWEEN '2024-03-01' AND '2024-03-31'
WHERE p.id IS NULL;
```
</details>

### 10. Productos con su categoría y veces vendido
Muestra el nombre del producto, su categoría y cuántas veces se ha vendido (si nunca, 0).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    pr.nombre,
    pr.categoria,
    COUNT(p.id) AS veces_vendido
FROM productos pr
LEFT JOIN pedidos p ON pr.id = p.producto_id
GROUP BY pr.id, pr.nombre, pr.categoria
ORDER BY veces_vendido DESC;
```
</details>