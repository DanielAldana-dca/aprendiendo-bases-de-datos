# 📋 SQL Cheat Sheet

Referencia rápida de los comandos SQL más usados.

## 🔍 SELECT

```sql
-- Básico
SELECT col1, col2 FROM tabla;
SELECT * FROM tabla;
SELECT DISTINCT col FROM tabla;

-- Con alias
SELECT col AS nombre FROM tabla;

-- Con cálculos
SELECT precio * 1.21 AS precio_iva FROM productos;

-- Con funciones
SELECT COUNT(*), SUM(precio), AVG(precio), MIN(precio), MAX(precio) FROM productos;
```

## 🔎 WHERE

```sql
-- Comparación
WHERE edad > 18
WHERE ciudad = 'Madrid'
WHERE precio BETWEEN 10 AND 100
WHERE ciudad IN ('Madrid', 'Barcelona')
WHERE nombre LIKE 'A%'
WHERE email IS NULL
WHERE email IS NOT NULL

-- Lógicos
WHERE a = 1 AND b = 2
WHERE a = 1 OR b = 2
WHERE NOT activo
WHERE (a = 1 OR b = 2) AND c = 3
```

## 📊 ORDER BY y LIMIT

```sql
ORDER BY edad ASC
ORDER BY edad DESC
ORDER BY ciudad ASC, edad DESC
ORDER BY 1
LIMIT 10
LIMIT 10 OFFSET 20
ORDER BY fecha DESC NULLS LAST
```

## 🔗 JOINs

```sql
-- INNER
SELECT * FROM a INNER JOIN b ON a.id = b.a_id;
SELECT * FROM a JOIN b ON a.id = b.a_id;

-- LEFT
SELECT * FROM a LEFT JOIN b ON a.id = b.a_id;
SELECT * FROM a LEFT JOIN b ON a.id = b.a_id WHERE b.id IS NULL;

-- RIGHT
SELECT * FROM a RIGHT JOIN b ON a.id = b.a_id;

-- FULL
SELECT * FROM a FULL OUTER JOIN b ON a.id = b.a_id;

-- CROSS
SELECT * FROM a CROSS JOIN b;

-- Múltiples JOINs
SELECT * 
FROM a
JOIN b ON a.id = b.a_id
JOIN c ON b.id = c.b_id;
```

## 📈 GROUP BY y HAVING

```sql
SELECT categoria, COUNT(*), AVG(precio)
FROM productos
GROUP BY categoria;

SELECT categoria, COUNT(*)
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 5;

SELECT categoria, AVG(precio) AS promedio
FROM productos
WHERE activo = TRUE
GROUP BY categoria
HAVING AVG(precio) > 100
ORDER BY promedio DESC;
```

## 🔄 INSERT / UPDATE / DELETE

```sql
-- INSERT
INSERT INTO tabla (col1, col2) VALUES (val1, val2);
INSERT INTO tabla VALUES (val1, val2, val3);
INSERT INTO tabla (col1, col2) VALUES (v1, v2), (v3, v4);
INSERT INTO tabla SELECT col1, col2 FROM otra_tabla;

-- UPDATE
UPDATE tabla SET col = valor WHERE id = 1;
UPDATE tabla SET col1 = v1, col2 = v2 WHERE id = 1;
UPDATE tabla SET precio = precio * 1.10 WHERE categoria = 'Ropa';

-- DELETE
DELETE FROM tabla WHERE id = 1;
DELETE FROM tabla WHERE fecha < '2024-01-01';
TRUNCATE TABLE tabla;
```

## 🎯 CASE y COALESCE

```sql
-- CASE
SELECT 
    nombre,
    CASE 
        WHEN precio < 50 THEN 'Barato'
        WHEN precio < 200 THEN 'Medio'
        ELSE 'Caro'
    END AS rango
FROM productos;

-- CASE simple
SELECT 
    CASE categoria 
        WHEN 'Electrónica' THEN 'Tech'
        ELSE 'Otros'
    END
FROM productos;

-- COALESCE
SELECT COALESCE(email, 'sin-email') FROM clientes;
SELECT COALESCE(telefono, movil, 'sin contacto') FROM usuarios;

-- NULLIF
SELECT a / NULLIF(b, 0) FROM tabla;
```

## 🪟 Window Functions

```sql
-- Row number
ROW_NUMBER() OVER (ORDER BY precio DESC)
ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC)

-- Rank
RANK() OVER (ORDER BY precio DESC)
DENSE_RANK() OVER (ORDER BY precio DESC)

-- LAG/LEAD
LAG(precio) OVER (ORDER BY fecha)
LEAD(precio) OVER (ORDER BY fecha)
LAG(precio, 1, 0) OVER (ORDER BY fecha)  -- con default

-- SUM acumulado
SUM(cantidad) OVER (ORDER BY fecha)

-- Media móvil
AVG(precio) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)

-- Porcentaje del total
100.0 * precio / SUM(precio) OVER ()
```

## 🎨 CTEs

```sql
-- Básica
WITH ventas AS (
    SELECT cliente_id, SUM(total) AS total
    FROM pedidos
    GROUP BY cliente_id
)
SELECT * FROM ventas WHERE total > 500;

-- Múltiples
WITH 
ventas AS (SELECT ...),
ranking AS (SELECT ...)
SELECT * FROM ranking WHERE rn = 1;

-- Recursiva
WITH RECURSIVE numeros(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 10
)
SELECT * FROM numeros;
```

## 🔍 Subconsultas

```sql
-- En WHERE
SELECT * FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

-- En WHERE con IN
SELECT * FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);

-- En WHERE con EXISTS
SELECT * FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);

-- En WHERE con NOT EXISTS
SELECT * FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);

-- En FROM
SELECT * FROM (
    SELECT categoria, AVG(precio) AS prom
    FROM productos GROUP BY categoria
) t WHERE prom > 100;

-- En SELECT (escalar)
SELECT nombre, (SELECT AVG(precio) FROM productos) AS prom FROM productos;
```

## 🏗️ DDL

```sql
-- CREATE TABLE
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    edad INTEGER CHECK (edad >= 0),
    ciudad VARCHAR(50) DEFAULT 'Madrid',
    activo BOOLEAN DEFAULT TRUE,
    fecha TIMESTAMP DEFAULT NOW()
);

-- FK
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ALTER
ALTER TABLE usuarios ADD COLUMN telefono VARCHAR(20);
ALTER TABLE usuarios DROP COLUMN telefono;
ALTER TABLE usuarios ALTER COLUMN nombre TYPE VARCHAR(200);

-- Índices
CREATE INDEX idx_usuarios_ciudad ON usuarios(ciudad);
CREATE UNIQUE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_compuesto ON tabla(col1, col2);

-- DROP
DROP TABLE usuarios;
DROP TABLE IF EXISTS usuarios CASCADE;
```

## 💾 Transacciones

```sql
BEGIN;
UPDATE cuentas SET saldo = saldo - 100 WHERE id = 1;
UPDATE cuentas SET saldo = saldo + 100 WHERE id = 2;
COMMIT;  -- o ROLLBACK;

-- Savepoint
BEGIN;
INSERT INTO a VALUES (1);
SAVEPOINT sp1;
INSERT INTO b VALUES (2);
ROLLBACK TO sp1;
COMMIT;
```

## 👁️ Vistas

```sql
-- Crear
CREATE VIEW ventas_resumen AS
SELECT cliente_id, SUM(total) AS total
FROM pedidos GROUP BY cliente_id;

-- Materializada
CREATE MATERIALIZED VIEW mv_ventas AS
SELECT ... FROM ...;

REFRESH MATERIALIZED VIEW mv_ventas;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ventas;

-- Eliminar
DROP VIEW ventas_resumen;
```

## 🔢 Funciones útiles

```sql
-- Texto
UPPER('hola')                -- HOLA
LOWER('HOLA')                -- hola
LENGTH('hola')               -- 4
TRIM('  hola  ')             -- 'hola'
SUBSTRING('hola', 1, 2)      -- 'ho'
CONCAT('a', 'b')             -- 'ab'
REPLACE('hola', 'o', 'a')    -- 'hala'
SPLIT_PART('a,b,c', ',', 1)  -- 'a'

-- Fecha
NOW()
CURRENT_DATE
CURRENT_TIMESTAMP
EXTRACT(YEAR FROM fecha)
EXTRACT(MONTH FROM fecha)
DATE_TRUNC('month', fecha)
fecha + INTERVAL '1 day'
fecha - INTERVAL '1 month'
AGE(fecha1, fecha2)

-- Números
ROUND(3.14159, 2)            -- 3.14
CEIL(3.1)                    -- 4
FLOOR(3.9)                   -- 3
ABS(-5)                      -- 5
POWER(2, 10)                 -- 1024
MOD(10, 3)                   -- 1

-- Conversión
CAST('123' AS INTEGER)
'123'::INTEGER
TO_CHAR(fecha, 'YYYY-MM-DD')
TO_DATE('2024-01-01', 'YYYY-MM-DD')
```

## 🎯 Patrones comunes

```sql
-- Top N por grupo
WITH ranking AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS rn
    FROM productos
)
SELECT * FROM ranking WHERE rn <= 3;

-- Eliminar duplicados
DELETE FROM tabla a
USING tabla b
WHERE a.id > b.id AND a.email = b.email;

-- Encontrar huérfanos
SELECT * FROM hijos h
LEFT JOIN padres p ON h.padre_id = p.id
WHERE p.id IS NULL;

-- Actualizar con JOIN
UPDATE pedidos p
SET total = sub.total
FROM (SELECT pedido_id, SUM(subtotal) AS total FROM lineas GROUP BY pedido_id) sub
WHERE p.id = sub.pedido_id;

-- Insertar si no existe (PostgreSQL)
INSERT INTO usuarios (email, nombre) VALUES ('a@x.com', 'Ana')
ON CONFLICT (email) DO NOTHING;

-- Upsert
INSERT INTO usuarios (id, email, nombre) VALUES (1, 'a@x.com', 'Ana')
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;
```

## 🐛 Debug

```sql
-- Ver plan
EXPLAIN SELECT ...;
EXPLAIN ANALYZE SELECT ...;

-- Ver índices (PostgreSQL)
SELECT * FROM pg_indexes WHERE tablename = 'usuarios';

-- Ver tamaño (PostgreSQL)
SELECT pg_size_pretty(pg_total_relation_size('usuarios'));

-- Ver conexiones activas
SELECT * FROM pg_stat_activity;
```

## 🎨 Buenas prácticas

- ✅ Palabras clave en MAYÚSCULAS
- ✅ Un campo por línea en SELECT largos
- ✅ Alias descriptivos
- ✅ Índices en FK
- ✅ EXPLAIN antes de optimizar
- ❌ Evitar `SELECT *` en producción
- ❌ No usar `NOT IN` con NULL
- ❌ No concatenar strings en SQL (usa parámetros)