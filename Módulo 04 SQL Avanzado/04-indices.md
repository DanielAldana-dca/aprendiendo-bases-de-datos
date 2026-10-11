# 04 - Índices

## 🎯 Objetivos

- Entender qué es un índice y por qué acelera consultas
- Crear, ver y eliminar índices
- Conocer los tipos de índices
- Saber cuándo NO indexar

## 📚 ¿Qué es un índice?

Un índice es una **estructura auxiliar** que permite encontrar filas rápidamente sin recorrer toda la tabla.

**Analogía:** el índice de un libro. En lugar de leer todas las páginas para encontrar "transacciones", vas al índice y saltas directo.

## 💻 Crear un índice

```sql
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
```

Ahora las consultas como `WHERE ciudad = 'Madrid'` son más rápidas.

### Índice único

```sql
CREATE UNIQUE INDEX idx_clientes_email ON clientes(email);
```

Garantiza que no haya dos valores iguales.

### Índice compuesto (varias columnas)

```sql
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha);
```

**Orden importa:** este índice sirve para `WHERE cliente_id = X` o `WHERE cliente_id = X AND fecha = Y`, pero **no** para `WHERE fecha = Y` solo.

### Índice parcial (solo algunas filas)

```sql
CREATE INDEX idx_productos_sin_stock ON productos(nombre)
WHERE stock = 0;
```

Más pequeño y rápido si solo consultas ese subconjunto.

### Índice en expresión

```sql
CREATE INDEX idx_clientes_email_lower ON clientes(LOWER(email));
```

Útil si buscas `WHERE LOWER(email) = 'ana@mail.com'`.

## 🔍 Ver índices existentes

### PostgreSQL
```sql
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'clientes';
```

### MySQL
```sql
SHOW INDEX FROM clientes;
```

### SQLite
```sql
PRAGMA index_list('clientes');
```

## 🗑️ Eliminar un índice

```sql
DROP INDEX idx_clientes_ciudad;
```

## 📊 ¿Cuándo indexar?

✅ **Sí indexar:**
- Columnas usadas en `WHERE` con frecuencia
- Columnas en `JOIN` (FK)
- Columnas en `ORDER BY` con muchos datos
- Columnas con alta **selectividad** (muchos valores distintos)

❌ **No indexar:**
- Tablas pequeñas (< 1000 filas)
- Columnas con pocos valores distintos (ej: `activo` boolean)
- Tablas con muchas escrituras y pocas lecturas
- Cada columna "por si acaso"

## ⚖️ Trade-offs

| Ventaja | Desventaja |
|---------|------------|
| Lecturas más rápidas | Ocupa espacio en disco |
| Ordenamiento rápido | Escrituras más lentas |
| Búsquedas eficientes | Necesita mantenimiento |

**Regla:** indexa para las consultas que realmente haces, no para todas las posibles.

## 📈 Ver el plan de ejecución

### PostgreSQL
```sql
EXPLAIN ANALYZE SELECT * FROM clientes WHERE ciudad = 'Madrid';
```

### MySQL
```sql
EXPLAIN SELECT * FROM clientes WHERE ciudad = 'Madrid';
```

### SQLite
```sql
EXPLAIN QUERY PLAN SELECT * FROM clientes WHERE ciudad = 'Madrid';
```

**Busca:** `Seq Scan` (malo) vs `Index Scan` (bueno).

## 🧠 Tipos de índices

| Tipo | Uso |
|------|-----|
| **B-tree** | Por defecto, para comparaciones y rangos |
| **Hash** | Solo igualdad (=) |
| **GIN** | JSON, arrays, búsqueda full-text |
| **GiST** | Datos geográficos |
| **BRIN** | Tablas enormes ordenadas |

Para empezar, **B-tree** es lo que necesitas.

## 🎯 Patrón: índice en FK

Cuando declaras una FK, **no se crea un índice automáticamente** (excepto en MySQL). Si haces muchos JOIN por esa columna, créalo:

```sql
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_producto ON pedidos(producto_id);
```

## ⚠️ Errores comunes

- Indexar todo "por si acaso" → ralentiza escrituras
- Índice compuesto con columnas en mal orden
- No actualizar estadísticas (`ANALYZE`)
- Esperar que un índice se use siempre
- Ignorar el plan de ejecución

## ✅ Ejercicios

1. Crea un índice en `clientes.ciudad` y verifica con EXPLAIN
2. Crea un índice compuesto en `pedidos(cliente_id, fecha)`
3. Compara el plan de ejecución con y sin índice
4. Crea un índice único en `productos.nombre`
5. ¿Qué índice crearías para acelerar "pedidos de un cliente ordenados por fecha"?
6. Analiza qué índices faltan en el dataset actual

## 🔗 Recursos

- [Use The Index, Luke](https://use-the-index-luke.com/) (¡lectura obligada!)
- [Índices en PostgreSQL](https://www.postgresql.org/docs/current/indexes.html)