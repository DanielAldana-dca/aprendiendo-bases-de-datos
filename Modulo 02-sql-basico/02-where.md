# 02 - WHERE

## 🎯 Objetivos
- Filtrar filas según condiciones
- Combinar condiciones con AND, OR, NOT
- Usar operadores de comparación y patrones

## 📚 ¿Qué es WHERE?
Filtra las filas que cumplen una condición. Sin WHERE, obtienes **todas** las filas.

## 💻 Sintaxis

```sql
SELECT columnas
FROM tabla
WHERE condicion;
```

## 🔍 Operadores de comparación

| Operador | Significado |
|----------|-------------|
| `=` | Igual |
| `<>` o `!=` | Distinto |
| `>` `<` | Mayor / Menor |
| `>=` `<=` | Mayor o igual / Menor o igual |

### Ejemplos
```sql
-- Clientes de Madrid
SELECT * FROM clientes WHERE ciudad = 'Madrid';

-- Productos con precio mayor a 100
SELECT nombre, precio FROM productos WHERE precio > 100;

-- Clientes mayores de 30
SELECT nombre, edad FROM clientes WHERE edad > 30;

-- Clientes que NO son de Madrid
SELECT nombre FROM clientes WHERE ciudad <> 'Madrid';
```

## 🔗 Operadores lógicos

### AND (todas se cumplen)
```sql
SELECT * FROM clientes 
WHERE ciudad = 'Madrid' AND edad > 25;
```

### OR (al menos una)
```sql
SELECT * FROM clientes 
WHERE ciudad = 'Madrid' OR ciudad = 'Barcelona';
```

### NOT
```sql
SELECT * FROM productos 
WHERE NOT categoria = 'Electrónica';
```

### Combinados (¡usa paréntesis!)
```sql
SELECT * FROM clientes
WHERE (ciudad = 'Madrid' OR ciudad = 'Barcelona')
  AND edad >= 30;
```

## 📋 BETWEEN, IN, LIKE, IS NULL

### BETWEEN (rango inclusivo)
```sql
SELECT * FROM productos WHERE precio BETWEEN 50 AND 200;

SELECT * FROM clientes WHERE edad BETWEEN 25 AND 35;
```

### IN (lista de valores)
```sql
SELECT * FROM clientes 
WHERE ciudad IN ('Madrid', 'Barcelona', 'Valencia');

SELECT * FROM productos 
WHERE categoria IN ('Electrónica', 'Muebles');
```

### LIKE (patrones de texto)
| Comodín | Significa |
|---------|-----------|
| `%` | Cualquier cantidad de caracteres |
| `_` | Un solo carácter |

```sql
-- Empieza por 'A'
SELECT * FROM clientes WHERE nombre LIKE 'A%';

-- Termina por 'z'
SELECT * FROM clientes WHERE nombre LIKE '%z';

-- Contiene 'ar'
SELECT * FROM clientes WHERE nombre LIKE '%ar%';

-- Exactamente 4 letras
SELECT * FROM clientes WHERE nombre LIKE '____';
```

### IS NULL / IS NOT NULL
> ⚠️ NULL no se compara con `=`. Se usa `IS NULL`.

```sql
-- Clientes sin email
SELECT * FROM clientes WHERE email IS NULL;

-- Clientes con email
SELECT * FROM clientes WHERE email IS NOT NULL;
```

## 💡 Combinando varios filtros
```sql
SELECT nombre, precio, categoria
FROM productos
WHERE categoria = 'Electrónica'
  AND precio BETWEEN 20 AND 500
  AND stock > 0;
```

## ⚠️ Errores comunes
- `WHERE email = NULL` ❌ → `WHERE email IS NULL` ✅
- Olvidar comillas en texto: `WHERE ciudad = Madrid` ❌
- Confundir `LIKE` con `=` (LIKE permite patrones)
- No usar paréntesis al combinar AND/OR (¡la precedencia importa!)

## ✅ Ejercicios
1. Productos con stock menor a 20
2. Clientes cuya edad esté entre 25 y 35
3. Productos de categoría 'Ropa' o 'Hogar'
4. Clientes cuyo nombre empiece con 'M'
5. Productos que NO sean de 'Electrónica' y cuesten menos de 100
6. Clientes sin email registrado
7. Clientes de Madrid mayores de 30 ordenados por edad

## 🔗 Recursos
- [WHERE - PostgreSQL Docs](https://www.postgresql.org/docs/current/sql-select.html#SQL-WHERE)