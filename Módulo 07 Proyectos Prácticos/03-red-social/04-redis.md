# 🔴 Redis en la Red Social

## 🎯 Estructuras y patrones

### 1. Feed personal (List)

```
feed:{usuario_id}  →  List
  [post_id_1, post_id_2, post_id_3, ...]
```

**Operaciones:**

```redis
# Al publicar un post, añadir al feed de cada seguidor
LPUSH feed:1 "post:123"
LPUSH feed:1 "post:124"

# Mantener solo 1000 más recientes
LTRIM feed:1 0 999

# Leer feed (últimos 20)
LRANGE feed:1 0 19

# TTL de 7 días
EXPIRE feed:1 604800
```

### 2. Likes por post (Set)

```
likes:{post_id}  →  Set de user_ids
```

**Operaciones:**

```redis
# Dar like (idempotente)
SADD likes:123 1 2 3
SISMEMBER likes:123 1    # ¿Le dio like el user 1?
SCARD likes:123          # ¿Cuántos likes?
SREM likes:123 1         # Quitar like
```

**Ventaja:** el Set garantiza que no haya likes duplicados.

### 3. Contadores (String)

```
stats:post:{post_id}:likes        →  String (int)
stats:post:{post_id}:comentarios  →  String
stats:post:{post_id}:compartidos  →  String
stats:user:{user_id}:seguidores   →  String
```

**Operaciones:**

```redis
INCR stats:post:123:likes
DECR stats:post:123:likes
INCRBY stats:post:123:likes 5
GET stats:post:123:likes
```

### 4. Sesiones (Hash)

```
sesion:{token}  →  Hash
  ├── usuario_id → 1
  ├── username   → "ana"
  └── expira     → "2024-12-31"
```

**Operaciones:**

```redis
HSET sesion:abc123 usuario_id 1 username "ana"
EXPIRE sesion:abc123 86400     # 24h

HGET sesion:abc123 usuario_id  # 1
EXISTS sesion:abc123           # 1

# Logout
DEL sesion:abc123
```

### 5. Presencia online (String con TTL)

```
online:{usuario_id}  →  String con timestamp
```

**Operaciones:**

```redis
# Cada vez que el usuario hace algo
SETEX online:1 300 "2024-03-15T10:30:00"

# ¿Está online?
EXISTS online:1

# Listar online
KEYS online:*
```

### 6. Notificaciones no leídas (String)

```
notif:{usuario_id}:no_leidas  →  Contador
```

```redis
INCR notif:1:no_leidas
SET notif:1:no_leidas 0     # al leer todas
```

### 7. Posts populares (Sorted Set)

```
trending:posts  →  Sorted Set con score = engagement
```

**Operaciones:**

```redis
# Score = likes + comentarios*2 + compartidos*3
ZINCRBY trending:posts 1 "post:123"
ZINCRBY trending:posts 2 "post:124"

# Top 10 trending
ZREVRANGE trending:posts 0 9 WITHSCORES
```

### 8. Rate limiting (String)

```redis
# Máximo 100 acciones por minuto
INCR rate:user:1:minute
EXPIRE rate:user:1:minute 60
```

## 🔄 Flujos completos

### Publicar un post

```python
def publicar_post(usuario_id, contenido):
    # 1. Guardar en MongoDB
    post_id = str(mongo.posts.insert_one({
        "usuario_id": usuario_id,
        "contenido": contenido,
        "fecha": datetime.now(),
        "stats": {"likes": 0, "comentarios": 0, "compartidos": 0}
    }).inserted_id)
    
    # 2. Obtener seguidores (PostgreSQL)
    seguidores = pg.query("SELECT seguidor_id FROM follows WHERE seguido_id = %s", usuario_id)
    
    # 3. Push al feed de cada seguidor
    pipe = redis.pipeline()
    for seguidor in seguidores:
        pipe.lpush(f"feed:{seguidor.seguidor_id}", f"post:{post_id}")
        pipe.ltrim(f"feed:{seguidor.seguidor_id}", 0, 999)
        pipe.expire(f"feed:{seguidor.seguidor_id}", 604800)
    pipe.execute()
    
    # 4. Añadir también al feed propio
    redis.lpush(f"feed:{usuario_id}", f"post:{post_id}")
    
    return post_id
```

### Dar like

```python
def dar_like(usuario_id, post_id):
    # 1. Set (evita duplicados)
    added = redis.sadd(f"likes:{post_id}", usuario_id)
    
    if added:
        # 2. Contador
        redis.incr(f"stats:post:{post_id}:likes")
        
        # 3. Trending
        redis.zincrby("trending:posts", 1, f"post:{post_id}")
        
        # 4. Notificación (a PostgreSQL)
        autor_id = mongo.posts.find_one({"_id": ObjectId(post_id)})["usuario_id"]
        if autor_id != usuario_id:
            pg.execute("""
                INSERT INTO notificaciones (usuario_id, tipo, actor_id, referencia_id)
                VALUES (%s, 'like', %s, %s)
            """, autor_id, usuario_id, post_id)
```

### Ver feed

```python
def ver_feed(usuario_id, offset=0, limit=20):
    # 1. Obtener IDs de Redis
    post_ids = redis.lrange(f"feed:{usuario_id}", offset, offset + limit - 1)
    
    if not post_ids:
        # Fallback a consulta directa
        return build_feed_from_sql(usuario_id)
    
    # 2. Quitar prefijo "post:"
    ids = [pid.replace("post:", "") for pid in post_ids]
    
    # 3. Traer de MongoDB
    posts = list(mongo.posts.find({"_id": {"$in": [ObjectId(i) for i in ids]}}))
    
    # 4. Ordenar según Redis (que tiene el orden cronológico)
    posts_map = {str(p["_id"]): p for p in posts}
    ordered_posts = [posts_map[i] for i in ids if i in posts_map]
    
    # 5. Enriquecer con contadores actualizados de Redis
    pipe = redis.pipeline()
    for p in ordered_posts:
        pid = str(p["_id"])
        pipe.get(f"stats:post:{pid}:likes")
        pipe.get(f"stats:post:{pid}:comentarios")
    stats = pipe.execute()
    
    for i, p in enumerate(ordered_posts):
        p["stats"]["likes"] = int(stats[i*2] or 0)
        p["stats"]["comentarios"] = int(stats[i*2+1] or 0)
    
    return ordered_posts
```

## 🔄 Sincronización Redis → MongoDB

Los contadores en Redis son la "verdad" en tiempo real. Cada X minutos:

```python
def sincronizar_contadores():
    # Obtener todos los contadores de posts
    for key in redis.scan_iter("stats:post:*:likes"):
        post_id = key.decode().split(":")[2]
        likes = int(redis.get(key) or 0)
        
        mongo.posts.update_one(
            {"_id": ObjectId(post_id)},
            {"$set": {"stats.likes": likes}}
        )
```

## 🧹 Mantenimiento

### Feed de usuarios inactivos

Los feeds con TTL de 7 días se limpian solos. Si un usuario vuelve:
1. No hay feed en Redis
2. Se reconstruye desde SQL + Mongo (más lento, pero solo una vez)

### Likes huérfanos

Si un post se borra, sus likes quedan en Redis hasta que expiren.

**Solución:** al borrar, `DEL likes:{post_id}` y `DEL stats:post:{post_id}:*`.

### Trending

```redis
# Job cada hora: reducir scores viejos
ZREMRANGEBYSCORE trending:posts 0 100  # quitar de baja puntuación
```

## 🎯 Ventajas del diseño

| Operación | Sin Redis | Con Redis |
|-----------|-----------|-----------|
| Ver feed | JOIN + ORDER en SQL (100ms) | LRANGE (1ms) |
| Dar like | UPDATE contador (10ms) | INCR (0.1ms) |
| Trending | GROUP BY complejo | ZREVRANGE (1ms) |
| Sesiones | JOIN con tabla (5ms) | GET (0.1ms) |

## ⚠️ Errores comunes

- No poner TTL (memoria explota)
- Guardar el post completo en Redis (solo IDs)
- No tener fallback a SQL/Mongo
- No sincronizar contadores a Mongo
- Usar Redis como única fuente de verdad para datos críticos