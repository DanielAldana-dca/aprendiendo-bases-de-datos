# 03 - MongoDB

## 🎯 Objetivos

- Conocer la estructura de MongoDB
- Dominar CRUD (insert, find, update, delete)
- Escribir consultas con filtros avanzados
- Usar aggregation pipeline
- Crear índices

## 📚 ¿Qué es MongoDB?

Base de datos **documental** que guarda datos en **BSON** (JSON binario).

**Jerarquía:**
```
Servidor
  └── Base de datos (tienda_nosql)
        └── Colección (clientes)
              └── Documento ({ _id: 1, nombre: "Ana" })
```

Equivalencias con SQL:

| SQL | MongoDB |
|-----|---------|
| Tabla | Colección |
| Fila | Documento |
| Columna | Campo |
| JOIN | `$lookup` |
| PRIMARY KEY | `_id` |

## 💻 Operaciones CRUD

### INSERT

```javascript
// Un documento
db.clientes.insertOne({
    nombre: "Laura Gil",
    email: "laura@mail.com",
    ciudad: "Madrid",
    edad: 27
});

// Varios documentos
db.productos.insertMany([
    { nombre: "Webcam HD", categoria: "Electrónica", precio: 45.00, stock: 50 },
    { nombre: "Auriculares BT", categoria: "Electrónica", precio: 79.99, stock: 60 }
]);
```

### FIND (SELECT)

```javascript
// Todos
db.clientes.find();

// Con filtro
db.clientes.find({ ciudad: "Madrid" });

// Bonito
db.clientes.find({ ciudad: "Madrid" }).pretty();

// Campos específicos (proyección)
db.clientes.find({ ciudad: "Madrid" }, { nombre: 1, email: 1, _id: 0 });

// Uno solo
db.clientes.findOne({ _id: 1 });
```

### UPDATE

```javascript
// Un documento
db.clientes.updateOne(
    { _id: 1 },
    { $set: { ciudad: "Barcelona" } }
);

// Varios documentos
db.productos.updateMany(
    { categoria: "Electrónica" },
    { $mul: { precio: 1.10 } }  // +10%
);

// Reemplazar todo el documento
db.clientes.replaceOne(
    { _id: 1 },
    { nombre: "Ana G.", email: "ana@mail.com", ciudad: "Madrid", edad: 29 }
);
```

**Operadores de actualización:**
| Operador | Efecto |
|----------|--------|
| `$set` | Establece un valor |
| `$unset` | Elimina un campo |
| `$inc` | Incrementa |
| `$mul` | Multiplica |
| `$push` | Añade a un array |
| `$pull` | Quita de un array |
| `$addToSet` | Añade si no existe |

### DELETE

```javascript
// Uno
db.clientes.deleteOne({ _id: 1 });

// Varios
db.pedidos.deleteMany({ estado: "cancelado" });

// Todos (¡cuidado!)
db.clientes.deleteMany({});
```

## 🔍 Consultas avanzadas

### Operadores de comparación

```javascript
db.productos.find({ precio: { $gt: 100 } });      // >
db.productos.find({ precio: { $gte: 100 } });     // >=
db.productos.find({ precio: { $lt: 50 } });       // <
db.productos.find({ precio: { $ne: 0 } });        // !=
db.productos.find({ precio: { $in: [25.50, 89.99] } });
db.productos.find({ precio: { $nin: [1200] } });
```

### Operadores lógicos

```javascript
// AND implícito
db.clientes.find({ ciudad: "Madrid", edad: { $gt: 25 } });

// OR
db.clientes.find({
    $or: [
        { ciudad: "Madrid" },
        { ciudad: "Barcelona" }
    ]
});

// AND explícito
db.clientes.find({
    $and: [
        { edad: { $gte: 25 } },
        { edad: { $lte: 35 } }
    ]
});

// NOT
db.clientes.find({ ciudad: { $not: { $eq: "Madrid" } } });
```

### Existencia y null

```javascript
db.clientes.find({ email: { $exists: true } });
db.clientes.find({ email: null });  // null O campo inexistente
db.clientes.find({ email: { $type: "string" } });
```

### Arrays

```javascript
// Contiene el valor
db.productos.find({ tags: "gaming" });

// Contiene todos
db.productos.find({ tags: { $all: ["accesorio", "gaming"] } });

// Tamaño del array
db.productos.find({ tags: { $size: 2 } });

// Algún elemento cumple
db.productos.find({ tags: { $elemMatch: { $eq: "laptop" } } });
```

### Documentos anidados

```javascript
db.clientes.find({ "preferencias.idioma": "es" });
db.clientes.find({ "preferencias.newsletter": true });
```

### Expresiones regulares

```javascript
db.clientes.find({ nombre: /^A/ });       // Empieza por A
db.clientes.find({ nombre: /a$/i });      // Termina por a (case-insensitive)
db.productos.find({ nombre: /pro/i });
```

## 📊 Proyección y orden

```javascript
// Solo algunos campos
db.clientes.find({}, { nombre: 1, ciudad: 1 });

// Excluir
db.clientes.find({}, { email: 0 });

// Ordenar
db.clientes.find().sort({ edad: -1 });           // DESC
db.clientes.find().sort({ ciudad: 1, edad: -1 }); // ciudad ASC, edad DESC

// Limitar y saltar
db.clientes.find().limit(5);
db.clientes.find().skip(5).limit(5);  // paginación
```

## 📈 Aggregation Pipeline

El "GROUP BY + JOIN" de MongoDB.

```javascript
db.pedidos.aggregate([
    { $match: { estado: "entregado" } },           // WHERE
    { $group: {                                    // GROUP BY
        _id: "$cliente_id",
        total: { $sum: { $sum: "$productos.precio" } },
        num_pedidos: { $sum: 1 }
    }},
    { $sort: { total: -1 } },                      // ORDER BY
    { $limit: 5 }                                  // LIMIT
]);
```

### Etapas principales

| Etapa | Equivalente SQL |
|-------|-----------------|
| `$match` | WHERE |
| `$group` | GROUP BY |
| `$sort` | ORDER BY |
| `$limit` | LIMIT |
| `$skip` | OFFSET |
| `$project` | SELECT |
| `$lookup` | LEFT JOIN |
| `$unwind` | (expandir arrays) |
| `$count` | COUNT(*) |

### $lookup (JOIN)

```javascript
db.pedidos.aggregate([
    {
        $lookup: {
            from: "clientes",
            localField: "cliente_id",
            foreignField: "_id",
            as: "cliente"
        }
    },
    { $unwind: "$cliente" },
    { $project: { _id: 1, "cliente.nombre": 1, fecha: 1 } }
]);
```

### $unwind (aplanar arrays)

```javascript
db.pedidos.aggregate([
    { $unwind: "$productos" },
    {
        $group: {
            _id: "$productos.producto_id",
            cantidad_total: { $sum: "$productos.cantidad" }
        }
    }
]);
```

## ⚡ Índices

```javascript
// Crear índice
db.clientes.createIndex({ ciudad: 1 });
db.clientes.createIndex({ email: 1 }, { unique: true });
db.productos.createIndex({ categoria: 1, precio: -1 });

// Ver índices
db.clientes.getIndexes();

// Analizar consulta
db.clientes.find({ ciudad: "Madrid" }).explain("executionStats");

// Eliminar
db.clientes.dropIndex({ ciudad: 1 });
```

## 🎯 Ejemplos prácticos

### Contar clientes por ciudad

```javascript
db.clientes.aggregate([
    { $group: { _id: "$ciudad", total: { $sum: 1 } } },
    { $sort: { total: -1 } }
]);
```

### Productos más caros por categoría

```javascript
db.productos.aggregate([
    { $sort: { precio: -1 } },
    {
        $group: {
            _id: "$categoria",
            producto_top: { $first: "$nombre" },
            precio_max: { $first: "$precio" }
        }
    }
]);
```

### Total gastado por cliente

```javascript
db.pedidos.aggregate([
    { $unwind: "$productos" },
    {
        $group: {
            _id: "$cliente_id",
            total_gastado: {
                $sum: { $multiply: ["$productos.cantidad", "$productos.precio"] }
            }
        }
    },
    {
        $lookup: {
            from: "clientes",
            localField: "_id",
            foreignField: "_id",
            as: "cliente"
        }
    },
    { $unwind: "$cliente" },
    { $project: { _id: 0, cliente: "$cliente.nombre", total_gastado: 1 } },
    { $sort: { total_gastado: -1 } }
]);
```

## ⚠️ Errores comunes

- Modelar como SQL (todo referenciado)
- No usar índices en consultas frecuentes
- Hacer `$lookup` en exceso (mejor embeber)
- Arrays que crecen sin límite
- No usar proyección cuando solo necesitas 2 campos
- Ignorar el orden de las etapas del pipeline (match primero)

## ✅ Ejercicios

1. Inserta 3 clientes nuevos
2. Busca clientes de Madrid mayores de 25
3. Actualiza el precio de todos los productos de 'Ropa' +5%
4. Elimina pedidos con estado "cancelado"
5. Cuenta cuántos productos hay por categoría (aggregation)
6. Top 3 productos más caros
7. Total gastado por cliente (con `$lookup`)
8. Crea un índice en `clientes.ciudad` y verifica con `explain`
9. Encuentra clientes sin email (`$exists` o null)
10. Productos con tag "accesorio"

## 🔗 Recursos

- [MongoDB Manual](https://www.mongodb.com/docs/manual/)
- [MongoDB University (gratis)](https://learn.mongodb.com/)