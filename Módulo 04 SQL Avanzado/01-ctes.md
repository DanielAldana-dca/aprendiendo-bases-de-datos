# 01 - CTEs (Common Table Expressions)

## 🎯 Objetivos

- Escribir consultas legibles con `WITH`
- Encadenar varias CTEs
- Usar CTEs recursivas
- Saber cuándo usar CTE vs subconsulta

## 📚 ¿Qué es una CTE?

Una **CTE** es una tabla temporal con nombre que existe solo durante la ejecución de una consulta. Se define con `WITH`.

**Ventaja:** las consultas se vuelven **legibles** como capítulos de un libro.

## 💻 Sintaxis básica

```sql
WITH nombre_cte AS (
    SELECT ...
)
SELECT * FROM nombre_cte;
```

## 💻 Ejemplo simple

En lugar de esto:
```sql
SELECT categoria, promedio
FROM (
    SELECT categoria, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria
) AS resumen
WHERE promedio > 100;
```

Escribimos esto:
```sql
WITH resumen AS (
    SELECT categoria, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria
)
SELECT categoria, promedio
FROM resumen
WHERE promedio > 100;
```

✅ Mucho más claro.

## 💻 Varias CTEs encadenadas

```sql
WITH 
ventas_por_cliente AS (
    SELECT 
        p.cliente_id,
        SUM(p.cantidad * pr.precio) AS total
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    GROUP BY p.cliente_id
),
clientes_top AS (
    SELECT cliente_id, total
    FROM ventas_por_cliente
    WHERE total > 500
)
SELECT c.nombre, ct.total
FROM clientes_top ct
JOIN clientes c ON c.id = ct.cliente_id
ORDER BY ct.total DESC;
```

**Ventaja:** cada CTE es un paso lógico independiente y testeable.

## 💻 CTE + JOIN + GROUP BY + Window Functions

```sql
WITH pedidos_detalle AS (
    SELECT 
        p.id AS pedido_id,
        c.nombre AS cliente,
        pr.nombre AS producto,
        pr.categoria,
        p.cantidad,
        pr.precio,
        p.cantidad * pr.precio AS subtotal,
        p.fecha
    FROM pedidos p
    JOIN clientes c   ON p.cliente_id = c.id
    JOIN productos pr ON p.producto_id = pr.id
)
SELECT 
    categoria,
    SUM(subtotal) AS ingresos,
    COUNT(*) AS num_pedidos,
    ROUND(AVG(subtotal), 2) AS ticket_promedio
FROM pedidos_detalle
GROUP BY categoria
ORDER BY ingresos DESC;
```

## 🔁 CTEs recursivas

Una CTE se puede llamar a sí misma. Útil para jerarquías (organigramas, categorías anidadas, series numéricas).

### Sintaxis

```sql
WITH RECURSIVE nombre AS (
    -- Caso base
    SELECT ...
    UNION ALL
    -- Caso recursivo (se refiere a nombre)
    SELECT ... FROM nombre WHERE ...
)
SELECT * FROM nombre;
```

### Ejemplo 1: contar del 1 al 10

```sql
WITH RECURSIVE numeros(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 10
)
SELECT * FROM numeros;
```

### Ejemplo 2: fechas de un mes

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

### Ejemplo 3: jerarquía de empleados

```sql
-- Tabla hipotética: empleados(id, nombre, jefe_id)
WITH RECURSIVE organigrama AS (
    -- Nivel raíz (el CEO no tiene jefe)
    SELECT id, nombre, jefe_id, 1 AS nivel
    FROM empleados
    WHERE jefe_id IS NULL
    
    UNION ALL
    
    -- Subordinados
    SELECT e.id, e.nombre, e.jefe_id, o.nivel + 1
    FROM empleados e
    JOIN organigrama o ON e.jefe_id = o.id
)
SELECT * FROM organigrama ORDER BY nivel, nombre;
```

## 🆚 CTE vs Subconsulta

| Situación | Mejor |
|-----------|-------|
| Consulta simple, un solo uso | Subconsulta |
| Lógica compleja o reutilizada | CTE |
| Necesitas recursión | CTE recursiva |
| Consulta encadenada en pasos | CTE |

> 💡 **Regla práctica:** si tu subconsulta tiene más de 5 líneas o la usas dos veces, conviértela en CTE.

## 🎨 Buenas prácticas

- ✅ Nombra las CTEs con verbos o sustantivos claros (`ventas_por_cliente`, no `cte1`)
- ✅ Una CTE = un paso lógico
- ✅ Indenta el contenido de cada CTE
- ❌ No abuses: 10 CTEs encadenadas son difíciles de leer
- ❌ No uses CTE para algo trivial que cabría en una línea

## ⚠️ Errores comunes

- Olvidar que las CTEs solo existen en esa consulta
- No poner `RECURSIVE` en CTEs recursivas
- CTE recursiva sin caso base → loop infinito
- Confundir CTE con vista (la CTE no se guarda)

## ✅ Ejercicios

1. Crea una CTE con los clientes de Madrid y luego filtra los mayores de 25
2. Encadena dos CTEs: una con las ventas por cliente, otra con los top 3
3. Genera los números del 1 al 100 con una CTE recursiva
4. Muestra todas las fechas entre 2024-01-01 y 2024-01-31
5. Con una CTE, muestra los productos con precio superior al promedio de su categoría
6. Ranking de clientes por gasto total usando CTE + JOIN
7. Reporte mensual de ventas con CTE

## 🔗 Recursos

- [WITH queries - PostgreSQL](https://www.postgresql.org/docs/current/queries-with.html)