# 04 - Redis

## 🎯 Objetivos

- Entender qué es Redis y para qué sirve
- Conocer los tipos de datos
- Dominar operaciones básicas
- Usar TTL y expiración
- Conocer casos de uso típicos

## 📚 ¿Qué es Redis?

Base de datos **clave-valor en memoria** (RAM). Ultrarrápida: millones de operaciones por segundo.

**Características:**
- Datos en memoria (no en disco, aunque puede persistir)
- Estructuras de datos ricas (listas, sets, hashes, sorted sets)
- TTL (expiración automática)
- Pub/Sub
- Transacciones básicas

**Uso típico:** caché, sesiones, colas, contadores, rankings en tiempo real.

## 📦 Tipos de datos

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| String | Valor simple | Nombre, token, contador |
| List | Lista ordenada | Cola de mensajes, timeline |
| Set | Conjunto sin orden | Tags, seguidores |
| Hash | Objeto | Perfil de usuario |
| Sorted Set | Set ordenado por score | Rankings, feeds |
| Stream | Log de eventos | Colas avanzadas |

## 💻 Operaciones básicas

### Strings

```redis
SET usuario:1:nombre "Ana"
GET usuario:1:nombre
# "Ana"

SET contador:visitas 0
INCR contador:visitas
INCR contador:visitas
INCRBY contador:visitas 10
GET contador:visitas
# "12"

SETEX sesion:abc 3600 "datos"
# expira en 3600 segundos

TTL sesion:abc
# 3600

APPEND usuario:1:nombre " García"
GET usuario:1:nombre
# "Ana García"
```

### Listas

```redis
RPUSH cola:tareas "tarea1"
RPUSH cola:tareas "tarea2"
LPUSH cola:tareas "urgente"

LRANGE cola:tareas 0 -1
# 1) "urgente"
# 2) "tarea1"
# 3) "tarea2"

LPOP cola:tareas
# "urgente"

LLEN cola:tareas
# 2
```

### Sets

```redis
SADD tags:post:1 "nosql" "mongodb" "tutorial"
SADD tags:post:1 "nosql"  # no se duplica

SMEMBERS tags:post:1
# 1) "nosql"
# 2) "mongodb"
# 3) "tutorial"

SISMEMBER tags:post:1 "nosql"
# 1 (true)

SCARD tags:post:1
# 3 (cardinalidad)
```

### Hashes

```redis
HSET usuario:1 nombre "Ana" email "ana@x.com" edad 28

HGET usuario:1 nombre
# "Ana"

HGETALL usuario:1
# 1) "nombre"
# 2) "Ana"
# 3) "email"
# 4) "ana@x.com"
# 5) "edad"
# 6) "28"

HINCRBY usuario:1 edad 1
HDEL usuario:1 email
```

### Sorted Sets (rankings)

```redis
ZADD ranking:jugadores 100 "Ana"
ZADD ranking:jugadores 85 "Luis"
ZADD ranking:jugadores 95 "Marta"

ZRANGE ranking:jugadores 0 -1 WITHSCORES
# 1) "Luis"   2) "85"
# 3) "Marta"  4) "95"
# 5) "Ana"    6) "100"

ZREVRANGE ranking:jugadores 0 2 WITHSCORES  # top 3
ZRANK ranking:jugadores "Marta"  # posición
ZSCORE ranking:jugadores "Ana"   # 100
```

## ⏰ TTL y expiración

```redis
SET cache:productos "..." EX 300     # 300 segundos
TTL cache:productos                  # 300

EXPIRE cache:productos 600           # resetear a 600
PERSIST cache:productos              # quitar expiración
```

**Uso típico:** caché con expiración automática.

## 🎯 Casos de uso

### 1. Caché

```redis
# Al consultar un producto caro:
GET cache:producto:1
# Si NULL:
#   Consultar BD
#   SET cache:producto:1 "..." EX 300
```

### 2. Sesiones

```redis
SET sesion:user:abc123 "{\"user_id\":1}" EX 86400
# 24 horas
```

### 3. Contadores en tiempo real

```redis
INCR likes:post:1
INCR visitas:home
```

### 4. Rankings

```redis
ZADD ranking:ventas 150 "producto:1"
ZADD ranking:ventas 200 "producto:2"
ZREVRANGE ranking:ventas 0 9  # top 10
```

### 5. Cola de tareas

```redis
# Productor
LPUSH cola:emails "email:1"
LPUSH cola:emails "email:2"

# Consumidor
BRPOP cola:emails 0   # bloquea hasta que haya
```

### 6. Rate limiting

```redis
INCR rate:user:1
EXPIRE rate:user:1 60
# Si INCR > 100 → bloquea
```

### 7. Pub/Sub

```redis
# Terminal 1 (suscriptor)
SUBSCRIBE canal:noticias

# Terminal 2 (publicador)
PUBLISH canal:noticias "Nueva noticia!"
```

## 🔄 Persistencia

Redis puede persistir a disco:

- **RDB:** snapshots periódicos (rápido, puede perder datos)
- **AOF:** log de operaciones (más lento, menos pérdida)
- **Ambos:** lo mejor de cada uno

**Configuración en `redis.conf`:**
```
save 900 1      # cada 900s si hubo ≥1 cambio
save 300 10
save 60 10000
appendonly yes
```

## 🎯 Comandos útiles

```redis
# Info del servidor
INFO

# Todas las claves (¡cuidado en producción!)
KEYS *

# Buscar patrón
KEYS usuario:*

# Contar
DBSIZE

# Borrar
DEL usuario:1
UNLINK usuario:1  # borrado asíncrono

# Ver tipo
TYPE usuario:1

# Renombrar
RENAME viejo nuevo

# Limpiar todo (¡cuidado!)
FLUSHDB
FLUSHALL
```

## ⚡ Rendimiento

- Todo en RAM → microsegundos de latencia
- Single-threaded (evita locks)
- Pipeline para agrupar comandos
- Lua scripts para operaciones atómicas complejas

## ⚠️ Errores comunes

- Usar Redis como BD principal (no está pensado para eso)
- `KEYS *` en producción (bloquea)
- No poner TTL a las cachés (llenan la memoria)
- Guardar objetos grandes (mejor strings pequeños)
- No planear la política de evicción (`maxmemory-policy`)

## ✅ Ejercicios

1. Guarda un contador de visitas e increméntalo 5 veces
2. Crea una sesión de usuario con expiración de 1 hora
3. Crea una lista con 5 tareas y saca la primera
4. Crea un ranking de 5 jugadores y muestra el top 3
5. Guarda un perfil de usuario como hash
6. Implementa un rate limiter (máx 10 req/min por usuario)
7. Cachea el resultado de una consulta con TTL de 5 minutos
8. Publica y suscríbete a un canal

## 🔗 Recursos

- [Redis Docs](https://redis.io/docs/)
- [Try Redis (interactivo)](https://try.redis.io/)