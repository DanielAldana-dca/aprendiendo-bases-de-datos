# 🧪 Ejercicios - Integridad y Constraints

## Nivel 🟢 Fácil

### 1. CHECK simple
Crea una tabla `productos` con `precio > 0` y `stock >= 0`.

<details>
<summary>💡 Solución</summary>

```sql
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
);
```
</details>

### 2. FK con CASCADE
Crea `pedidos` con FK a `clientes` con CASCADE.

<details>
<summary>💡 Solución</summary>

```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);
```
</details>

---

## Nivel 🟡 Intermedio

### 3. CHECK con IN
Crea una tabla `pedidos` con `estado` limitado a valores específicos.

<details>
<summary>💡 Solución</summary>

```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','pagado','enviado','entregado','cancelado')),
    fecha DATE DEFAULT CURRENT_DATE
);
```
</details>

### 4. CHECK de rango
`clientes.edad` entre 0 y 120.

<details>
<summary>💡 Solución</summary>

```sql
ALTER TABLE clientes
ADD CONSTRAINT chk_edad CHECK (edad BETWEEN 0 AND 120);
```
</details>

### 5. CHECK entre columnas
Crea `reservas` con `fecha_fin > fecha_inicio`.

<details>
<summary>💡 Solución</summary>

```sql
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin > fecha_inicio)
);
```
</details>

---

## Nivel 🔴 Difícil

### 6. Estrategia de borrado
Tienes: `clientes → pedidos → lineas_pedido → facturas`.

¿Qué acción ON DELETE usarías en cada FK? Justifica.

<details>
<summary>💡 Solución</summary>

| FK | Acción | Razón |
|----|--------|-------|
| pedidos.cliente_id | `RESTRICT` | No deberías borrar un cliente con pedidos |
| lineas_pedido.pedido_id | `CASCADE` | Las líneas no existen sin el pedido |
| facturas.pedido_id | `RESTRICT` | Las facturas son documentos legales |

**Mejor aún:** usar **soft delete** en clientes.

```sql
ALTER TABLE clientes ADD COLUMN activo BOOLEAN DEFAULT TRUE;
```

</details>

### 7. Constraint completo
Crea la tabla `productos` con:
- PK autoincremental
- nombre no nulo y único
- precio > 0
- stock >= 0
- categoría limitada a valores
- fecha_creacion automática

<details>
<summary>💡 Solución</summary>

```sql
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(50) NOT NULL 
        CHECK (categoria IN ('Electrónica','Muebles','Ropa','Hogar','Deportes')),
    fecha_creacion TIMESTAMP DEFAULT NOW()
);
```
</details>

### 8. Trigger para validar stock
Crea un trigger que impida vender más stock del disponible.

<details>
<summary>💡 Solución (PostgreSQL)</summary>

```sql
CREATE OR REPLACE FUNCTION validar_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INTEGER;
BEGIN
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id = NEW.producto_id;
    
    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %', stock_actual;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_validar_stock
BEFORE INSERT ON pedidos
FOR EACH ROW
EXECUTE FUNCTION validar_stock();
```
</details>