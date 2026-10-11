// ============================================
// Dataset NoSQL: Tienda
// Ejecutar en mongosh
// ============================================

use tienda_nosql;

// Limpiar colecciones
db.clientes.drop();
db.productos.drop();
db.pedidos.drop();

// ============ CLIENTES ============
db.clientes.insertMany([
    {
        _id: 1,
        nombre: "Ana García",
        email: "ana@mail.com",
        ciudad: "Madrid",
        edad: 28,
        fecha_registro: ISODate("2023-01-15"),
        preferencias: { newsletter: true, idioma: "es" }
    },
    {
        _id: 2,
        nombre: "Luis Pérez",
        email: "luis@mail.com",
        ciudad: "Barcelona",
        edad: 34,
        fecha_registro: ISODate("2023-02-20"),
        preferencias: { newsletter: false, idioma: "es" }
    },
    {
        _id: 3,
        nombre: "Marta López",
        email: "marta@mail.com",
        ciudad: "Madrid",
        edad: 25,
        fecha_registro: ISODate("2023-03-05"),
        preferencias: { newsletter: true, idioma: "ca" }
    },
    {
        _id: 4,
        nombre: "Carlos Ruiz",
        email: "carlos@mail.com",
        ciudad: "Valencia",
        edad: 41,
        fecha_registro: ISODate("2023-03-22"),
        preferencias: { newsletter: true, idioma: "es" }
    },
    {
        _id: 5,
        nombre: "Elena Sanz",
        email: "elena@mail.com",
        ciudad: "Sevilla",
        edad: 30,
        fecha_registro: ISODate("2023-04-10"),
        preferencias: { newsletter: false, idioma: "es" }
    },
    {
        _id: 6,
        nombre: "Javier Mora",
        email: "javier@mail.com",
        ciudad: "Madrid",
        edad: 22,
        fecha_registro: ISODate("2023-05-01"),
        preferencias: { newsletter: true, idioma: "es" }
    },
    {
        _id: 7,
        nombre: "Lucía Torres",
        email: "lucia@mail.com",
        ciudad: "Bilbao",
        edad: 37,
        fecha_registro: ISODate("2023-05-18"),
        preferencias: { newsletter: true, idioma: "eu" }
    },
    {
        _id: 8,
        nombre: "Pedro Vidal",
        email: null,
        ciudad: "Barcelona",
        edad: 29,
        fecha_registro: ISODate("2023-06-02"),
        preferencias: { newsletter: false, idioma: "es" }
    },
    {
        _id: 9,
        nombre: "Sara Núñez",
        email: "sara@mail.com",
        ciudad: "Madrid",
        edad: 33,
        fecha_registro: ISODate("2023-06-25"),
        preferencias: { newsletter: true, idioma: "es" }
    },
    {
        _id: 10,
        nombre: "Diego Romero",
        email: "diego@mail.com",
        ciudad: "Valencia",
        edad: 26,
        fecha_registro: ISODate("2023-07-14"),
        preferencias: { newsletter: false, idioma: "es" }
    }
]);

// ============ PRODUCTOS ============
db.productos.insertMany([
    { _id: 1,  nombre: "Laptop Pro 15",      categoria: "Electrónica", precio: 1200.00, stock: 15, tags: ["laptop", "premium"] },
    { _id: 2,  nombre: "Mouse Inalámbrico",  categoria: "Electrónica", precio: 25.50,   stock: 100, tags: ["accesorio"] },
    { _id: 3,  nombre: "Teclado Mecánico",   categoria: "Electrónica", precio: 89.99,   stock: 45, tags: ["accesorio", "gaming"] },
    { _id: 4,  nombre: "Monitor 27\"",       categoria: "Electrónica", precio: 320.00,  stock: 20, tags: ["monitor"] },
    { _id: 5,  nombre: "Silla Ergonómica",   categoria: "Muebles",     precio: 250.00,  stock: 10, tags: ["oficina"] },
    { _id: 6,  nombre: "Escritorio Madera",  categoria: "Muebles",     precio: 180.00,  stock: 8,  tags: ["oficina"] },
    { _id: 7,  nombre: "Lámpara LED",        categoria: "Muebles",     precio: 45.00,   stock: 30, tags: ["iluminacion"] },
    { _id: 8,  nombre: "Camiseta Básica",    categoria: "Ropa",        precio: 15.99,   stock: 200, tags: ["basico"] },
    { _id: 9,  nombre: "Zapatillas Running", categoria: "Ropa",        precio: 75.00,   stock: 60, tags: ["deporte"] },
    { _id: 10, nombre: "Mochila Urban",      categoria: "Ropa",        precio: 55.00,   stock: 40, tags: ["accesorio"] },
    { _id: 11, nombre: "Cafetera Express",   categoria: "Hogar",       precio: 150.00,  stock: 25, tags: ["cocina"] },
    { _id: 12, nombre: "Set Sartenes",       categoria: "Hogar",       precio: 80.00,   stock: 35, tags: ["cocina"] }
]);

// ============ PEDIDOS ============
db.pedidos.insertMany([
    { _id: 1,  cliente_id: 1,  productos: [{ producto_id: 1, cantidad: 1, precio: 1200.00 }], fecha: ISODate("2024-01-10"), estado: "entregado" },
    { _id: 2,  cliente_id: 1,  productos: [{ producto_id: 2, cantidad: 2, precio: 25.50 }],   fecha: ISODate("2024-01-10"), estado: "entregado" },
    { _id: 3,  cliente_id: 2,  productos: [{ producto_id: 3, cantidad: 1, precio: 89.99 }],   fecha: ISODate("2024-01-15"), estado: "entregado" },
    { _id: 4,  cliente_id: 3,  productos: [{ producto_id: 5, cantidad: 1, precio: 250.00 }],  fecha: ISODate("2024-01-20"), estado: "entregado" },
    { _id: 5,  cliente_id: 3,  productos: [{ producto_id: 2, cantidad: 1, precio: 25.50 }],   fecha: ISODate("2024-01-20"), estado: "entregado" },
    { _id: 6,  cliente_id: 4,  productos: [{ producto_id: 4, cantidad: 2, precio: 320.00 }],  fecha: ISODate("2024-02-01"), estado: "entregado" },
    { _id: 7,  cliente_id: 5,  productos: [{ producto_id: 8, cantidad: 3, precio: 15.99 }],   fecha: ISODate("2024-02-05"), estado: "entregado" },
    { _id: 8,  cliente_id: 6,  productos: [{ producto_id: 9, cantidad: 1, precio: 75.00 }],   fecha: ISODate("2024-02-10"), estado: "entregado" },
    { _id: 9,  cliente_id: 7,  productos: [{ producto_id: 11, cantidad: 1, precio: 150.00 }], fecha: ISODate("2024-02-15"), estado: "entregado" },
    { _id: 10, cliente_id: 8,  productos: [{ producto_id: 12, cantidad: 2, precio: 80.00 }],  fecha: ISODate("2024-02-20"), estado: "enviado" },
    { _id: 11, cliente_id: 9,  productos: [{ producto_id: 1, cantidad: 1, precio: 1200.00 }], fecha: ISODate("2024-03-01"), estado: "enviado" },
    { _id: 12, cliente_id: 9,  productos: [{ producto_id: 7, cantidad: 2, precio: 45.00 }],   fecha: ISODate("2024-03-01"), estado: "enviado" },
    { _id: 13, cliente_id: 10, productos: [{ producto_id: 3, cantidad: 1, precio: 89.99 }],   fecha: ISODate("2024-03-05"), estado: "pendiente" },
    { _id: 14, cliente_id: 2,  productos: [{ producto_id: 10, cantidad: 1, precio: 55.00 }],  fecha: ISODate("2024-03-10"), estado: "pendiente" },
    { _id: 15, cliente_id: 4,  productos: [{ producto_id: 6, cantidad: 1, precio: 180.00 }],  fecha: ISODate("2024-03-15"), estado: "pendiente" }
]);

print("✅ Dataset cargado:");
print("  Clientes: " + db.clientes.countDocuments());
print("  Productos: " + db.productos.countDocuments());
print("  Pedidos: " + db.pedidos.countDocuments());