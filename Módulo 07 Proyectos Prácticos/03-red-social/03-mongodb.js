// ============================================
// Red Social - MongoDB
// Ejecutar en mongosh
// ============================================

use red_social;

db.posts.drop();
db.comentarios.drop();
db.mensajes.drop();

// ============================================
// COLECCIÓN: POSTS
// ============================================

db.createCollection("posts", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["usuario_id", "contenido", "fecha"],
            properties: {
                usuario_id: { bsonType: "int" },
                contenido: { bsonType: "string", maxLength: 5000 },
                imagenes: { bsonType: "array" },
                hashtags: { bsonType: "array" },
                menciones: { bsonType: "array" },
                visibilidad: { 
                    enum: ["publico", "seguidores", "privado"] 
                },
                stats: {
                    bsonType: "object",
                    properties: {
                        likes: { bsonType: "int" },
                        comentarios: { bsonType: "int" },
                        compartidos: { bsonType: "int" }
                    }
                },
                fecha: { bsonType: "date" }
            }
        }
    }
});

// Índices
db.posts.createIndex({ usuario_id: 1, fecha: -1 });
db.posts.createIndex({ hashtags: 1 });
db.posts.createIndex({ fecha: -1 });
db.posts.createIndex({ "ubicacion.nombre": 1 });
db.posts.createIndex({ contenido: "text" });  // full-text

// ============================================
// COLECCIÓN: COMENTARIOS
// ============================================

db.createCollection("comentarios");

db.comentarios.createIndex({ post_id: 1, fecha: -1 });
db.comentarios.createIndex({ usuario_id: 1 });
db.comentarios.createIndex({ padre_id: 1 });

// ============================================
// COLECCIÓN: MENSAJES
// ============================================

db.createCollection("mensajes");

db.mensajes.createIndex({ conversacion_id: 1, fecha: -1 });
db.mensajes.createIndex({ emisor_id: 1 });
db.mensajes.createIndex({ receptor_id: 1, leido: 1 });

// ============================================
// DATOS DE PRUEBA
// ============================================

const ahora = new Date();

db.posts.insertMany([
    {
        usuario_id: 1,
        contenido: "¡Mi primer post en la red social! 🎉",
        imagenes: [],
        hashtags: ["#bienvenida", "#primerpost"],
        menciones: [],
        visibilidad: "publico",
        stats: { likes: 5, comentarios: 2, compartidos: 0 },
        fecha: new Date(ahora - 2 * 60 * 60 * 1000)
    },
    {
        usuario_id: 2,
        contenido: "Aprendiendo MongoDB, ¡qué potencia!",
        imagenes: [{ url: "https://example.com/mongo.jpg", alt: "MongoDB" }],
        hashtags: ["#mongodb", "#nosql"],
        menciones: [1],
        visibilidad: "publico",
        stats: { likes: 12, comentarios: 4, compartidos: 2 },
        fecha: new Date(ahora - 5 * 60 * 60 * 1000)
    },
    {
        usuario_id: 1,
        contenido: "Probando consultas de aggregation",
        imagenes: [],
        hashtags: ["#mongodb", "#aggregation"],
        menciones: [],
        visibilidad: "seguidores",
        stats: { likes: 3, comentarios: 1, compartidos: 0 },
        fecha: new Date(ahora - 24 * 60 * 60 * 1000)
    },
    {
        usuario_id: 3,
        contenido: "Post sobre Redis y caché de feeds",
        imagenes: [],
        hashtags: ["#redis", "#cache"],
        menciones: [],
        visibilidad: "publico",
        ubicacion: { nombre: "Madrid", lat: 40.4168, lng: -3.7038 },
        stats: { likes: 8, comentarios: 3, compartidos: 1 },
        fecha: new Date(ahora - 3 * 24 * 60 * 60 * 1000)
    }
]);

db.comentarios.insertMany([
    {
        post_id: db.posts.findOne({ "contenido": /primer post/ })._id,
        usuario_id: 2,
        contenido: "¡Bienvenida Ana!",
        padre_id: null,
        likes: 2,
        fecha: new Date(ahora - 1 * 60 * 60 * 1000)
    },
    {
        post_id: db.posts.findOne({ "contenido": /primer post/ })._id,
        usuario_id: 3,
        contenido: "Genial! 🎊",
        padre_id: null,
        likes: 1,
        fecha: new Date(ahora - 30 * 60 * 1000)
    },
    {
        post_id: db.posts.findOne({ "contenido": /MongoDB/ })._id,
        usuario_id: 1,
        contenido: "Totalmente de acuerdo",
        padre_id: null,
        likes: 0,
        fecha: new Date(ahora - 2 * 60 * 60 * 1000)
    }
]);

// ============================================
// CONSULTAS DE EJEMPLO
// ============================================

// 1. Posts recientes de un usuario
db.posts.find({ usuario_id: 1 }).sort({ fecha: -1 }).limit(10);

// 2. Posts con un hashtag
db.posts.find({ hashtags: "#mongodb" }).sort({ fecha: -1 });

// 3. Posts con likes > 5
db.posts.find({ "stats.likes": { $gt: 5 } }).sort({ fecha: -1 });

// 4. Búsqueda full-text
db.posts.find({ $text: { $search: "mongodb" } });

// 5. Posts con imágenes
db.posts.find({ "imagenes.0": { $exists: true } });

// 6. Comentarios de un post
db.comentarios.find({ post_id: ObjectId("...") }).sort({ fecha: -1 });

// 7. Top 5 posts con más likes (aggregation)
db.posts.aggregate([
    { $sort: { "stats.likes": -1 } },
    { $limit: 5 },
    { $project: { usuario_id: 1, contenido: 1, "stats.likes": 1 } }
]);

// 8. Hashtags más usados
db.posts.aggregate([
    { $unwind: "$hashtags" },
    { $group: { _id: "$hashtags", total: { $sum: 1 } } },
    { $sort: { total: -1 } },
    { $limit: 10 }
]);

// 9. Posts por mes
db.posts.aggregate([
    {
        $group: {
            _id: {
                anio: { $year: "$fecha" },
                mes: { $month: "$fecha" }
            },
            total: { $sum: 1 }
        }
    },
    { $sort: { "_id.anio": -1, "_id.mes": -1 } }
]);

print("✅ Red social cargada en MongoDB");
print("  Posts: " + db.posts.countDocuments());
print("  Comentarios: " + db.comentarios.countDocuments());