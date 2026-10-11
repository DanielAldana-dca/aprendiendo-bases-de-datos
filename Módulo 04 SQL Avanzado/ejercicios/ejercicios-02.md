# 🧪 Ejercicios - Window Functions

## Nivel 🟢 Fácil

### 1. Numerar productos
Numera los productos por precio descendente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) AS posicion
FROM productos;
```
</details>

### 2. Ranking de clientes
Ranking de clientes por edad (mayor a menor).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    nombre,
    edad,
    RANK() OVER (ORDER BY edad DESC) AS rank_edad
FROM clientes;
```
</details>

---

## Nivel 🟡 Intermedio

### 3. Top por categoría
Top 2 de productos más caros por categoría.

<details>
<summary>💡 Solución</summary>

```sql
WITH ranking AS (
    SELECT 
        nombre,
        categoria,
        precio,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS rn
    FROM productos
)
SELECT nombre, categoria, precio
FROM ranking
WHERE rn <= 2
ORDER BY categoria, precio DESC;
```
</details>

### 4. Porcentaje del total de categoría
Cada producto con su porcentaje sobre el total de su categoría.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    nombre,
    categoria,
    precio,
    ROUND(100.0 * precio / SUM(precio) OVER (PARTITION BY categoria), 2) AS porcentaje
FROM productos
ORDER BY categoria, porcentaje DESC;
```
</details>

### 5. Diferencia con el anterior
Para cada producto, compara su precio con el del anterior (por id).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    id,
    nombre,
    precio,
    LAG(precio) OVER (ORDER BY id) AS precio_anterior,
    precio - LAG(precio) OVER (ORDER BY id) AS diferencia
FROM productos
ORDER BY id;
```
</details>

---

## Nivel 🔴 Difícil

### 6. Total acumulado
Total acumulado de unidades vendidas por fecha.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    fecha,
    cantidad,
    SUM(cantidad) OVER (ORDER BY fecha, id) AS acumulado
FROM pedidos
ORDER BY fecha, id;
```
</details>

### 7. Cliente top por ciudad
El cliente que más gastó en cada ciudad.

<details>
<summary>💡 Solución</summary>

```sql
WITH gastos AS (
    SELECT 
        c.nombre,
        c.ciudad,
        SUM(p.cantidad * pr.precio) AS total,
        ROW_NUMBER() OVER (PARTITION BY c.ciudad ORDER BY SUM(p.cantidad * pr.precio) DESC) AS rn
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre, c.ciudad
)
SELECT ciudad, nombre, total
FROM gastos
WHERE rn = 1
ORDER BY total DESC;
```
</details>

### 8. Crecimiento mensual
Variación de pedidos mes a mes.

<details>
<summary>💡 Solución (PostgreSQL)</summary>

```sql
WITH mensual AS (
    SELECT 
        DATE_TRUNC('month', fecha) AS mes,
        COUNT(*) AS pedidos
    FROM pedidos
    GROUP BY mes
)
SELECT 
    mes,
    pedidos,
    LAG(pedidos) OVER (ORDER BY mes) AS mes_anterior,
    pedidos - LAG(pedidos) OVER (ORDER BY mes) AS variacion
FROM mensual
ORDER BY mes;
```
</details>

### 9. Top 3 clientes por gasto
Ranking de clientes por gasto, mostrando solo el top 3.

<details>
<summary>💡 Solución</summary>

```sql
WITH gastos AS (
    SELECT 
        c.nombre,
        SUM(p.cantidad * pr.precio) AS total
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY total DESC) AS pos,
    nombre,
    total
FROM gastos
ORDER BY total DESC
LIMIT 3;
```
</details>

### 10. Promedio móvil
Promedio móvil de 3 pedidos consecutivos (por id).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    id,
    fecha,
    cantidad,
    ROUND(AVG(cantidad) OVER (
        ORDER BY id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS promedio_movil_3
FROM pedidos
ORDER BY id;
```
</details>