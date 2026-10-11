# 🎯 Desafíos Integradores - Módulo 06

> ⚠️ Sin soluciones. Combina todo lo aprendido.

## 🎯 Desafío 1: Migrar de SQL a MongoDB

Toma el dataset SQL de la tienda (Módulo 02) y migra a MongoDB:
1. Diseña las colecciones (¿embeber o referenciar?)
2. Escribe los `insertMany`
3. Reescribe estas 5 consultas SQL en aggregation:
   - Clientes con más pedidos
   - Ingresos por categoría
   - Top 3 productos más vendidos
   - Clientes sin pedidos
   - Ticket promedio por cliente

## 🎯 Desafío 2: Sistema de caché

Diseña un sistema de caché con Redis para:
1. Caché de productos (TTL 5 min)
2. Caché de "top 10 productos" (TTL 1 hora)
3. Sesión de usuario (TTL 24 horas)
4. Contador de visitas por página

Escribe los comandos para:
- Leer con fallback a BD
- Invalidar caché cuando cambia un producto
- Ver todas las claves de caché

## 🎯 Desafío 3: Timeline de red social

Diseña con Redis + MongoDB:
1. Al publicar un post, se añade al timeline de los seguidores
2. Los timelines se cachean por 5 minutos
3. Los contadores de likes son en tiempo real

**Pistas:**
- `LPUSH timeline:user:1 post_id` para el timeline
- `INCR likes:post:1` para likes
- `EXPIRE` para TTL

## 🎯 Desafío 4: Rate limiting avanzado

Implementa:
1. Rate limit de 100 req/min por usuario
2. Rate limit de 1000 req/hora por IP
3. Bloqueo temporal tras 3 infracciones
4. Whitelist para usuarios premium

## 🎯 Desafío 5: Arquitectura políglota

Diseña la arquitectura para una app de delivery:
- Usuarios, restaurantes, pedidos
- Ubicación en tiempo real de repartidores
- Búsqueda de restaurantes
- Recomendaciones

Indica:
- Qué BD usarías para cada componente
- Por qué
- Cómo se sincronizan

## 🎯 Desafío 6: Benchmark

Compara el mismo caso de uso (ej: total gastado por cliente):
1. En PostgreSQL (Módulo 03)
2. En MongoDB (aggregation)
3. Mide tiempos con 10, 1.000 y 100.000 registros
4. Documenta los resultados y conclusiones

> 💡 Puedes generar datos de prueba con un script.