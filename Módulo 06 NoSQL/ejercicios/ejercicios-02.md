# 🧪 Ejercicios - MongoDB

> Carga el dataset: `mongosh < ../../recursos/datasets/tienda-nosql.js`

## Nivel 🟢 Fácil

### 1. Insertar
Inserta 3 clientes nuevos.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.insertMany([
    { _id: 11, nombre: "Laura Gil", email: "laura@x.com", ciudad: "Madrid", edad: 27 },
    { _id: 12, nombre: "Raúl Vega", email: "raul@x.com", ciudad: "Zaragoza", edad: 32 },
    { _id: 13, nombre: "Nuria Pinto", email: "nuria@x.com", ciudad: "Sevilla", edad: 29 }
]);
```
</details>

### 2. Buscar
Clientes de Madrid.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.find({ ciudad: "Madrid" });
```
</details>

### 3. Filtrar por rango
Productos entre 50 y 200 €.

<details>
<summary>💡 Solución</summary>

```javascript
db.productos.find({ precio: { $gte: 50, $lte: 200 } });
```
</details>

---

## Nivel 🟡 Intermedio

### 4. Actualizar varios
Sube 10% el precio a productos de 'Electrónica'.

<details>
<summary>💡 Solución</summary>

```javascript
db.productos.updateMany(
    { categoria: "Electrónica" },
    { $mul: { precio: 1.10 } }
);
```
</details>

### 5. Filtro OR
Clientes de Madrid o Barcelona, mayores de 25.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.find({
    ciudad: { $in: ["Madrid", "Barcelona"] },
    edad: { $gt: 25 }
});
```
</details>

### 6. Campos anidados
Clientes que quieren newsletter.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.find({ "preferencias.newsletter": true });
```
</details>

### 7. Arrays
Productos con tag "accesorio".

<details>
<summary>💡 Solución</summary>

```javascript
db.productos.find({ tags: "accesorio" });
```
</details>

---

## Nivel 🔴 Difícil

### 8. Group by
Contar productos por categoría.

<details>
<summary>💡 Solución</summary>

```javascript
db.productos.aggregate([
    { $group: { _id: "$categoria", total: { $sum: 1 } } },
    { $sort: { total: -1 } }
]);
```
</details>

### 9. Top 3 más caros
Los 3 productos más caros.

<details>
<summary>💡 Solución</summary>

```javascript
db.productos.find().sort({ precio: -1 }).limit(3);
```
</details>

### 10. Total gastado por cliente
Con `$lookup` de `pedidos` a `clientes`.

<details>
<summary>💡 Solución</summary>

```javascript
db.pedidos.aggregate([
    { $unwind: "$productos" },
    {
        $group: {
            _id: "$cliente_id",
            total: { $sum: { $multiply: ["$productos.cantidad", "$productos.precio"] } }
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
    { $project: { _id: 0, nombre: "$cliente.nombre", total: 1 } },
    { $sort: { total: -1 } }
]);
```
</details>

### 11. Índice
Crea un índice en `clientes.ciudad`.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.createIndex({ ciudad: 1 });

// Verificar
db.clientes.find({ ciudad: "Madrid" }).explain("executionStats");
```
</details>

### 12. Clientes sin email
Clientes donde `email` es null o no existe.

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.find({ email: null });
// o
db.clientes.find({ email: { $exists: false } });
```
</details>

### 13. Regex
Clientes cuyo nombre empiece por "A".

<details>
<summary>💡 Solución</summary>

```javascript
db.clientes.find({ nombre: /^A/ });
```
</details>

### 14. Productos más vendidos
Top 3 productos por cantidad vendida.

<details>
<summary>💡 Solución</summary>

```javascript
db.pedidos.aggregate([
    { $unwind: "$productos" },
    {
        $group: {
            _id: "$productos.producto_id",
            cantidad_total: { $sum: "$productos.cantidad" }
        }
    },
    { $sort: { cantidad_total: -1 } },
    { $limit: 3 },
    {
        $lookup: {
            from: "productos",
            localField: "_id",
            foreignField: "_id",
            as: "producto"
        }
    },
    { $unwind: "$producto" },
    { $project: { nombre: "$producto.nombre", cantidad_total: 1 } }
]);
```
</details>

### 15. Ventas por mes
Total facturado por mes.

<details>
<summary>💡 Solución</summary>

```javascript
db.pedidos.aggregate([
    { $unwind: "$productos" },
    {
        $group: {
            _id: {
                anio: { $year: "$fecha" },
                mes: { $month: "$fecha" }
            },
            total: { $sum: { $multiply: ["$productos.cantidad", "$productos.precio"] } }
        }
    },
    { $sort: { "_id.anio": 1, "_id.mes": 1 } }
]);
```
</details>