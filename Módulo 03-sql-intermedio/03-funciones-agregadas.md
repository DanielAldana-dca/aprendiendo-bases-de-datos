# 03 - Funciones Agregadas

## 🎯 Objetivos

- Dominar COUNT, SUM, AVG, MIN, MAX
- Entender cómo tratan los NULL
- Combinarlas con GROUP BY

## 📚 ¿Qué son?

Funciones que **resumen** muchas filas en un solo valor.

## 📋 Las 5 clásicas

### COUNT
Cuenta filas.

```sql
-- Total de clientes
SELECT COUNT(*) FROM clientes;

-- Clientes con email no nulo
SELECT COUNT(email) FROM clientes;
-- ⚠️ COUNT(columna) ignora NULL

-- Clientes únicos por ciudad
SELECT COUNT(DISTINCT ciudad) FROM clientes;
```

### SUM
Suma valores numéricos.

```sql
-- Stock total de todos los productos
SELECT SUM(stock) FROM productos;

-- Valor total del inventario
SELECT SUM(precio * stock) AS valor_inventario FROM productos;

-- Cantidad total vendida
SELECT SUM(cantidad) FROM pedidos;
```

### AVG
Promedio.

```sql
SELECT AVG(precio) FROM productos;

SELECT ROUND(AVG(edad), 2) AS edad_promedio FROM clientes;
```

> ⚠️ `AVG` ignora NULL. Si un 30% de edades son NULL, el promedio se calcula sobre el 70% restante.

### MIN y MAX
Mínimo y máximo.

```sql
SELECT MIN(precio), MAX(precio) FROM productos;

SELECT MIN(fecha), MAX(fecha) FROM pedidos;
```

### Combinando todas

```sql
SELECT 
    COUNT(*) AS total_productos,
    MIN(precio) AS mas_barato,
    MAX(precio) AS mas_caro,
    AVG(precio) AS promedio,
    SUM(stock) AS stock_total
FROM productos;
```

## 🔗 Con GROUP BY

```sql
SELECT 
    categoria,
    COUNT(*) AS productos,
    MIN(precio) AS min_precio,
    MAX(precio) AS max_precio,
    AVG(precio) AS promedio,
    SUM(stock) AS stock_total
FROM productos
GROUP BY categoria
ORDER BY promedio DESC;
```

**Resultado:** una fila por categoría con todas las métricas.

## 🧮 Cálculos avanzados

### Porcentaje del total
```sql
SELECT 
    categoria,
    SUM(stock) AS stock_categoria,
    ROUND(100.0 * SUM(stock) / (SELECT SUM(stock) FROM productos), 2) AS porcentaje
FROM productos
GROUP BY categoria;
```

### Diferencia respecto al promedio
```sql
SELECT 
    nombre,
    precio,
    precio - (SELECT AVG(precio) FROM productos) AS diferencia
FROM productos
ORDER BY diferencia DESC;
```

## ⚠️ Cómo tratan los NULL

| Función | Comportamiento con NULL |
|---------|------------------------|
| COUNT(*) | Cuenta TODO, incluye NULL |
| COUNT(col) | Ignora NULL |
| SUM | Ignora NULL (suma de ceros = NULL si todo NULL) |
| AVG | Ignora NULL (divide entre no-NULL) |
| MIN/MAX | Ignoran NULL |

### Ejemplo práctico con `clientes.email`

```sql
SELECT 
    COUNT(*) AS total_clientes,        -- 10
    COUNT(email) AS con_email,          -- 9
    COUNT(*) - COUNT(email) AS sin_email -- 1
FROM clientes;
```

## 🎯 Funciones útiles adicionales

```sql
-- Redondear
SELECT ROUND(AVG(precio), 2) FROM productos;

-- Valor absoluto
SELECT ABS(-5);

-- Potencia
SELECT POWER(2, 10);

-- Módulo
SELECT 10 % 3;
```

## ⚠️ Errores comunes

- Confundir `COUNT(*)` con `COUNT(columna)` cuando hay NULL
- Usar `SUM` sobre texto (error)
- Esperar que `AVG` cuente NULL como 0
- Aplicar agregadas sin `GROUP BY` cuando quieres por grupos

## ✅ Ejercicios

1. ¿Cuántos productos hay en total?
2. ¿Cuál es el precio promedio de todos los productos?
3. ¿Cuál es el producto más caro y el más barato?
4. ¿Cuál es la cantidad total de unidades vendidas?
5. Por cada categoría: cuántos productos, precio promedio y stock total
6. ¿Cuántos clientes tienen email registrado? ¿Y cuántos no?
7. Valor total del inventario (`SUM(precio * stock)`)
8. Por ciudad: número de clientes y edad promedio (ordenado por edad descendente)

## 🔗 Recursos

- [Funciones agregadas - PostgreSQL](https://www.postgresql.org/docs/current/functions-aggregate.html)