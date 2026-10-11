# 04 - Subconsultas

## 🎯 Objetivos

- Escribir consultas dentro de otras consultas
- Usar subconsultas en WHERE, FROM y SELECT
- Conocer los operadores IN, EXISTS, ANY, ALL
- Entender cuándo conviene una subconsulta vs un JOIN

## 📚 ¿Qué es una subconsulta?

Una consulta anidada dentro de otra. La interna se ejecuta primero (conceptualmente) y su resultado alimenta a la externa.

## 💻 Subconsultas en WHERE

### Con operador de comparación

```sql
-- Productos más caros que el promedio
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);
```

### Con IN

```sql
-- Clientes que han hecho al menos un pedido
SELECT nombre
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```

### Con NOT IN

```sql
-- Clientes que NUNCA han hecho un pedido
SELECT nombre
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL);
```

> ⚠️ **Cuidado:** si la subconsulta devuelve algún `NULL`, `NOT IN` falla silenciosamente (devuelve vacío). Usa `WHERE ... IS NOT NULL` o mejor, `NOT EXISTS`.

### Con EXISTS / NOT EXISTS

```sql
-- Clientes con al menos un pedido
SELECT nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);

-- Clientes sin pedidos
SELECT nombre
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id
);
```

> ✅ `EXISTS` suele ser más eficiente que `IN` con subconsultas grandes.

### Con ANY / ALL

```sql
-- Productos más caros que ALGUNO de la categoría 'Ropa'
SELECT nombre, precio FROM productos
WHERE precio > ANY (SELECT precio FROM productos WHERE categoria = 'Ropa');

-- Productos más caros que TODOS los de 'Ropa'
SELECT nombre, precio FROM productos
WHERE precio > ALL (SELECT precio FROM productos WHERE categoria = 'Ropa');
```

## 💻 Subconsultas en FROM (derived tables)

Se usan como si fueran tablas temporales. **Obligatorio poner alias.**

```sql
SELECT categoria, promedio
FROM (
    SELECT categoria, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria
) AS resumen
WHERE promedio > 100;
```

**Traducción:** "Del promedio por categoría, muéstrame las que superan 100".

## 💻 Subconsultas en SELECT (escalares)

Deben devolver **una sola fila y una sola columna**.

```sql
SELECT 
    nombre,
    precio,
    (SELECT AVG(precio) FROM productos) AS precio_promedio,
    precio - (SELECT AVG(precio) FROM productos) AS diferencia
FROM productos;
```

## 🔄 Subconsulta vs JOIN

Ambos pueden resolver lo mismo. Reglas prácticas:

| Situación | Mejor opción |
|-----------|--------------|
| Necesitas columnas de ambas tablas | JOIN |
| Solo filtras por existencia | EXISTS / IN |
| Necesitas agregados por grupo | Subconsulta en FROM o JOIN + GROUP BY |
| Consulta simple y clara | La que sea más legible |

### Ejemplo: mismo resultado, dos formas

**Con JOIN:**
```sql
SELECT DISTINCT c.nombre
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id;
```

**Con subconsulta:**
```sql
SELECT nombre
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```

Ambas devuelven los clientes con pedidos. La subconsulta suele ser más legible.

## 🎯 Patrones útiles

### Producto más caro por categoría

```sql
SELECT nombre, categoria, precio
FROM productos p1
WHERE precio = (
    SELECT MAX(precio)
    FROM productos p2
    WHERE p2.categoria = p1.categoria
);
```

> 💡 Esto es una **subconsulta correlacionada**: la interna depende de la externa (`p1.categoria`).

### Segundo más caro

```sql
SELECT nombre, precio FROM productos
WHERE precio = (
    SELECT MAX(precio) FROM productos
    WHERE precio < (SELECT MAX(precio) FROM productos)
);
```

## ⚠️ Errores comunes

- Olvidar alias en subconsultas dentro de FROM
- Usar `NOT IN` con posibilidad de NULL
- Subconsultas escalares que devuelven varias filas (error)
- Anidar demasiado cuando un JOIN sería más claro
- No indentar: las subconsultas sin formato son ilegibles

## ✅ Ejercicios

1. Productos más caros que el promedio general
2. Clientes que han hecho al menos un pedido (con IN)
3. Clientes que NO han hecho pedidos (con NOT EXISTS)
4. Productos cuyo precio supera el promedio de su categoría
5. Categorías con precio promedio mayor a 100 (subconsulta en FROM)
6. El pedido más reciente de cada cliente
7. Clientes que han comprado algo de la categoría 'Electrónica'

## 🔗 Recursos

- [Subqueries - PostgreSQL](https://www.postgresql.org/docs/current/functions-subquery.html)