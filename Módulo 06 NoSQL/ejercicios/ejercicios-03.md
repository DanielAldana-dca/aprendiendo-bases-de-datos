# 🧪 Ejercicios - Redis

## Nivel 🟢 Fácil

### 1. Contador
Crea un contador de visitas e increméntalo 5 veces.

<details>
<summary>💡 Solución</summary>

```redis
SET visitas:home 0
INCR visitas:home
INCR visitas:home
INCR visitas:home
INCR visitas:home
INCR visitas:home
GET visitas:home# "5"
```
</details>

### 2. Sesión con TTL
Crea una sesión que expire en 1 hora.

<details>
<summary>💡 Solución</summary>

```redis
SETEX sesion:user:abc123 3600 "{\"user_id\":1,\"nombre\":\"Ana\"}"
TTL sesion:user:abc123
# 3600
```
</details>

### 3. Lista
Crea una lista con 5 tareas y saca la primera.

<details>
<summary>💡 Solución</summary>

```redis
RPUSH tareas "comprar" "cocinar" "estudiar" "ejercicio" "leer"
LRANGE tareas 0 -1
LPOP tareas
# "comprar"
```
</details>

---

## Nivel 🟡 Intermedio

### 4. Ranking
Crea un ranking de 5 jugadores y muestra el top 3.

<details>
<summary>💡 Solución</summary>

```redis
ZADD ranking 100 "Ana"
ZADD ranking 85 "Luis"
ZADD ranking 95 "Marta"
ZADD ranking 78 "Pedro"
ZADD ranking 92 "Sara"

ZREVRANGE ranking 0 2 WITHSCORES
# 1) "Ana"   2) "100"
# 3) "Marta" 4) "95"
# 5) "Sara"  6) "92"
```
</details>

### 5. Perfil con hash
Guarda un perfil de usuario.

<details>
<summary>💡 Solución</summary>

```redis
HSET usuario:1 nombre "Ana" email "ana@x.com" edad 28 ciudad "Madrid"
HGETALL usuario:1
HGET usuario:1 nombre
HINCRBY usuario:1 edad 1
```
</details>

### 6. Cache con expiración
Cachea un resultado por 5 minutos.

<details>
<summary>💡 Solución</summary>

```redis
SET cache:productos:top10 "...JSON..." EX 300
TTL cache:productos:top10
# 300
```
</details>

---

## Nivel 🔴 Difícil

### 7. Rate limiter
Limita a 10 peticiones por minuto por usuario.

<details>
<summary>💡 Solución</summary>

```redis
# Por cada petición:
INCR rate:user:1
EXPIRE rate:user:1 60

# Verificar:
GET rate:user:1
# Si > 10 → bloquear
```

**Pseudocódigo:**
```python
count = redis.incr(f"rate:user:{user_id}")
if count == 1:
    redis.expire(f"rate:user:{user_id}", 60)
if count > 10:
    raise RateLimitExceeded()
```
</details>

### 8. Cola de tareas
Implementa una cola con productor y consumidor.

<details>
<summary>💡 Solución</summary>

```redis
# Productor
LPUSH cola:emails "email:1"
LPUSH cola:emails "email:2"
LPUSH cola:emails "email:3"

# Consumidor (bloqueante)
BRPOP cola:emails 0
# "email:1"  ← el más antiguo (FIFO con BRPOP)
```
</details>

### 9. Pub/Sub
Publica un mensaje y recíbelo.

<details>
<summary>💡 Solución</summary>

**Terminal 1:**
```redis
SUBSCRIBE canal:noticias
```

**Terminal 2:**
```redis
PUBLISH canal:noticias "Hola suscriptores!"
# (integer) 1
```
</details>

### 10. Tags de un post
Guarda los tags de un post y verifica si tiene uno específico.

<details>
<summary>💡 Solución</summary>

```redis
SADD tags:post:1 "nosql" "mongodb" "tutorial"
SADD tags:post:1 "nosql"   # no duplica

SMEMBERS tags:post:1
# 1) "nosql"
# 2) "mongodb"
# 3) "tutorial"

SISMEMBER tags:post:1 "nosql"
# (integer) 1
```
</details>