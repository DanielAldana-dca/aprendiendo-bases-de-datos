# 04 - Integridad Referencial

## 🎯 Objetivos

- Entender qué es la integridad referencial
- Conocer las acciones ON DELETE / ON UPDATE
- Diseñar constraints efectivos
- Manejar borrados en cascada con seguridad

## 📚 ¿Qué es la integridad referencial?

Garantiza que las **FK siempre apunten a filas existentes**. Es una regla que el motor verifica automáticamente.

### Sin integridad
```
pedidos.cliente_id = 999  ← no existe el cliente 999 😱
```

### Con integridad
```
INSERT ... cliente_id = 999 → ERROR: FK violation
```

## 📚 Tipos de constraints

| Constraint | Qué garantiza |
|------------|---------------|
| `PRIMARY KEY` | Unicidad + NOT NULL |
| `FOREIGN KEY` | Integridad referencial |
| `UNIQUE` | Sin duplicados |
| `NOT NULL` | Sin valores nulos |
| `CHECK` | Condición personalizada |
| `DEFAULT` | Valor por defecto |

## 💻 CHECK: reglas personalizadas

```sql
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) CHECK (precio > 0),
    stock INTEGER CHECK (stock >= 0),
    categoria VARCHAR(50) CHECK (categoria IN ('Electrónica','Muebles','Ropa','Hogar'))
);
```

Si intentas `INSERT` con precio negativo → error.

### CHECK más complejos

```sql
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin > fecha_inicio)
);
```

## 💻 FOREIGN KEY: opciones

### Sintaxis completa

```sql
FOREIGN KEY (columna) 
REFERENCES tabla_referenciada(columna)
ON DELETE accion
ON UPDATE accion
```

### Acciones posibles

| Acción | Qué hace |
|--------|----------|
| `NO ACTION` | Error si hay referencias (por defecto) |
| `RESTRICT` | Igual que NO ACTION (inmediato) |
| `CASCADE` | Borra/actualiza en cascada |
| `SET NULL` | Pone NULL en la FK |
| `SET DEFAULT` | Pone el valor por defecto |

### Ejemplos

**NO ACTION (por defecto):**
```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```
Intentar borrar un cliente con pedidos → **error**.

**CASCADE:**
```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);
```
Borrar cliente → **borra todos sus pedidos**.

**SET NULL:**
```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
);
```
Borrar cliente → sus pedidos quedan con `cliente_id = NULL`.

## ⚠️ CASCADE con cuidado

`ON DELETE CASCADE` es potente pero **peligroso**.

### Ejemplo real

```
clientes
  └── pedidos
        └── lineas_pedido
              └── facturas
```

Si borras un cliente con CASCADE en toda la cadena → **borras facturas históricas**. En muchos países, eso es **ilegal** (hay que conservar registros fiscales 5-10 años).

### Alternativas
- `ON DELETE RESTRICT` + soft delete
- Archivar en vez de borrar
- `ON DELETE SET NULL` si la relación es opcional

## 💻 Soft Delete

En lugar de borrar, marca como inactivo.

```sql
ALTER TABLE clientes ADD COLUMN activo BOOLEAN DEFAULT TRUE;
ALTER TABLE clientes ADD COLUMN fecha_baja TIMESTAMP;

-- "Borrar" un cliente
UPDATE clientes SET activo = FALSE, fecha_baja = NOW() WHERE id = 1;
```

**Ventajas:**
- No pierdes historial
- Puedes recuperar
- FK siguen válidas

**Desventajas:**
- Todas las consultas deben filtrar `WHERE activo = TRUE`
- Ocupa espacio

## 💻 Añadir constraint a tabla existente

```sql
ALTER TABLE pedidos
ADD CONSTRAINT fk_pedido_cliente
FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE;
```

### Eliminar constraint

```sql
ALTER TABLE pedidos DROP CONSTRAINT fk_pedido_cliente;
```

### Ver constraints

**PostgreSQL:**
```sql
SELECT conname, contype, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'pedidos'::regclass;
```

**MySQL:**
```sql
SHOW CREATE TABLE pedidos;
```

## 🎯 Patrón: tabla con integridad completa

```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' 
        CHECK (estado IN ('pendiente','pagado','enviado','cancelado')),
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
```

## 🎯 Estrategias para borrados

| Escenario | Acción |
|-----------|--------|
| Datos maestros (país, categoría) | `RESTRICT` |
| Composición real (pedido → líneas) | `CASCADE` |
| Referencias opcionales | `SET NULL` |
| Datos legales/históricos | Soft delete |

## ⚠️ Errores comunes

- Poner CASCADE en todo "para que no falle"
- No declarar FK (y perder integridad)
- FK sin índice (¡consultas lentas!)
- Confundir RESTRICT con NO ACTION (son casi iguales)
- No pensar en la política de borrado desde el diseño

## ✅ Ejercicios

1. Crea las tablas `clientes`, `pedidos`, `lineas_pedido` con FK y CASCADE apropiado
2. Añade un CHECK a `clientes.edad` para que sea entre 0 y 120
3. ¿Qué acción de FK usarías entre `facturas` y `clientes`? Justifica
4. Crea un CHECK que garantice que `stock >= 0`
5. Prueba qué pasa al borrar un cliente con pedidos:
   - Con NO ACTION
   - Con CASCADE
   - Con SET NULL
6. Diseña un sistema de soft delete para productos

## 🔗 Recursos

- [Constraints - PostgreSQL](https://www.postgresql.org/docs/current/ddl-constraints.html)