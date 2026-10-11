# 01 - SELECT

## 🎯 Objetivos
- Consultar todas las columnas de una tabla
- Seleccionar columnas específicas
- Usar alias y valores calculados

## 📚 ¿Qué es SELECT?
Es la sentencia para **leer datos** de una o varias tablas. Es la más usada en SQL.

## 💻 Sintaxis básica

```sql
SELECT columnas
FROM tabla;
```

### Ejemplo 1: Todas las columnas
```sql
SELECT * FROM clientes;
```
> ⚠️ `*` trae todo. Úsalo solo para explorar, no en producción.

### Ejemplo 2: Columnas específicas
```sql
SELECT nombre, email FROM clientes;
```
**Ventaja:** menos datos transferidos, más rápido.

### Ejemplo 3: Alias con AS
```sql
SELECT 
    nombre AS cliente,
    ciudad AS ubicacion
FROM clientes;
```

### Ejemplo 4: Columnas calculadas
```sql
SELECT 
    nombre,
    precio,
    precio * 1.21 AS precio_con_iva
FROM productos;
```

### Ejemplo 5: Valores únicos con DISTINCT
```sql
SELECT DISTINCT ciudad FROM clientes;
```
Devuelve cada ciudad **una sola vez**.

### Ejemplo 6: Concatenar texto
```sql
-- SQLite / PostgreSQL / Oracle
SELECT nombre || ' (' || ciudad || ')' AS info FROM clientes;

-- MySQL / SQL Server
SELECT CONCAT(nombre, ' (', ciudad, ')') AS info FROM clientes;
```

### Ejemplo 7: Contar filas
```sql
SELECT COUNT(*) AS total_clientes FROM clientes;
```

## 🎨 Buenas prácticas
- ✅ Escribe SQL en MAYÚSCULAS las palabras clave (`SELECT`, `FROM`)
- ✅ Usa alias descriptivos
- ✅ Indenta consultas largas
- ❌ Evita `SELECT *` en código de producción
- ❌ No uses alias con espacios sin comillas (`AS "mi alias"`)

## ⚠️ Errores comunes
- Olvidar el `FROM`
- Confundir `AS` (alias) con `=` (comparación)
- Usar `*` y luego quejarse del rendimiento

## ✅ Ejercicios
1. Muestra todos los productos
2. Muestra solo `nombre` y `precio` de productos
3. Muestra las ciudades únicas de clientes
4. Muestra el nombre y la edad + 1 de cada cliente (alias: `edad_futura`)
5. Cuenta cuántos productos hay en total

## 🔗 Recursos
- [SELECT - PostgreSQL Docs](https://www.postgresql.org/docs/current/sql-select.html)