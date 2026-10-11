# 05 - Transacciones

## 🎯 Objetivos

- Entender qué es una transacción
- Conocer las propiedades ACID
- Usar BEGIN, COMMIT, ROLLBACK
- Aplicar transacciones para operaciones seguras

## 📚 ¿Qué es una transacción?

Una **transacción** es un conjunto de operaciones que se ejecutan **como una sola unidad**. O se ejecutan todas, o no se ejecuta ninguna.

**Ejemplo clásico:** transferencia bancaria.
- Restar 100€ de la cuenta A
- Sumar 100€ a la cuenta B

Si falla el segundo paso, el primero **no debe quedar aplicado**.

## 🏛️ Propiedades ACID

| Letra | Significa | Qué garantiza |
|-------|-----------|---------------|
| **A** | Atomicity | Todo o nada |
| **C** | Consistency | Los datos quedan válidos |
| **I** | Isolation | Transacciones concurrentes no se interfieren |
| **D** | Durability | Una vez confirmado, persiste aunque haya fallo |

## 💻 Comandos básicos

### BEGIN / COMMIT / ROLLBACK

```sql
BEGIN;

UPDATE productos SET stock = stock - 1 WHERE id = 1;
UPDATE productos SET stock = stock - 1 WHERE id = 2;

-- Si todo está bien:
COMMIT;

-- Si algo falla:
-- ROLLBACK;
```

### Ejemplo con verificación

```sql
BEGIN;

UPDATE productos SET stock = stock - 5 WHERE id = 1;

-- Verificar
SELECT * FROM productos WHERE id = 1;

-- Si el stock quedó negativo:
-- ROLLBACK;

-- Si está bien:
COMMIT;
```

## 🎯 Patrón: transferencia entre tablas

Simulemos: mover 10 unidades de stock del producto 1 al producto 2.

```sql
BEGIN;

-- Paso 1: restar
UPDATE productos SET stock = stock - 10 WHERE id = 1;

-- Paso 2: verificar que no quede negativo
-- (en app real, habría un IF aquí)

-- Paso 3: sumar
UPDATE productos SET stock = stock + 10 WHERE id = 2;

COMMIT;
```

Si algo falla entre medio, `ROLLBACK` deja todo como estaba.

## 💻 SAVEPOINT

Puntos intermedios para hacer rollback parcial.

```sql
BEGIN;

INSERT INTO clientes VALUES (20, 'Test 1', 'test1@x.com', 'Madrid', 30, '2024-01-01');
SAVEPOINT sp1;

INSERT INTO clientes VALUES (21, 'Test 2', 'test2@x.com', 'Madrid', 30, '2024-01-01');
SAVEPOINT sp2;

-- Ups, el segundo tiene un error
ROLLBACK TO sp2;

COMMIT;
-- Solo se guarda el primer INSERT
```

## 🔒 Niveles de aislamiento

Controlan cuánto se "ven" las transacciones concurrentes.

| Nivel | Problema que evita |
|-------|-------------------|
| READ UNCOMMITTED | Nada |
| READ COMMITTED | Dirty reads (por defecto en PostgreSQL) |
| REPEATABLE READ | Non-repeatable reads |
| SERIALIZABLE | Phantom reads |

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
-- ...
COMMIT;
```

> 💡 Para el 90% de casos, el nivel por defecto funciona bien.

## 🎯 Cuándo usar transacciones

✅ **Sí:**
- Operaciones que tocan varias tablas relacionadas
- Cálculos financieros (transferencias, facturación)
- Procesos batch que deben ser atómicos
- Cualquier cosa donde un fallo a medias dejaría datos inconsistentes

❌ **No hace falta:**
- Un solo SELECT
- Un solo INSERT simple
- Consultas de solo lectura

## 🧪 Ejemplo: crear pedido completo

```sql
BEGIN;

-- 1. Insertar el pedido
INSERT INTO pedidos (id, cliente_id, producto_id, cantidad, fecha)
VALUES (100, 1, 3, 2, CURRENT_DATE);

-- 2. Reducir stock
UPDATE productos SET stock = stock - 2 WHERE id = 3;

-- 3. Verificar stock
SELECT stock FROM productos WHERE id = 3;
-- Si stock < 0 → ROLLBACK

COMMIT;
```

## ⚠️ Errores comunes

- Olvidar `COMMIT` → cambios no guardados
- Olvidar `ROLLBACK` cuando algo falla
- Transacciones muy largas → bloquean la tabla
- No usar transacción en operaciones críticas

## ⚠️ Bloqueos (deadlocks)

Si dos transacciones se esperan mutuamente, el motor aborta una.

```
Transacción A: bloquea fila 1, espera fila 2
Transacción B: bloquea fila 2, espera fila 1
→ DEADLOCK
```

**Prevención:** accede a las tablas/filas siempre en el mismo orden.

## ✅ Ejercicios

1. Simula una transferencia de stock entre dos productos
2. Inserta 3 clientes en una transacción. Si uno falla, ninguno debe guardarse
3. Practica SAVEPOINT: inserta 3 filas, revierte solo la segunda
4. ¿Qué pasa si ejecutas `BEGIN` y no ejecutas `COMMIT` ni `ROLLBACK`?
5. Simula un fallo a mitad de una operación y usa ROLLBACK

## 🔗 Recursos

- [Transacciones - PostgreSQL](https://www.postgresql.org/docs/current/tutorial-transactions.html)