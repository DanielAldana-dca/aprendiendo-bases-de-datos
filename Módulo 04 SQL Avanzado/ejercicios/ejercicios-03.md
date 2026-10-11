# 🧪 Ejercicios - CASE, COALESCE, Índices y Transacciones

## Sección A: CASE y COALESCE

### 1. Email por defecto
Muestra clientes con email o 'sin-email' si es NULL.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    nombre,
    COALESCE(email, 'sin-email') AS email
FROM clientes;
```
</details>

### 2. Categorizar precios
Clasifica productos en barato (<50), medio (50-200), caro (>200).

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    nombre,
    precio,
    CASE 
        WHEN precio < 50 THEN 'Barato'
        WHEN precio <= 200 THEN 'Medio'
        ELSE 'Caro'
    END AS rango
FROM productos
ORDER BY precio DESC;
```
</details>

### 3. Conteo condicional
En una sola fila: clientes mayores de 30 y menores de 30.

<details>
<summary>💡 Solución</summary>

```sql
SELECT 
    COUNT(CASE WHEN edad > 30 THEN 1 END) AS mayores_30,
    COUNT(CASE WHEN edad <= 30 THEN 1 END) AS menores_30
FROM clientes;
```
</details>

### 4. Prioridad de orden
Ordena productos poniendo primero 'Electrónica', luego 'Ropa', luego el resto.

<details>
<summary>💡 Solución</summary>

```sql
SELECT nombre, categoria
FROM productos
ORDER BY 
    CASE categoria
        WHEN 'Electrónica' THEN 1
        WHEN 'Ropa' THEN 2
        ELSE 3
    END,
    nombre;
```
</details>

---

## Sección B: Índices

### 5. Crear índice
Crea un índice en `clientes.ciudad`.

<details>
<summary>💡 Solución</summary>

```sql
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
```
</details>

### 6. Índice compuesto
Índice en `pedidos(cliente_id, fecha)`.

<details>
<summary>💡 Solución</summary>

```sql
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha);
```
</details>

### 7. Ver plan
Consulta el plan de ejecución de una búsqueda por ciudad.

<details>
<summary>💡 Solución</summary>

PostgreSQL:
```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE ciudad = 'Madrid';
```

SQLite:
```sql
EXPLAIN QUERY PLAN SELECT * FROM clientes WHERE ciudad = 'Madrid';
```
</details>

### 8. Análisis
¿Qué índice crearías para "pedidos de un cliente ordenados por fecha"?

<details>
<summary>💡 Solución</summary>

```sql
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha);
```

Orden importante: primero `cliente_id` (para filtrar) y luego `fecha` (para ordenar).
</details>

---

## Sección C: Transacciones

### 9. Transferencia de stock
Mueve 5 unidades del producto 1 al producto 2 dentro de una transacción.

<details>
<summary>💡 Solución</summary>

```sql
BEGIN;

UPDATE productos SET stock = stock - 5 WHERE id = 1;
UPDATE productos SET stock = stock + 5 WHERE id = 2;

-- Verificar
SELECT id, nombre, stock FROM productos WHERE id IN (1, 2);

COMMIT;
```
</details>

### 10. Rollback de prueba
Inserta 3 clientes, luego haz rollback y verifica que no quedaron.

<details>
<summary>💡 Solución</summary>

```sql
BEGIN;

INSERT INTO clientes VALUES (100, 'Test A', 'a@t.com', 'X', 20, '2024-01-01');
INSERT INTO clientes VALUES (101, 'Test B', 'b@t.com', 'X', 21, '2024-01-01');
INSERT INTO clientes VALUES (102, 'Test C', 'c@t.com', 'X', 22, '2024-01-01');

-- Confirmar que están:
SELECT COUNT(*) FROM clientes WHERE id >= 100;

ROLLBACK;

-- Verificar que NO están:
SELECT COUNT(*) FROM clientes WHERE id >= 100;  -- debe dar 0
```
</details>