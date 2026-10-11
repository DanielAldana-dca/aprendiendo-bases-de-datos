# 03 - ORDER BY y LIMIT

## 🎯 Objetivos
- Ordenar resultados ascendente y descendente
- Ordenar por varias columnas
- Limitar el número de filas devueltas

## 📚 ORDER BY
Ordena los resultados. Sin él, el orden **no está garantizado**.

### Sintaxis
```sql
SELECT columnas
FROM tabla
ORDER BY columna [ASC|DESC];
```

- `ASC` = ascendente (por defecto)
- `DESC` = descendente

### Ejemplos

```sql
-- Clientes por edad (menor a mayor)
SELECT nombre, edad FROM clientes ORDER BY edad;

-- Clientes por edad (mayor a menor)
SELECT nombre, edad FROM clientes ORDER BY edad DESC;

-- Productos por precio descendente
SELECT nombre, precio FROM productos ORDER BY precio DESC;

-- Por texto alfabéticamente
SELECT nombre FROM clientes ORDER BY nombre ASC;
```

### Ordenar por varias columnas
```sql
-- Primero por ciudad (A-Z), luego por edad (mayor a menor)
SELECT nombre, ciudad, edad
FROM clientes
ORDER BY ciudad ASC, edad DESC;
```

### Ordenar por columna calculada
```sql
SELECT nombre, precio, precio * 1.21 AS precio_iva
FROM productos
ORDER BY precio_iva DESC;
```

### Ordenar por posición
```sql
-- 2 = segunda columna del SELECT
SELECT nombre, edad FROM clientes ORDER BY 2 DESC;
```
> ⚠️ No recomendado: si cambias el SELECT, se rompe.

### NULLs en el ordenamiento
- En PostgreSQL: NULLs van al **final** en ASC, al inicio en DESC
- Puedes controlarlo:
```sql
SELECT nombre, email FROM clientes 
ORDER BY email ASC NULLS LAST;
```

## 📚 LIMIT y OFFSET

### LIMIT
Limita cuántas filas devuelve.
```sql
-- Los 3 productos más caros
SELECT nombre, precio FROM productos
ORDER BY precio DESC
LIMIT 3;

-- Los 5 clientes más jóvenes
SELECT nombre, edad FROM clientes
ORDER BY edad ASC
LIMIT 5;
```

### OFFSET
Salta N filas (útil para paginación).
```sql
-- Página 2 (5 por página): salta los primeros 5
SELECT * FROM productos
ORDER BY id
LIMIT 5 OFFSET 5;
```

> 💡 Fórmula de paginación: `OFFSET = (pagina - 1) * tamaño_pagina`

### MySQL / SQL Server usan sintaxis distinta
```sql
-- MySQL
SELECT * FROM productos LIMIT 5 OFFSET 5;

-- SQL Server
SELECT * FROM productos ORDER BY id OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;
```

## 🎯 Combinando todo
```sql
SELECT nombre, categoria, precio
FROM productos
WHERE categoria = 'Electrónica'
ORDER BY precio DESC
LIMIT 3;
```
**Traducción:** "Los 3 productos electrónicos más caros"

## ⚠️ Errores comunes
- Usar LIMIT sin ORDER BY (el resultado es impredecible)
- Olvidar que OFFSET sin ORDER BY no tiene sentido
- Escribir `LIMIT 0, 10` (MySQL) creyendo que es estándar

## ✅ Ejercicios
1. Los 5 productos más caros
2. Los 3 clientes más jóvenes
3. Clientes ordenados por ciudad (A-Z) y luego por nombre (A-Z)
4. Los 2 productos más baratos de 'Ropa'
5. El cliente de mayor edad
6. Página 2 (3 por página) de productos ordenados por precio descendente
7. Clientes ordenados por email, con los NULL al final

## 🔗 Recursos
- [ORDER BY - PostgreSQL](https://www.postgresql.org/docs/current/queries-order.html)
- [LIMIT y OFFSET](https://www.postgresql.org/docs/current/queries-limit.html)