# 🔍 Consultas Clave - Red Social

Consultas que cruzan PostgreSQL, MongoDB y Redis.

## 📊 PostgreSQL

### 1. Perfil completo de un usuario

```sql
SELECT 
    u.id,
    u.username,
    u.email,
    p.nombre,
    p.bio,
    p.avatar_url,
    p.ubicacion,
    (SELECT COUNT(*) FROM follows WHERE seguido_id = u.id) AS seguidores,
    (SELECT COUNT(*) FROM follows WHERE seguidor_id = u.id) AS siguiendo,
    (SELECT COUNT(*) FROM follows WHERE seguido_id = u.id AND seguidor_id = 1) > 0 AS yo_sigo
FROM usuarios u
LEFT JOIN perfiles p ON u.id = p.usuario_id
WHERE u.id = 1;
```

### 2. ¿A quién sigo pero no me sigue? (no recíproco)

```sql
SELECT u.id, u.username
FROM usuarios u
JOIN follows f ON u.id = f.seguido_id
WHERE f.seguidor_id = 1
  AND NOT EXISTS (
    SELECT 1 FROM follows f2
    WHERE f2.seguidor_id = u.id AND f2.seguido_id = 1
  );
```

### 3. Amigos mutuos

```sql
SELECT u.id, u.username
FROM usuarios u
WHERE EXISTS (
    SELECT 1 FROM follows f1 
    WHERE f1.seguidor_id = 1 AND f1.seguido_id = u.id
)
AND EXISTS (
    SELECT 1 FROM follows f2 
    WHERE f2.seguidor_id = u.id AND f2.seguido_id = 1
)
AND u.id != 1;
```

### 4. Sugerencias de amistad (amigos de amigos)

```sql
WITH yo_sigo AS (
    SELECT seguido_id FROM follows WHERE seguidor_id = 1
),
amigos_de_amigos AS (
    SELECT f.seguido_id, COUNT(*) AS amigos_en_comun
    FROM follows f
    WHERE f.seguidor_id IN (SELECT seguido_id FROM yo_sigo)
      AND f.seguido_id != 1
      AND f.seguido_id NOT IN (SELECT seguido_id FROM yo_sigo)
    GROUP BY f.seguido_id
)
SELECT 
    u.id,
    u.username,
    a.amigos_en_comun
FROM amigos_de_amigos a
JOIN usuarios u ON a.seguido_id = u.id
WHERE u.activo = TRUE
ORDER BY amigos_en_comun DESC
LIMIT 10;
```

### 5. Notificaciones no leídas

```sql
SELECT 
    n.id,
    n.tipo,
    u.username AS actor,
    n.contenido,
    n.fecha
FROM notificaciones n
LEFT JOIN usuarios u ON n.actor_id = u.id
WHERE n.usuario_id = 1 AND n.leida = FALSE
ORDER BY n.fecha DESC
LIMIT 50;
```

## 📊 MongoDB

### 6. Posts de un usuario con stats actualizados

```javascript
const postIds = db.posts
    .find({ usuario_id: 1 })
    .sort({ fecha: -1 })
    .limit(20)
    .map(p => p._id);

// Enriquecer con stats de Redis
const posts = db.posts.find({ _id: { $in: postIds } }).toArray();
```

### 7. Posts con hashtags populares

```javascript
db.posts.aggregate([
    { $match: { fecha: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } } },
    { $unwind: "$hashtags" },
    { $group: {
        _id: "$hashtags",
        posts: { $sum: 1 },
        likes_total: { $sum: "$stats.likes" }
    }},
    { $sort: { posts: -1 } },
    { $limit: 10 }
]);
```

### 8. Posts con más engagement

```javascript
db.posts.aggregate([
    {
        $addFields: {
            engagement: {
                $add: [
                    "$stats.likes",
                    { $multiply: ["$stats.comentarios", 2] },
                    { $multiply: ["$stats.compartidos", 3] }
                ]
            }
        }
    },
    { $sort: { engagement: -1 } },
    { $limit: 10 },
    { $project: { contenido: 1, usuario_id: 1, engagement: 1, stats: 1 } }
]);
```

### 9. Comentarios con respuestas (threading)

```javascript
const postId = ObjectId("...");

// Comentarios raíz
const raices = db.comentarios.find({ 
    post_id: postId, 
    padre_id: null 
}).sort({ fecha: 1 }).toArray();

// Respuestas por cada raíz
const threads = raices.map(r => ({
    ...r,
    respuestas: db.comentarios.find({ 
        padre_id: r._id 
    }).sort({ fecha: 1 }).toArray()
}));
```

### 10. Posts por ubicación

```javascript
db.posts.find({
    "ubicacion.nombre": "Madrid",
    fecha: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
}).sort({ fecha: -1 }).limit(20);
```

### 11. Conversaciones de un usuario

```javascript
db.mensajes.aggregate([
    {
        $match: {
            $or: [
                { emisor_id: 1 },
                { receptor_id: 1 }
            ]
        }
    },
    {
        $group: {
            _id: "$conversacion_id",
            ultimo_mensaje: { $last: "$contenido" },
            fecha: { $max: "$fecha" },
            no_leidos: {
                $sum: {
                    $cond: [
                        { $and: [
                            { $eq: ["$receptor_id", 1] },
                            { $eq: ["$leido", false] }
                        ]},
                        1,
                        0
                    ]
                }
            }
        }
    },
    { $sort: { fecha: -1 } }
]);
```

## 📊 Redis

### 12. Feed del usuario (últimos 20)

```redis
LRANGE feed:1 0 19
```

### 13. ¿Le di like a este post?

```redis
SISMEMBER likes:post:123 1
# 1 = sí, 0 = no
```

### 14. Contadores en tiempo real

```redis
MGET stats:post:123:likes stats:post:123:comentarios stats:post:123:compartidos
```

### 15. Trending posts

```redis
ZREVRANGE trending:global 0 9 WITHSCORES
```

### 16. ¿Está online?

```redis
EXISTS online:1
```

### 17. Rate limiting

```redis
GET rate:user:1:minute
```

## 🔄 Consultas cross-DB

### 18. Feed enriquecido (Redis + MongoDB + PostgreSQL)

**Paso 1 - Redis:**
```redis
LRANGE feed:1 0 19
# → ["post:123", "post:456", ...]
```

**Paso 2 - MongoDB:**
```javascript
const postIds = ["post:123", "post:456"].map(p => ObjectId(p.replace("post:", "")));
const posts = db.posts.find({ _id: { $in: postIds } }).toArray();
```

**Paso 3 - Redis (stats):**
```redis
MGET stats:post:123:likes stats:post:123:comentarios \
     stats:post:456:likes stats:post:456:comentarios
```

**Paso 4 - PostgreSQL (autores):**
```sql
SELECT id, username, p.nombre, p.avatar_url
FROM usuarios u
LEFT JOIN perfiles p ON u.id = p.usuario_id
WHERE u.id IN (1, 2, 3);
```

**Resultado final:**
```json
[
    {
        "id": "post:123",
        "contenido": "...",
        "autor": { "id": 1, "username": "ana", "avatar": "..." },
        "stats": { "likes": 42, "comentarios": 8 },
        "fecha": "2024-03-15T10:30:00Z",
        "le_guste": true
    }
]
```

### 19. Detalle de un post

```python
def get_post_detalle(post_id, usuario_id):
    # MongoDB: post + comentarios
    post = mongo.posts.find_one({"_id": ObjectId(post_id)})
    comentarios = list(mongo.comentarios.find({"post_id": ObjectId(post_id)}).sort("fecha", 1))
    
    # Redis: stats y likes
    pipe = redis.pipeline()
    pipe.get(f"stats:post:{post_id}:likes")
    pipe.get(f"stats:post:{post_id}:comentarios")
    pipe.sismember(f"likes:{post_id}", usuario_id)
    stats = pipe.execute()
    
    # PostgreSQL: autor
    autor = pg.query_one("""
        SELECT u.id, u.username, p.nombre, p.avatar_url
        FROM usuarios u
        LEFT JOIN perfiles p ON u.id = p.usuario_id
        WHERE u.id = %s
    """, post["usuario_id"])
    
    return {
        **post,
        "stats": {
            "likes": int(stats[0] or 0),
            "comentarios": int(stats[1] or 0)
        },
        "le_guste": bool(stats[2]),
        "autor": autor,
        "comentarios": comentarios
    }
```

### 20. Notificaciones en tiempo real (contador)

```python
def contar_no_leidas(usuario_id):
    # Redis (rápido)
    count = redis.get(f"notif:{usuario_id}:no_leidas")
    if count is not None:
        return int(count)
    
    # Fallback a PostgreSQL
    count = pg.query_one("""
        SELECT COUNT(*) FROM notificaciones
        WHERE usuario_id = %s AND leida = FALSE
    """, usuario_id)
    
    redis.setex(f"notif:{usuario_id}:no_leidas", 300, count)
    return count
```

## 🎯 Patrones de consulta por caso de uso

| Caso de uso | Fuente principal | Caché |
|-------------|------------------|-------|
| Perfil de usuario | PostgreSQL | Redis (5 min) |
| Feed personal | Redis | — |
| Detalle de post | MongoDB | Redis (stats) |
| Comentarios | MongoDB | — |
| Trending | Redis | — |
| Búsqueda full-text | MongoDB (text index) | — |
| Sugerencias de amistad | PostgreSQL | Redis (1 hora) |
| Notificaciones | PostgreSQL | Redis (contador) |
| Presencia online | Redis | — |
| Mensajes | MongoDB | — |

## ⚠️ Consideraciones

- **Siempre** filtrar bloqueados en lectura, no solo en escritura
- **Siempre** tener fallback a SQL/Mongo si Redis falla
- **No** confiar en Redis para datos críticos
- **Sí** usar Redis para datos efímeros y cacheables
- **Documentar** qué BD es la fuente de verdad para cada dato