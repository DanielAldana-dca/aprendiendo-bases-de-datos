# 📒 Módulo 06: NoSQL

El mundo de las bases de datos no relacionales. Aprende cuándo, cómo y por qué usarlas.

## 📂 Contenido

| # | Tema | Enlace |
|---|------|--------|
| 01 | Introducción a NoSQL | [01-introduccion-nosql.md](./01-introduccion-nosql.md) |
| 02 | Modelado documental | [02-modelado-documental.md](./02-modelado-documental.md) |
| 03 | MongoDB | [03-mongodb.md](./03-mongodb.md) |
| 04 | Redis | [04-redis.md](./04-redis.md) |
| 05 | SQL vs NoSQL: cuándo usar cada uno | [05-sql-vs-nosql.md](./05-sql-vs-nosql.md) |
| 06 | Ejercicios | [ejercicios/](./ejercicios/) |

## 🎯 Objetivos

- Entender qué es NoSQL y sus tipos
- Modelar datos en documentos (no tablas)
- Dominar operaciones CRUD en MongoDB
- Conocer casos de uso de Redis
- Decidir cuándo usar SQL y cuándo NoSQL

## 🛠️ Preparación del entorno

### MongoDB con Docker
```bash
docker run --name mongo-practica -p 27017:27017 -d mongo:latest

# Cliente
docker exec -it mongo-practica mongosh
```

### Alternativa: MongoDB Atlas (cloud gratis)
1. Regístrate en https://www.mongodb.com/atlas
2. Crea un cluster gratuito M0
3. Conéctate con `mongosh` o Compass

### Redis con Docker
```bash
docker run --name redis-practica -p 6379:6379 -d redis:latest
docker exec -it redis-practica redis-cli
```

## 📦 Dataset de práctica

Ver [`recursos/datasets/tienda-nosql.js`](../recursos/datasets/tienda-nosql.js)

## ⏱️ Tiempo estimado

10-12 horas