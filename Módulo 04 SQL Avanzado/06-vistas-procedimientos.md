# 06 - Vistas y Procedimientos

## 🎯 Objetivos

- Crear y usar vistas (VIEW)
- Crear vistas materializadas
- Entender qué son los procedimientos almacenados
- Conocer triggers

## 📚 Vistas (VIEW)

Una **vista** es una consulta guardada con nombre. Se comporta como una tabla virtual.

### Crear una vista

```sql
CREATE VIEW ventas_por_cliente AS
SELECT 
    c.id AS cliente_id,
    c.nombre,
    COUNT(p.id) AS num_pedidos,
    SUM(p.cantidad * pr.precio) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p    ON c.id = p.cliente_id
LEFT JOIN productos pr ON p.producto_id = pr.id
GROUP BY c.id, c.nombre;
```

### Usar la vista

```sql
SELECT * FROM ventas_por_cliente WHERE total_gastado > 500;
```

Se ve como una tabla pero **no guarda datos**: ejecuta la consulta cada vez.

### Ventajas

- Simplifica consultas complejas
- Reutilizable
- Capa de seguridad (no expones la tabla completa)
- Abstrae cambios en el esquema

### Actualizar la vista

```sql
CREATE OR REPLACE VIEW ventas_por_cliente AS
SELECT ...;
```

### Eliminar

```sql
DROP VIEW ventas_por_cliente;
```

## 📚 Vistas materializadas

Guardan **físicamente** el resultado. Más rápidas pero hay que **refrescarlas**.

### PostgreSQL

```sql
CREATE MATERIALIZED VIEW resumen_ventas AS
SELECT 
    DATE_TRUNC('month', fecha) AS mes,
    SUM(cantidad) AS unidades
FROM pedidos
GROUP BY mes;

-- Refrescar (cuando los datos cambian)
REFRESH MATERIALIZED VIEW resumen_ventas;
```

### ¿Cuándo usar cada una?

| Vista normal | Vista materializada |
|--------------|---------------------|
| Datos siempre actualizados | Datos "congelados" |
| Más lenta | Más rápida |
| Sin mantenimiento | Necesita refresco |
| Consultas ligeras | Reportes pesados |

## 📚 Procedimientos almacenados

Bloques de código SQL guardados en la BD, ejecutables con nombre.

### PostgreSQL (función)

```sql
CREATE OR REPLACE FUNCTION total_gastado_cliente(p_cliente_id INT)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(p.cantidad * pr.precio), 0)
    INTO total
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.cliente_id = p_cliente_id;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;
```

### Usar

```sql
SELECT total_gastado_cliente(1);
```

### MySQL

```sql
DELIMITER //
CREATE PROCEDURE total_gastado(IN cliente INT, OUT total DECIMAL)
BEGIN
    SELECT COALESCE(SUM(p.cantidad * pr.precio), 0)
    INTO total
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.cliente_id = cliente;
END //
DELIMITER ;

CALL total_gastado(1, @total);
SELECT @total;
```

## 📚 Triggers

Se ejecutan **automáticamente** ante eventos (INSERT, UPDATE, DELETE).

### Ejemplo: reducir stock al insertar pedido

```sql
CREATE OR REPLACE FUNCTION reducir_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.producto_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_pedido_insert
AFTER INSERT ON pedidos
FOR EACH ROW
EXECUTE FUNCTION reducir_stock();
```

Ahora cada INSERT en `pedidos` reduce el stock automáticamente.

### ⚠️ Cuándo NO usar triggers

- Lógica de negocio compleja (mejor en la app)
- Si dificultan el debugging
- Si ocultan efectos secundarios inesperados

## 🎯 Patrones útiles

### Vista para reportes

```sql
CREATE VIEW reporte_mensual AS
SELECT 
    DATE_TRUNC('month', fecha) AS mes,
    COUNT(DISTINCT cliente_id) AS clientes_unicos,
    COUNT(*) AS pedidos,
    SUM(cantidad) AS unidades
FROM pedidos
GROUP BY mes;
```

### Vista de "datos sensibles ocultos"

```sql
CREATE VIEW clientes_publicos AS
SELECT 
    id,
    nombre,
    ciudad,
    CONCAT(SUBSTRING(email, 1, 3), '***@', SPLIT_PART(email, '@', 2)) AS email_parcial
FROM clientes;
```

## ⚠️ Errores comunes

- Crear vistas que dependen de otras vistas (difícil de mantener)
- Abusar de vistas materializadas sin refrescar
- Meter lógica de negocio en triggers (dolor de cabeza)
- No documentar procedimientos

## ✅ Ejercicios

1. Crea una vista `productos_caros` con productos > 100
2. Crea una vista `resumen_clientes` con nombre, ciudad y total gastado
3. Consulta la vista y filtra solo los de Madrid
4. Crea una función que reciba un id de producto y devuelva su stock
5. Crea un trigger que registre cambios de precio (tabla `historial_precios`)
6. ¿Cuándo usarías vista materializada vs vista normal?

## 🔗 Recursos

- [Vistas - PostgreSQL](https://www.postgresql.org/docs/current/sql-createview.html)
- [Triggers - PostgreSQL](https://www.postgresql.org/docs/current/sql-createtrigger.html)