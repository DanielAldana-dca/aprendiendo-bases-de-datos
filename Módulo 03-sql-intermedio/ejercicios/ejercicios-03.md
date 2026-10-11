# 🧪 Ejercicios - Subconsultas

## Nivel 🟢 Fácil

### 1. Sobre el promedio
Productos más caros que el promedio general.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos)
ORDER BY precio DESC;
```
</details>

### 2. Clientes con pedidos
Clientes que han hecho al menos un pedido (usando IN).

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```
</details>

---

## Nivel 🟡 Intermedio

### 3. Clientes sin pedidos
Clientes que nunca han hecho pedidos (usando NOT EXISTS).

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);
```
</details>

### 4. Producto más caro por categoría
Muestra el producto más caro de cada categoría.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, categoria, precio
FROM productos p1
WHERE precio = (
    SELECT MAX(precio)
    FROM productos p2
    WHERE p2.categoria = p1.categoria
);
```
</details>

### 5. Categorías rentables
Categorías con precio promedio mayor a 100 (subconsulta en FROM).

<details>
<summary>💡 Solución</summary>

```sql
SELECT categoria, promedio
FROM (
    SELECT categoria, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria
) AS resumen
WHERE promedio > 100;
```
</details>

---

## Nivel 🔴 Difícil

### 6. Pedido más reciente por cliente
El pedido más reciente de cada cliente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT c.nombre, p.fecha
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.fecha = (
    SELECT MAX(p2.fecha)
    FROM pedidos p2
    WHERE p2.cliente_id = p.cliente_id
)
ORDER BY c.nombre;
```
</details>

### 7. Clientes que compraron electrónica
Clientes que han comprado al menos un producto de categoría 'Electrónica'.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre
FROM clientes
WHERE id IN (
    SELECT p.cliente_id
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE pr.categoria = 'Electrónica'
);
```
</details>

### 8. Segundo producto más caro
El segundo producto más caro (sin usar LIMIT).

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio
FROM productos
WHERE precio = (
    SELECT MAX(precio) FROM productos
    WHERE precio < (SELECT MAX(precio) FROM productos)
);
```
</details>

### 9. Clientes que gastaron más que el promedio
Clientes cuyo gasto total supera el promedio de gastos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, total
FROM (
    SELECT 
        c.nombre,
        SUM(p.cantidad * pr.precio) AS total
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
) AS gastos
WHERE total > (
    SELECT AVG(total) FROM (
        SELECT SUM(p.cantidad * pr.precio) AS total
        FROM pedidos p
        JOIN productos pr ON p.producto_id = pr.id
        GROUP BY p.cliente_id
    ) AS promedios
);
```
</details>

### 10. Productos nunca vendidos
Productos que nunca aparecen en pedidos (con NOT EXISTS).

<details>
<summary>💡 Solución</summary>

```sql
SELECT pr.nombre
FROM productos pr
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.producto_id = pr.id
);
```
</details>