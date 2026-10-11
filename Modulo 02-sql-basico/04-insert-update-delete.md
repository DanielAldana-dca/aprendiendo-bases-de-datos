# 04 - INSERT, UPDATE y DELETE

## 🎯 Objetivos
- Insertar registros nuevos
- Actualizar registros existentes
- Borrar registros con seguridad

## 📚 INSERT - Crear datos

### Sintaxis básica
```sql
INSERT INTO tabla (col1, col2, ...) VALUES (val1, val2, ...);
```

### Ejemplo 1: Insertar un cliente
```sql
INSERT INTO clientes (id, nombre, email, ciudad, edad, fecha_registro)
VALUES (11, 'Laura Gil', 'laura@mail.com', 'Madrid', 27, '2024-04-01');
```

### Ejemplo 2: Insertar sin especificar todas las columnas
```sql
INSERT INTO clientes (id, nombre, ciudad, edad)
VALUES (12, 'Raúl Vega', 'Zaragoza', 32);
-- Las columnas omitidas quedan como NULL
```

### Ejemplo 3: Varias filas de una vez
```sql
INSERT INTO productos (id, nombre, categoria, precio, stock) VALUES
(13, 'Webcam HD', 'Electrónica', 45.00, 50),
(14, 'Auriculares BT', 'Electrónica', 79.99, 60),
(15, 'Alfombra', 'Hogar', 35.00, 20);
```

### Ejemplo 4: Insertar desde otra tabla
```sql
INSERT INTO clientes_vip (id, nombre)
SELECT id, nombre FROM clientes WHERE edad > 35;
```

## 📚 UPDATE - Modificar datos

### Sintaxis
```sql
UPDATE tabla
SET columna1 = valor1, columna2 = valor2
WHERE condicion;
```

> ⚠️ **NUNCA olvides el WHERE**. Sin él, actualizas TODA la tabla.

### Ejemplo 1: Un solo campo
```sql
UPDATE productos
SET precio = 1100.00
WHERE id = 1;
```

### Ejemplo 2: Varios campos
```sql
UPDATE clientes
SET ciudad = 'Málaga', edad = 29
WHERE id = 8;
```

### Ejemplo 3: Actualizar con cálculo
```sql
-- Subir 10% el precio a todos los productos de Electrónica
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Electrónica';
```

### Ejemplo 4: Actualizar NULL
```sql
UPDATE clientes
SET email = 'pedro@mail.com'
WHERE id = 8 AND email IS NULL;
```

### ⚠️ Patrón seguro: UPDATE con SELECT previo
**Siempre haz esto antes:**
```sql
-- 1. Primero verifica qué filas vas a afectar
SELECT * FROM productos WHERE categoria = 'Electrónica';

-- 2. Luego actualiza
UPDATE productos SET precio = precio * 1.10 WHERE categoria = 'Electrónica';
```

## 📚 DELETE - Borrar datos

### Sintaxis
```sql
DELETE FROM tabla WHERE condicion;
```

> ⚠️ Sin WHERE borras **todo**. En producción, respira antes de ejecutar.

### Ejemplo 1: Borrar uno
```sql
DELETE FROM clientes WHERE id = 12;
```

### Ejemplo 2: Borrar varios
```sql
DELETE FROM productos WHERE stock = 0;
```

### Ejemplo 3: Borrar con condición compleja
```sql
DELETE FROM pedidos
WHERE fecha < '2024-02-01' AND cantidad > 1;
```

### 🧨 DELETE vs TRUNCATE vs DROP

| Comando | Qué hace | Se puede deshacer |
|---------|----------|-------------------|
| `DELETE FROM t WHERE ...` | Borra filas según condición | ✅ (con transacción) |
| `DELETE FROM t` | Borra todas las filas | ✅ (con transacción) |
| `TRUNCATE TABLE t` | Vacía la tabla rápido | ❌ |
| `DROP TABLE t` | Elimina la tabla entera | ❌ |

## 🛡️ Consejos de seguridad

1. **Usa transacciones** para cambios grandes:
```sql
BEGIN;
UPDATE productos SET precio = precio * 0.9;
-- Verifica el resultado
SELECT * FROM productos;
-- Si está bien:
COMMIT;
-- Si algo salió mal:
ROLLBACK;
```

2. **Haz backup** antes de operaciones masivas

3. **Prueba en desarrollo** antes de producción

## ⚠️ Errores comunes
- Olvidar el `WHERE` en UPDATE/DELETE
- Confundir `DELETE FROM t` con `DROP TABLE t`
- No usar transacciones en operaciones peligrosas
- Actualizar sin backup previo

## ✅ Ejercicios
1. Inserta 3 productos nuevos de categoría 'Deportes'
2. Sube un 5% el precio de todos los productos de 'Ropa'
3. Cambia la ciudad de todos los clientes de 'Bilbao' a 'Santander'
4. Elimina los pedidos anteriores al 2024-02-01
5. Marca como stock = 0 todos los productos con menos de 10 unidades
6. Elimina los clientes que no tengan email (¡cuidado con las FK!)

## 🔗 Recursos
- [INSERT - PostgreSQL](https://www.postgresql.org/docs/current/sql-insert.html)
- [UPDATE - PostgreSQL](https://www.postgresql.org/docs/current/sql-update.html)
- [DELETE - PostgreSQL](https://www.postgresql.org/docs/current/sql-delete.html)