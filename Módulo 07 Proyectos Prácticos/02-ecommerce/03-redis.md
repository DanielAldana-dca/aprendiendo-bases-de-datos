# 🔴 Diseño del Carrito con Redis

## 🎯 Objetivo

Implementar un carrito de compras rápido y temporal usando Redis.

## 📊 Estructura

### Carrito por usuario

```
cart:{usuario_id}  →  Hash
  ├── variante:{id}:cantidad  →  2
  └── ...
```

### Metadata del carrito

```
cart:{usuario_id}:meta  →  Hash
  ├── cupon        →  "VERANO24"
  └── actualizado  →  "2024-03-15T10:30:00"
```

## 💻 Operaciones básicas

### Crear/añadir al carrito

```redis
# Añadir 2 unidades de la variante 123
HSET cart:1 variante:123:cantidad 2

# Añadir 1 unidad de la variante 456
HSET cart:1 variante:456:cantidad 1

# TTL de 7 días
EXPIRE cart:1 604800
EXPIRE cart:1:meta 604800
```

### Leer carrito

```redis
HGETALL cart:1
# 1) "variante:123:cantidad"
# 2) "2"
# 3) "variante:456:cantidad"
# 4) "1"

HGETALL cart:1:meta
# 1) "cupon"
# 2) "VERANO24"
# 3) "actualizado"
# 4) "2024-03-15T10:30:00"
```

### Actualizar cantidad

```redis
HSET cart:1 variante:123:cantidad 3
```

### Eliminar producto

```redis
HDEL cart:1 variante:456:cantidad
```

### Vaciar carrito

```redis
DEL cart:1
DEL cart:1:meta
```

## 🧮 Aplicar cupón

```redis
# Guardar cupón en meta
HSET cart:1:meta cupon "VERANO24"

# Al calcular total, validar en PostgreSQL:
# SELECT * FROM cupones WHERE codigo = 'VERANO24' AND activo AND CURRENT_DATE BETWEEN valido_desde AND valido_hasta;
```

## 🔄 Flujo completo

### 1. Usuario añade producto

```python
def add_to_cart(user_id, variante_id, cantidad):
    key = f"cart:{user_id}"
    field = f"variante:{variante_id}:cantidad"
    redis.hincrby(key, field, cantidad)
    redis.expire(key, 604800)
    redis.hset(f"{key}:meta", "actualizado", datetime.now().isoformat())
```

### 2. Usuario consulta carrito

```python
def get_cart(user_id):
    key = f"cart:{user_id}"
    items = redis.hgetall(key)
    
    # Convertir a lista de (variante_id, cantidad)
    cart_items = []
    for field, cantidad in items.items():
        variante_id = int(field.split(":")[1])
        cart_items.append((variante_id, int(cantidad)))
    
    # Cruzar con PostgreSQL para precios y stock
    query = """
        SELECT 
            v.id,
            v.sku,
            v.precio,
            v.stock,
            p.nombre AS producto,
            array_agg(a.nombre || ': ' || a.valor) AS atributos
        FROM variantes v
        JOIN productos p ON v.producto_id = p.id
        LEFT JOIN variante_atributo va ON v.id = va.variante_id
        LEFT JOIN atributos a ON va.atributo_id = a.id
        WHERE v.id = ANY(%s)
        GROUP BY v.id, v.sku, v.precio, v.stock, p.nombre
    """
    variantes = db.execute(query, ([v[0] for v in cart_items],))
    
    # Calcular subtotales
    total = 0
    for v in variantes:
        cantidad = next(c for vid, c in cart_items if vid == v.id)
        v.cantidad = cantidad
        v.subtotal = v.precio * cantidad
        total += v.subtotal
    
    # Aplicar cupón si existe
    meta = redis.hgetall(f"{key}:meta")
    descuento = 0
    if "cupon" in meta:
        cupon = validate_coupon(meta["cupon"])
        if cupon:
            descuento = calculate_discount(cupon, total)
    
    return {
        "items": variantes,
        "subtotal": total,
        "descuento": descuento,
        "total": total - descuento,
        "cupon": meta.get("cupon")
    }
```

### 3. Usuario finaliza compra

```python
def checkout(user_id, direccion_id):
    cart = get_cart(user_id)
    
    if not cart["items"]:
        raise Exception("Carrito vacío")
    
    with db.transaction():
        # 1. Crear pedido
        pedido_id = db.insert("pedidos", {
            "usuario_id": user_id,
            "direccion_id": direccion_id,
            "subtotal": cart["subtotal"],
            "descuento": cart["descuento"],
            "total": cart["total"],
            "estado": "pendiente"
        })
        
        # 2. Insertar líneas
        for item in cart["items"]:
            db.insert("lineas_pedido", {
                "pedido_id": pedido_id,
                "variante_id": item.id,
                "producto_nombre": item.producto,
                "variante_desc": ", ".join(item.atributos),
                "cantidad": item.cantidad,
                "precio_unitario": item.precio,
                "subtotal": item.subtotal
            })
            # El trigger reduce stock automáticamente
        
        # 3. Vaciar carrito en Redis
        redis.delete(f"cart:{user_id}")
        redis.delete(f"cart:{user_id}:meta")
    
    return pedido_id
```

## 🧹 Mantenimiento

### Limpiar carritos abandonados

```redis
# Escanear carritos viejos (más de 30 días)
SCAN 0 MATCH cart:* COUNT 100

# O confiar en el TTL
```

### Estadísticas

```redis
# Número de carritos activos
DBSIZE

# Carritos por usuario
KEYS cart:*
```

## 🎯 Ventajas de Redis para el carrito

| Ventaja | Detalle |
|---------|---------|
| **Velocidad** | Microsegundos vs milisegundos |
| **TTL automático** | Carritos viejos se limpian solos |
| **Sin escrituras en SQL** | Menos carga en la BD principal |
| **Sesión cross-device** | Con el `usuario_id` funciona en cualquier dispositivo |
| **Escalable** | Redis cluster para millones de usuarios |

## ⚠️ Errores comunes

- No poner TTL (carritos infinitos)
- Guardar precios en Redis (pueden quedar desactualizados)
- No validar stock al hacer checkout
- No usar transacción al crear el pedido
- Confundir "carrito" con "pedido pendiente" (el carrito no reserva stock)