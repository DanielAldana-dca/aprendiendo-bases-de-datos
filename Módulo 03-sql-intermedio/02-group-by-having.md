# 02 - GROUP BY y HAVING

## 🎯 Objetivos

- Agrupar filas por valores comunes
- Aplicar funciones agregadas a cada grupo
- Filtrar grupos con HAVING
- Entender la diferencia entre WHERE y HAVING

## 📚 ¿Qué es GROUP BY?

Agrupa filas que comparten un valor y permite aplicar funciones agregadas a cada grupo.

**Idea:** "dame un resultado por cada categoría / ciudad / cliente".

## 💻 Sintaxis

```sql
SELECT columna, FUNCION_AGREGADA(columna)
FROM tabla
WHERE condicion
GROUP BY columna
HAVING condicion_sobre_grupo
ORDER BY columna;
```

**Orden lógico:** `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY`

## 💻 Ejemplos

### Ejemplo 1: contar pedidos por cliente

```sql
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM pedidos
GROUP BY cliente_id;
```

**Resultado:** una fila por cliente con su número de pedidos.

### Ejemplo 2: contar clientes por ciudad

```sql
SELECT ciudad, COUNT(*) AS total_clientes
FROM clientes
GROUP BY ciudad
ORDER BY total_clientes DESC;
```

### Ejemplo 3: precio promedio por categoría

```sql
SELECT categoria, AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria;
```

### Ejemplo 4: stock total por categoría

```sql
SELECT categoria, SUM(stock) AS stock_total
FROM productos
GROUP BY categoria;
```

### Ejemplo 5: agrupar por varias columnas

```sql
SELECT categoria, stock > 20 AS abundante, COUNT(*)
FROM productos
GROUP BY categoria, stock > 20;
```

## 🔍 HAVING

`WHERE` filtra **filas antes** de agrupar.  
`HAVING` filtra **grupos después** de agrupar.

### Ejemplo: clientes con más de 1 pedido

```sql
SELECT cliente_id, COUNT(*) AS total
FROM pedidos
GROUP BY cliente_id
HAVING COUNT(*) > 1;
```

> ❌ `WHERE COUNT(*) > 1` daría error: las funciones agregadas no van en WHERE.

### Combinando WHERE y HAVING

```sql
SELECT categoria, AVG(precio) AS precio_promedio
FROM productos
WHERE stock > 10
GROUP BY categoria
HAVING AVG(precio) > 50;
```

**Traducción:** "De los productos con stock > 10, muéstrame las categorías cuyo precio promedio supera 50".

## ⚠️ Regla de oro

> **Toda columna en SELECT debe estar en GROUP BY o dentro de una función agregada.**

❌ Mal:
```sql
SELECT categoria, nombre, COUNT(*)
FROM productos
GROUP BY categoria;
-- nombre no está en GROUP BY ni agregado
```

✅ Bien:
```sql
SELECT categoria, COUNT(*)
FROM productos
GROUP BY categoria;
```

## 📊 WHERE vs HAVING

| | WHERE | HAVING |
|--|-------|--------|
| Cuándo | Antes de agrupar | Después de agrupar |
| Filtra | Filas | Grupos |
| Admite agregadas | ❌ | ✅ |
| Ejemplo | `WHERE precio > 100` | `HAVING COUNT(*) > 2` |

## 💡 Patrones útiles

### Top N por grupo (con window functions - módulo 04)
```sql
-- Solo conceptual aquí
```

### Contar distintos
```sql
SELECT categoria, COUNT(DISTINCT nombre) AS productos_unicos
FROM productos
GROUP BY categoria;
```

### Agrupar por fecha (por mes)
```sql
-- PostgreSQL
SELECT DATE_TRUNC('month', fecha) AS mes, COUNT(*)
FROM pedidos
GROUP BY mes
ORDER BY mes;
```

## ⚠️ Errores comunes

- Poner funciones agregadas en `WHERE` en lugar de `HAVING`
- Olvidar columnas en `GROUP BY`
- Confundir `COUNT(*)` con `COUNT(columna)` (el segundo ignora NULL)
- No ordenar el resultado (los grupos no vienen ordenados)

## ✅ Ejercicios

1. ¿Cuántos clientes hay por ciudad?
2. ¿Cuántos productos hay por categoría?
3. ¿Cuál es el precio promedio por categoría?
4. ¿Cuántos pedidos ha hecho cada cliente? (ordenado de mayor a menor)
5. ¿Qué categorías tienen más de 3 productos?
6. ¿Cuántas ventas (suma de cantidad) ha habido por producto? Top 5
7. Ciudades con más de 1 cliente y edad promedio mayor a 28

## 🔗 Recursos

- [GROUP BY - PostgreSQL](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)