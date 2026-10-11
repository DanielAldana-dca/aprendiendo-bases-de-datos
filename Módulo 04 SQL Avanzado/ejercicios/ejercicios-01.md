# 🧪 Ejercicios - CTEs

## Nivel 🟢 Fácil

### 1. Filtro con CTE
Crea una CTE con los clientes de Madrid y filtra los mayores de 25.

<details>
<summary>💡 Solución</summary>

```sql
WITH madrileños AS (
    SELECT * FROM clientes WHERE ciudad = 'Madrid'
)
SELECT nombre, edad
FROM madrileños
WHERE edad > 25
ORDER BY edad;
```
</details>

### 2. Promedio por categoría
CTE con el precio promedio por categoría; filtra las que superan 100.

<details>
<summary>💡 Solución</summary>

```sql
WITH promedios AS (
    SELECT categoria, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria
)
SELECT categoria, ROUND(promedio, 2) AS precio_promedio
FROM promedios
WHERE promedio > 100
ORDER BY promedio DESC;
```
</details>

---

## Nivel 🟡 Intermedio

### 3. Ventas por cliente + filtro
CTE con ventas totales por cliente; muestra los que gastaron más de 100.

<details>
<summary>💡 Solución</summary>

```sql
WITH ventas AS (
    SELECT 
        c.id,
        c.nombre,
        SUM(p.cantidad * pr.precio) AS total
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
)
SELECT nombre, total
FROM ventas
WHERE total > 100
ORDER BY total DESC;
```
</details>

### 4. Top clientes
CTE con ranking por gasto; muestra el top 3.

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
SELECT nombre, total
FROM gastos
ORDER BY total DESC
LIMIT 3;
```
</details>

---

## Nivel 🔴 Difícil

### 5. Números del 1 al 100
CTE recursiva que genere 1 al 100.

<details>
<summary>💡 Solución</summary>

```sql
WITH RECURSIVE numeros(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 100
)
SELECT n FROM numeros;
```
</details>

### 6. Fechas de enero 2024
CTE recursiva que genere todas las fechas de enero 2024.

<details>
<summary>💡 Solución (PostgreSQL)</summary>

```sql
WITH RECURSIVE fechas(dia) AS (
    SELECT DATE '2024-01-01'
    UNION ALL
    SELECT dia + INTERVAL '1 day'
    FROM fechas
    WHERE dia < DATE '2024-01-31'
)
SELECT * FROM fechas;
```
</details>

### 7. CTEs encadenadas
Usa dos CTEs: una con las ventas por cliente, otra con el ranking, y muestra el top 3.

<details>
<summary>💡 Solución</summary>

```sql
WITH ventas AS (
    SELECT 
        c.nombre,
        SUM(p.cantidad * pr.precio) AS total
    FROM clientes c
    JOIN pedidos p   ON c.id = p.cliente_id
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY c.id, c.nombre
),
ranking AS (
    SELECT 
        nombre,
        total,
        ROW_NUMBER() OVER (ORDER BY total DESC) AS posicion
    FROM ventas
)
SELECT * FROM ranking WHERE posicion <= 3;
```
</details>