# 🧪 Ejercicios - Módulo 02 (Parte 1)

> 📦 Ejecuta antes el script `recursos/datasets/tienda.sql`

## Nivel 🟢 Fácil

### 1. SELECT básico
Muestra nombre y precio de todos los productos.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio FROM productos;
```
</details>

### 2. Ciudades únicas
Lista todas las ciudades distintas de clientes.

<details>
<summary>💡 Solución</summary>

```sql
SELECT DISTINCT ciudad FROM clientes;
```
</details>

### 3. Clientes de Madrid
Muestra todos los clientes cuya ciudad sea Madrid.

<details>
<summary>💡 Solución</summary>

```sql
SELECT * FROM clientes WHERE ciudad = 'Madrid';
```
</details>

### 4. Productos caros
Productos con precio mayor a 100.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio FROM productos WHERE precio > 100;
```
</details>

---

## Nivel 🟡 Intermedio

### 5. Filtro combinado
Clientes de Madrid **o** Barcelona, mayores de 25 años.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, ciudad, edad
FROM clientes
WHERE ciudad IN ('Madrid', 'Barcelona') AND edad > 25;
```
</details>

### 6. Búsqueda por patrón
Clientes cuyo nombre empiece por 'M' o 'L'.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre FROM clientes
WHERE nombre LIKE 'M%' OR nombre LIKE 'L%';
```
</details>

### 7. Rango de precios
Productos entre 50 y 200 €, ordenados por precio descendente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio FROM productos
WHERE precio BETWEEN 50 AND 200
ORDER BY precio DESC;
```
</details>

### 8. Top 3
Los 3 productos más caros.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio FROM productos
ORDER BY precio DESC
LIMIT 3;
```
</details>

### 9. Cliente sin email
Muestra los clientes que no tienen email registrado.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre FROM clientes WHERE email IS NULL;
```
</details>

---

## Nivel 🔴 Difícil

### 10. Cálculo y orden
Muestra los productos con su precio con IVA (21%) y ordénalos de mayor a menor por ese precio.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio, precio * 1.21 AS precio_con_iva
FROM productos
ORDER BY precio_con_iva DESC;
```
</details>

### 11. Varios filtros
Productos de 'Electrónica' o 'Muebles' con stock entre 10 y 50, ordenados por categoría y luego por precio descendente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, categoria, precio, stock
FROM productos
WHERE categoria IN ('Electrónica', 'Muebles')
  AND stock BETWEEN 10 AND 50
ORDER BY categoria ASC, precio DESC;
```
</details>

### 12. Paginación
Muestra la página 2 (3 productos por página) ordenados por precio descendente.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, precio FROM productos
ORDER BY precio DESC
LIMIT 3 OFFSET 3;
```
</details>

### 13. Modificación segura
Sube un 15% el precio de todos los productos de la categoría 'Hogar' y muestra el resultado.

<details>
<summary>💡 Solución</summary>

```sql
-- Primero verifica
SELECT * FROM productos WHERE categoria = 'Hogar';

-- Aplica el cambio
UPDATE productos
SET precio = precio * 1.15
WHERE categoria = 'Hogar';

-- Verifica resultado
SELECT * FROM productos WHERE categoria = 'Hogar';
```
</details>

### 14. Insertar varios
Inserta 3 productos nuevos de categoría 'Deportes' con precios y stocks variados.

<details>
<summary>💡 Solución</summary>

```sql
INSERT INTO productos (id, nombre, categoria, precio, stock) VALUES
(13, 'Balón Fútbol', 'Deportes', 25.00, 40),
(14, 'Raqueta Tenis', 'Deportes', 89.00, 15),
(15, 'Bicicleta MTB', 'Deportes', 450.00, 5);
```
</details>

### 15. Limpieza
Elimina los pedidos anteriores al 2024-03-01 con cantidad = 1.

<details>
<summary>💡 Solución</summary>

```sql
-- Verifica primero
SELECT * FROM pedidos WHERE fecha < '2024-03-01' AND cantidad = 1;

-- Elimina
DELETE FROM pedidos WHERE fecha < '2024-03-01' AND cantidad = 1;
```
</details>

---

## 🎯 Autoevaluación

- [ ] Sé escribir un SELECT con columnas específicas
- [ ] Domino WHERE con operadores lógicos
- [ ] Uso correctamente BETWEEN, IN, LIKE, IS NULL
- [ ] Puedo ordenar por una o varias columnas
- [ ] Sé paginar con LIMIT/OFFSET
- [ ] Puedo insertar uno o varios registros
- [ ] Actualizo con seguridad usando SELECT previo
- [ ] Borro registros sin miedo (con WHERE)