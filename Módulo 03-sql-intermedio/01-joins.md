# 01 - JOINs

## 🎯 Objetivos

- Entender por qué necesitamos JOINs
- Dominar INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN y CROSS JOIN
- Saber cuándo usar cada uno

## 📚 ¿Por qué JOINs?

En el módulo anterior solo consultábamos una tabla. Pero los datos reales están **repartidos en varias tablas** relacionadas.

Ejemplo: si quieres saber **qué cliente hizo cada pedido**, necesitas combinar `pedidos` con `clientes`.

## 🧠 Idea visual

```
CLIENTES              PEDIDOS
┌────┬────────┐      ┌────┬────────────┬─────────────┐
│ id │ nombre │      │ id │ cliente_id │ producto_id │
├────┼────────┤      ├────┼────────────┼─────────────┤
│ 1  │ Ana    │◄─────│ 1  │ 1          │ 1           │
│ 2  │ Luis   │◄─────│ 2  │ 1          │ 2           │
│ 3  │ Marta  │      │ 3  │ 2          │ 3           │
└────┴────────┘      └────┴────────────┴─────────────┘

JOIN = "pegar" las filas donde clientes.id = pedidos.cliente_id
```

## 💻 INNER JOIN

Devuelve solo las filas que **coinciden en ambas tablas**.

```sql
SELECT c.nombre, p.id AS pedido_id, p.fecha
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;
```

**Resultado:** solo los clientes que tienen pedidos.

> 💡 `INNER JOIN` es lo mismo que escribir solo `JOIN`.

### Alias de tabla

```sql
SELECT c.nombre, p.fecha
FROM clientes AS c
JOIN pedidos AS p ON c.id = p.cliente_id;
```

Los alias (`c`, `p`) hacen la consulta más corta y legible.

## 💻 LEFT JOIN (LEFT OUTER JOIN)

Devuelve **todas** las filas de la tabla izquierda, y las coincidencias de la derecha. Si no hay coincidencia, pone `NULL`.

```sql
SELECT c.nombre, p.id AS pedido_id
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

**Resultado:** todos los clientes, incluso los que **no** han hecho pedidos (aparecen con `NULL`).

> 🎯 **Caso de uso típico:** "¿Qué clientes NO han comprado nada?"

```sql
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL;
```

## 💻 RIGHT JOIN (RIGHT OUTER JOIN)

Igual que LEFT pero al revés: todas las filas de la tabla derecha.

```sql
SELECT c.nombre, p.id AS pedido_id
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;
```

**Resultado:** todos los pedidos, incluso si su cliente no existiera (no aplica aquí porque hay FK).

> 💡 En la práctica, `RIGHT JOIN` se usa poco: casi siempre se puede reescribir como `LEFT JOIN` cambiando el orden de las tablas.

## 💻 FULL JOIN (FULL OUTER JOIN)

Devuelve **todas** las filas de ambas tablas, coincidan o no.

```sql
SELECT c.nombre, p.id AS pedido_id
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id;
```

> ⚠️ MySQL no soporta `FULL OUTER JOIN` directamente. Se simula con `UNION` de un `LEFT` y un `RIGHT`.

## 💻 CROSS JOIN

Producto cartesiano: **cada fila de A con cada fila de B**.

```sql
SELECT c.nombre, pr.nombre AS producto
FROM clientes c
CROSS JOIN productos pr;
```

**Resultado:** 10 clientes × 12 productos = **120 filas**.

> ⚠️ Cuidado: si las tablas son grandes, explota. Se usa para generar combinaciones (ej: calendarios, tallas × colores).

## 🔗 JOIN con 3 o más tablas

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

**Traducción:** "Quién compró qué y cuándo"

## 📊 Comparativa rápida

| JOIN | Devuelve |
|------|----------|
| INNER | Solo coincidencias |
| LEFT | Todo de la izquierda + coincidencias |
| RIGHT | Todo de la derecha + coincidencias |
| FULL | Todo de ambas |
| CROSS | Producto cartesiano |

## 🎨 Buenas prácticas

- ✅ Usa alias cortos y claros (`c`, `p`, `pr`)
- ✅ Califica las columnas con su alias (`c.nombre`, no `nombre`)
- ✅ Indenta el `ON` debajo del `JOIN`
- ❌ No olvides el `ON` (sin él, es un CROSS JOIN accidental)
- ❌ Evita `SELECT *` cuando hay JOINs: columnas repetidas confunden

## ⚠️ Errores comunes

- Olvidar la condición `ON` → producto cartesiano
- Confundir `ON` con `WHERE` (en INNER son equivalentes, en OUTER no)
- Usar `RIGHT JOIN` cuando un `LEFT JOIN` con el orden invertido es más claro
- No usar alias y luego referirse a columnas ambiguas

## ✅ Ejercicios

1. Muestra el nombre del cliente y la fecha de cada pedido (INNER JOIN)
2. Lista todos los clientes, incluso los que no han hecho pedidos (LEFT JOIN)
3. Muestra qué cliente compró qué producto (JOIN de 3 tablas)
4. Encuentra los clientes que **nunca** han hecho un pedido
5. ¿Qué productos nunca se han vendido? (usa `LEFT JOIN` desde productos)

## 🔗 Recursos

- [JOINs visuales](https://joins.spathon.com/)
- [PostgreSQL JOIN](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)