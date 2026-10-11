# 📰 Diseño del Feed

## 🎯 Objetivo

Diseñar un feed escalable, rápido y consistente.

## 📊 Estrategias de feed

### 1. Fan-out on write (push)

Al publicar, se escribe en el feed de cada seguidor.

```python
def publicar_post(usuario_id, contenido):
    post_id = mongo.posts.insert_one({...}).inserted_id
    
    # Push a cada seguidor
    seguidores = pg.query("SELECT seguidor_id FROM follows WHERE seguido_id = %s", usuario_id)
    for seg in seguidores:
        redis.lpush(f"feed:{seg.seguidor_id}", f"post:{post_id}")
        redis.ltrim(f"feed:{seg.seguidor_id}", 0, 999)
```

**Ventajas:**
- Lectura instantánea (`LRANGE`)
- Feed ordenado listo para consumir

**Desventajas:**
- Costoso al publicar si tienes muchos seguidores
- Desperdicio si un seguidor nunca lee

### 2. Fan-out on read (pull)

Al leer, se consultan los posts de los seguidos.

```python
def get_feed(usuario_id):
    seguidos = pg.query("SELECT seguido_id FROM follows WHERE seguidor_id = %s", usuario_id)
    posts = mongo.posts.find({
        "usuario_id": {"$in": [s.seguido_id for s in seguidos]}
    }).sort("fecha", -1).limit(20)
    return posts
```

**Ventajas:**
- Escritura barata
- Sin desperdicio

**Desventajas:**
- Lectura lenta con muchos seguidos
- Requiere índice por `usuario_id + fecha`

### 3. Híbrido (recomendado)

- **Usuarios normales (< 10k seguidores):** push
- **Celebridades (> 10k seguidores):** pull

```python
def publicar_post(usuario_id, contenido):
    post_id = mongo.posts.insert_one({...}).inserted_id
    num_seguidores = pg.query("SELECT COUNT(*) FROM follows WHERE seguido_id = %s", usuario_id)
    
    if num_seguidores < 10000:
        # Push normal
        push_to_followers(usuario_id, post_id)
    else:
        # Solo actualizar contador (celebridad)
        redis.sadd("celebridades", usuario_id)
        # Sus seguidores lo leerán al vuelo
```

```python
def get_feed(usuario_id):
    # 1. Posts empujados (de usuarios normales)
    post_ids = redis.lrange(f"feed:{usuario_id}", 0, 19)
    
    # 2. Posts de celebridades que sigue
    celebridades = pg.query("""
        SELECT seguido_id FROM follows 
        WHERE seguidor_id = %s 
          AND seguido_id IN (SELECT * FROM celebridades_cache)
    """, usuario_id)
    
    posts_celebridades = mongo.posts.find({
        "usuario_id": {"$in": celebridades}
    }).sort("fecha", -1).limit(10)
    
    # 3. Mezclar y ordenar por fecha
    posts = mongo.posts.find({"_id": {"$in": post_ids}})
    return merge_and_sort(posts, posts_celebridades)
```

## 🎯 Estructuras en Redis

### Feed personal
```
feed:{usuario_id}  →  List de post_ids
```

### Feed "trending"
```
trending:{categoria}  →  Sorted Set (score = engagement)
trending:global       →  Sorted Set
```

### Posts vistos por usuario (evitar repetir)
```
vistos:{usuario_id}  →  Set de post_ids (TTL 7 días)
```

## 📈 Score de relevancia

Para el feed "explorar" o "trending":

```python
def calcular_score(post):
    # Factores
    likes = post["stats"]["likes"]
    comentarios = post["stats"]["comentarios"]
    compartidos = post["stats"]["compartidos"]
    
    # Antigüedad (decae con el tiempo)
    horas = (now() - post["fecha"]).total_seconds() / 3600
    factor_tiempo = 1 / (1 + horas / 24)
    
    # Score
    score = (likes + comentarios * 2 + compartidos * 3) * factor_tiempo
    
    return score
```

Actualizar en Redis:

```redis
ZADD trending:global {score} "post:{id}"
```

## 🔄 Flujos completos

### Publicar

```
1. Validar sesión
2. Insertar en MongoDB (posts)
3. Contar seguidores
4. Si < 10k:
     Redis: LPUSH feed:{seguidor} post_id (para cada uno)
     Redis: LTRIM feed:{seguidor} 0 999
   Si >= 10k:
     Redis: SADD celebridades post_id
5. Añadir a trending con score inicial
6. Notificar a menciones
7. Redis: INCR stats:user:{id}:posts
```

### Leer feed

```
1. Redis: LRANGE feed:{usuario} 0 19
2. Si vacío:
     Reconstruir desde SQL + Mongo
     Redis: RPUSH feed:{usuario} ... (para próxima vez)
3. Mongo: find({_id: {$in: post_ids}})
4. Ordenar según Redis (cronológico)
5. Enriquecer con contadores de Redis
6. Enriquecer con info de autores (cache)
7. Filtrar bloqueados y posts vistos
8. Devolver 20
```

### Infinite scroll

```
GET /feed?cursor=post:123

1. Redis: buscar posición de "post:123" en el feed
2. LRANGE feed:{usuario} {pos+1} {pos+20}
3. Devolver junto con nuevo cursor
```

## 🎯 Paginación con cursor

**Offset (malo para feeds grandes):**
```redis
LRANGE feed:1 100 119
```

**Cursor (mejor):**
```
Cliente envía: last_seen_post_id
Servidor:
  1. Localiza posición en el feed
  2. Devuelve siguientes 20
  3. Devuelve nuevo cursor (último post_id)
```

## 🧹 Mantenimiento

### Limpiar feeds inactivos

```python
# Jobs nocturnos
def limpiar_feeds_viejos():
    for key in redis.scan_iter("feed:*"):
        usuario_id = key.decode().split(":")[1]
        ultima_actividad = pg.query(
            "SELECT ultima_conexion FROM usuarios WHERE id = %s", usuario_id
        )
        if (now() - ultima_actividad).days > 30:
            redis.delete(key)
```

### Reconstruir feeds

Si Redis se reinicia, los feeds se reconstruyen on-demand:

```python
def rebuild_feed(usuario_id):
    seguidos = pg.query("SELECT seguido_id FROM follows WHERE seguidor_id = %s", usuario_id)
    posts = mongo.posts.find({
        "usuario_id": {"$in": [s.seguido_id for s in seguidos]}
    }).sort("fecha", -1).limit(1000)
    
    pipe = redis.pipeline()
    pipe.delete(f"feed:{usuario_id}")
    for p in reversed(list(posts)):  # LPUSH añade al principio
        pipe.lpush(f"feed:{usuario_id}", f"post:{p['_id']}")
    pipe.expire(f"feed:{usuario_id}", 604800)
    pipe.execute()
```

## 🎯 Consideraciones de consistencia

### ¿Qué pasa si Redis se cae?

- Fallback: consultar MongoDB directamente (más lento pero funciona)
- Los feeds se reconstruyen al volver Redis
- Los likes/contadores se pierden (mitigable con persistencia AOF)

### ¿Qué pasa si un post se borra?

```python
def borrar_post(post_id, usuario_id):
    # 1. MongoDB
    mongo.posts.delete_one({"_id": ObjectId(post_id)})
    mongo.comentarios.delete_many({"post_id": ObjectId(post_id)})
    
    # 2. Redis: quitar de todos los feeds
    for key in redis.scan_iter("feed:*"):
        redis.lrem(key, 0, f"post:{post_id}")
    
    # 3. Limpiar stats
    redis.delete(f"likes:{post_id}")
    redis.delete(f"stats:post:{post_id}:likes", ...)
    
    # 4. Trending
    redis.zrem("trending:global", f"post:{post_id}")
```

### ¿Qué pasa si un usuario bloquea a otro?

```python
def bloquear(usuario_id, bloqueado_id):
    # 1. PostgreSQL
    pg.execute("INSERT INTO bloqueos VALUES (%s, %s)", usuario_id, bloqueado_id)
    
    # 2. Redis: quitar mutuamente de feeds
    # (El filtrado se hace también en lectura por seguridad)
    seguidores_afectados = ...
    # Reconstruir feeds (o dejar que se limpien con TTL)
```

## ✅ Checklist

- [ ] Feed con TTL de 7 días
- [ ] Híbrido push/pull para escalar
- [ ] Fallback a MongoDB si Redis falla
- [ ] Filtrado de bloqueados en lectura
- [ ] Score para trending
- [ ] Paginación con cursor
- [ ] Reconstrucción on-demand
- [ ] Sincronización de contadores