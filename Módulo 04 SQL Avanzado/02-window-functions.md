# 02 - Window Functions

## 🎯 Objetivos

- Entender qué son las funciones de ventana
- Usar ROW_NUMBER, RANK, DENSE_RANK
- Usar LAG, LEAD para comparar filas
- Calcular totales acumulados y promedios móviles
- Usar PARTITION BY

## 📚 ¿Qué son?

Funciones que calculan valores **sobre un conjunto de filas relacionadas** con la fila actual, **sin colapsarlas** (a diferencia de GROUP BY).

**Idea:** "para cada fila, dame también un cálculo basado en su grupo".

## 🆚 GROUP BY vs Window Function

**GROUP BY:** 10 clientes → 3 ciudades → 3 filas.
**Window Function:** 10 clientes → 10 filas, cada una con su ciudad y el total de esa ciudad.

## 💻 Sintaxis

```sql
FUNCION() OVER (
    PARTITION BY columna
    ORDER BY columna
    ROWS BETWEEN ...
)
```

- `PARTITION BY`: divide en grupos (como GROUP BY pero sin colapsar)
- `ORDER BY`: ordena dentro de cada partición
- `ROWS`: define el marco (opcional)

## 💻 ROW_NUMBER, RANK, DENSE_RANK

### ROW_NUMBER: número único por fila
```sql
SELECT 
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) AS posicion
FROM productos;
```

### RANK: empates comparten posición, siguiente salta
```
precio:  100, 100, 90, 80
RANK:    1,   1,   3,  4
```

### DENSE_RANK: empates comparten posición, siguiente no salta
```
precio:  100, 100, 90, 80
DENSE_RANK: 1, 1, 2, 3
```

### Ejemplo comparativo

```sql
SELECT 
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) AS row_num,
    RANK()       OVER (ORDER BY precio DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY precio DESC) AS dense_rank
FROM productos
ORDER BY precio DESC;
```

## 💻 PARTITION BY

Aplica la función **por grupo** sin colapsar.

```sql
SELECT 
    nombre,
    categoria,
    precio,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS ranking_en_categoria
FROM productos;
```

**Resultado:** cada producto con su posición dentro de su categoría.

### Filtrar el top N por grupo

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
WHERE rn = 1;
```

**Traducción:** "El producto más caro de cada categoría".

> ⚠️ No puedes filtrar directamente por window functions en WHERE. Necesitas CTE o subconsulta.

## 💻 LAG y LEAD

Comparan con la fila anterior/siguiente.

```sql
SELECT 
    fecha,
    cantidad,
    LAG(cantidad)  OVER (ORDER BY fecha) AS cantidad_anterior,
    LEAD(cantidad) OVER (ORDER BY fecha) AS cantidad_siguiente,
    cantidad - LAG(cantidad) OVER (ORDER BY fecha) AS diferencia
FROM pedidos
ORDER BY fecha;
```

**Útil para:** calcular crecimiento, diferencias mes a mes, detectar cambios.

## 💻 SUM y AVG con ventana

### Total acumulado (running total)

```sql
SELECT 
    fecha,
    cantidad,
    SUM(cantidad) OVER (ORDER BY fecha) AS acumulado
FROM pedidos
ORDER BY fecha;
```

**Resultado:** cada fila muestra la suma desde el inicio hasta esa fila.

### Total por grupo (sin colapsar)

```sql
SELECT 
    nombre,
    categoria,
    precio,
    SUM(precio) OVER (PARTITION BY categoria) AS total_categoria,
    ROUND(100.0 * precio / SUM(precio) OVER (PARTITION BY categoria), 2) AS porcentaje
FROM productos;
```

**Resultado:** cada producto con el total y porcentaje de su categoría.

### Promedio móvil

```sql
SELECT 
    fecha,
    cantidad,
    AVG(cantidad) OVER (
        ORDER BY fecha 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3
FROM pedidos
ORDER BY fecha;
```

**Resultado:** promedio de las últimas 3 filas.

## 📊 Funciones más usadas

| Función | Uso |
|---------|-----|
| `ROW_NUMBER()` | Numeración única |
| `RANK()` | Ranking con saltos |
| `DENSE_RANK()` | Ranking sin saltos |
| `NTILE(n)` | Dividir en n grupos |
| `LAG(col, n)` | Valor n filas atrás |
| `LEAD(col, n)` | Valor n filas adelante |
| `FIRST_VALUE(col)` | Primer valor de la ventana |
| `LAST_VALUE(col)` | Último valor de la ventana |
| `SUM/AVG/COUNT` | Agregados con ventana |

## 🎯 Patrones profesionales

### Top N por categoría

```sql
WITH ranking AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS rn
    FROM productos
)
SELECT * FROM ranking WHERE rn <= 2;
```

### Comparar con el mes anterior

```sql
WITH ventas_mes AS (
    SELECT 
        DATE_TRUNC('month', fecha) AS mes,
        SUM(cantidad) AS unidades
    FROM pedidos
    GROUP BY mes
)
SELECT 
    mes,
    unidades,
    LAG(unidades) OVER (ORDER BY mes) AS mes_anterior,
    unidades - LAG(unidades) OVER (ORDER BY mes) AS diferencia
FROM ventas_mes
ORDER BY mes;
```

### Porcentaje del total

```sql
SELECT 
    nombre,
    precio,
    ROUND(100.0 * precio / SUM(precio) OVER (), 2) AS porcentaje
FROM productos;
```

## ⚠️ Errores comunes

- Intentar filtrar window functions en WHERE (usa CTE)
- Confundir PARTITION BY con GROUP BY
- Olvidar ORDER BY dentro de OVER cuando importa el orden
- No entender la diferencia entre RANK y DENSE_RANK

## ✅ Ejercicios

1. Numera todos los productos por precio descendente
2. Muestra el top 2 de productos más caros por categoría
3. Ranking de clientes por gasto total (usa CTE + window)
4. Para cada pedido, muestra la cantidad del pedido anterior del mismo cliente
5. Total acumulado de unidades vendidas por fecha
6. Porcentaje que representa cada producto sobre el total de su categoría
7. Ranking de ciudades por ingresos, con el porcentaje que representan

## 🔗 Recursos

- [Window Functions - PostgreSQL](https://www.postgresql.org/docs/current/tutorial-window.html)
- [Window Functions visuales](https://www.windowfunctions.com/)