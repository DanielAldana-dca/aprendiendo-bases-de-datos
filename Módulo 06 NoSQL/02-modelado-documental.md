# 02 - Modelado Documental

## 🎯 Objetivos

- Pensar en documentos, no en tablas
- Decidir entre embeber o referenciar
- Evitar anti-patrones comunes
- Modelar según el patrón de acceso

## 📚 Diferencia clave

**SQL:** "¿Cómo normalizo estos datos?"  
**MongoDB:** "¿Cómo se van a consultar estos datos?"

En NoSQL, el modelo se diseña **alrededor de las consultas**, no al revés.

## 🧩 Embeber vs Referenciar

### Embeber (documentos anidados)

Los datos relacionados viven **dentro** del mismo documento.

```javascript
{
    "_id": 1,
    "nombre": "Ana",
    "pedidos": [
        { "id": 1, "total": 1200, "fecha": "2024-01-10" },
        { "id": 2, "total": 25.50, "fecha": "2024-01-10" }
    ]
}
```

**Ventajas:**
- Una sola consulta trae todo
- Más rápido para lecturas
- Consistencia atómica del documento

**Desventajas:**
- Documentos pueden crecer demasiado (límite 16 MB en MongoDB)
- Difícil consultar datos embebidos de forma independiente
- Duplicación si varios documentos necesitan lo mismo

### Referenciar (documentos separados)

Los datos relacionados se guardan en **otra colección** y se enlazan por `_id`.

```javascript
// Colección clientes
{ "_id": 1, "nombre": "Ana" }

// Colección pedidos
{ "_id": 1, "cliente_id": 1, "total": 1200, "fecha": "2024-01-10" }
{ "_id": 2, "cliente_id": 1, "total": 25.50, "fecha": "2024-01-10" }
```

**Ventajas:**
- Sin límite de tamaño
- Datos reutilizables
- Más fácil de actualizar sin duplicar

**Desventajas:**
- Requiere múltiples consultas (o `$lookup`)
- No hay JOIN nativo (aunque existe `$lookup`)

## 🎯 Reglas para decidir

### Embeber cuando:
- Los datos se consultan **juntos**
- La relación es **1 a pocos** (ej: usuario → direcciones)
- El subdocumento **no crece indefinidamente**
- Los datos **no se comparten** con otros documentos

### Referenciar cuando:
- Los datos se consultan **por separado**
- La relación es **1 a muchos** con muchos
- El documento podría superar el límite
- Los datos se **reutilizan** en otros documentos
- Necesitas **integridad** referencial

## 💡 Ejemplos prácticos

### Ejemplo 1: Blog (posts y comentarios)

**Embeber** (si los comentarios son pocos y siempre se ven con el post):
```javascript
{
    "_id": 1,
    "titulo": "Introducción a NoSQL",
    "contenido": "...",
    "comentarios": [
        { "autor": "Luis", "texto": "Muy bueno!", "fecha": "2024-01-10" },
        { "autor": "Marta", "texto": "Gracias!", "fecha": "2024-01-11" }
    ]
}
```

**Referenciar** (si hay miles de comentarios):
```javascript
// posts
{ "_id": 1, "titulo": "Introducción a NoSQL", "contenido": "..." }

// comentarios
{ "_id": 1, "post_id": 1, "autor": "Luis", "texto": "Muy bueno!" }
{ "_id": 2, "post_id": 1, "autor": "Marta", "texto": "Gracias!" }
```

### Ejemplo 2: E-commerce (pedidos)

**Embeber** los productos del pedido (snapshot histórico):
```javascript
{
    "_id": 1,
    "cliente_id": 1,
    "fecha": "2024-01-10",
    "productos": [
        { "producto_id": 1, "nombre": "Laptop", "precio": 1200, "cantidad": 1 },
        { "producto_id": 2, "nombre": "Mouse", "precio": 25.50, "cantidad": 2 }
    ]
}
```

**Razón:** el precio y nombre al momento de la compra deben quedar congelados.

### Ejemplo 3: Red social (usuarios y seguidores)

**Referenciar** con arrays de IDs:
```javascript
{
    "_id": 1,
    "nombre": "Ana",
    "siguiendo": [2, 3, 5, 8],
    "seguidores": [2, 4, 7]
}
```

**Razón:** las listas crecen mucho y se consultan por separado.

## 🚫 Anti-patrones

### 1. Arrays sin límite
```javascript
// ❌ Mal: array que crece infinitamente
{ "_id": 1, "logs": [ ... millones de entradas ... ] }
```
**Solución:** colección separada.

### 2. Documentos masivos
```javascript
// ❌ Mal: documento que se acerca a 16 MB
{ "_id": 1, "usuario": {...}, "pedidos": [... 10.000 pedidos ...] }
```
**Solución:** referenciar pedidos.

### 3. Duplicar sin control
```javascript
// ❌ Mal: nombre duplicado en 1000 pedidos
{ "cliente_nombre": "Ana", ... }
```
**Solución:** solo duplica datos que **no cambian** (ej: precio histórico).

### 4. Modelar como SQL
```javascript
// ❌ Mal: una colección por "tabla" y todo por ID
// Clientes: { _id: 1, nombre: "Ana" }
// Pedidos: { _id: 1, cliente_id: 1 }
// Productos: { _id: 1, nombre: "Laptop" }
// Pedido_items: { pedido_id: 1, producto_id: 1, cantidad: 1 }
```
**Solución:** piensa en cómo se consulta, no en normalizar.

### 5. Índices en todo
```javascript
// ❌ Mal: índice para cada campo "por si acaso"
```
**Solución:** indexa solo los campos que usas en filtros/orden.

## 🎯 Patrón: Extended Reference

Duplica solo los **campos que necesitas** del documento relacionado.

```javascript
// En lugar de guardar solo el cliente_id:
{
    "_id": 1,
    "cliente_id": 1,
    "cliente_nombre": "Ana",     // duplicado
    "cliente_email": "ana@x.com", // duplicado
    "total": 1200
}

// Si el email del cliente cambia, actualizas:
db.pedidos.updateMany(
    { cliente_id: 1 },
    { $set: { cliente_email: "nuevo@x.com" } }
);
```

**Cuándo:** el dato casi no cambia y evitas un `$lookup`.

## 🎯 Patrón: Bucket

Agrupa datos en "cubetas" (por tiempo, por categoría) para reducir número de documentos.

```javascript
// En lugar de 1000 documentos (uno por venta):
{ "fecha": "2024-01-01", "venta": 100 }

// Un documento por día con las ventas agregadas:
{
    "fecha": "2024-01-01",
    "ventas": [100, 200, 150, ...],
    "total": 450
}
```

**Uso:** IoT, métricas, logs.

## ✅ Checklist de modelado

- [ ] ¿Qué consultas voy a hacer? (las 5 más frecuentes)
- [ ] ¿Qué datos se consultan juntos? → embeber
- [ ] ¿Qué datos crecen mucho? → referenciar
- [ ] ¿Qué datos se reutilizan? → referenciar
- [ ] ¿Qué datos no cambian? → puedo duplicar
- [ ] ¿Hay arrays que pueden crecer sin límite?
- [ ] ¿Hay documentos que podrían pasar 16 MB?

## ⚠️ Errores comunes

- Modelar como SQL (tablas y JOINs)
- Embeber todo (documentos enormes)
- Referenciar todo (muchos `$lookup`)
- No pensar en el patrón de acceso
- Ignorar el límite de 16 MB

## ✅ Ejercicios

1. Para una app de e-commerce, decide embeber o referenciar:
   - Líneas de pedido
   - Historial de pedidos del cliente
   - Categorías de productos
   - Reseñas de productos

2. Modela una colección `usuarios` con sus direcciones. ¿Embeber o referenciar?

3. Modela un blog con posts, comentarios y likes.

4. Identifica el anti-patrón: `{ "_id": 1, "logs": [ 500.000 entradas ] }`

5. Diseña el modelo para una app de mensajería (conversaciones, mensajes, usuarios).

## 🔗 Recursos

- [Data Modeling - MongoDB](https://www.mongodb.com/docs/manual/data-modeling/)
- [MongoDB Schema Design Patterns](https://www.mongodb.com/blog/post/building-with-patterns-a-summary)