# 👥 Proyecto 03: Red Social

Sistema completo con usuarios, publicaciones, comentarios, likes, seguidores y feed.

## 🎯 Objetivos

- Arquitectura políglota (SQL + MongoDB + Redis)
- Modelar relaciones sociales
- Implementar feed con caché
- Contadores en tiempo real
- Análisis con grafos (opcional)

## 📋 Requisitos funcionales

### Usuarios
- Registro, perfil, avatar
- Seguir / dejar de seguir
- Bloquear usuarios
- Búsqueda

### Publicaciones
- Texto, imágenes, ubicación
- Visibilidad (público, seguidores, privado)
- Edición y borrado
- Hashtags y menciones

### Interacciones
- Likes
- Comentarios (con respuestas)
- Compartir
- Guardar

### Feed
- Feed personal (quienes sigues)
- Feed "explorar" (recomendaciones)
- Notificaciones

### Mensajería
- Chats 1 a 1
- Grupos

## 🗂️ Arquitectura políglota

```
┌───────────────────────────────────────────┐
│              Frontend                      │
└────────────────┬──────────────────────────┘
                 │
┌────────────────▼──────────────────────────┐
│              API                          │
└──┬─────────┬─────────┬─────────┬──────────┘
   │         │         │         │
┌──▼──┐  ┌───▼───┐  ┌──▼───┐  ┌──▼──────┐
│Postg│  │ Mongo │  │Redis │  │ Neo4j   │
│     │  │       │  │      │  │(opcional)│
│Users│  │Posts  │  │Feed  │  │Amigos   │
│Relac│  │Coment.│  │Cache │  │         │
│Notif│  │Mensaj.│  │Count.│  │         │
└─────┘  └───────┘  └──────┘  └─────────┘
```

### Responsabilidades

| BD | Qué guarda | Por qué |
|----|------------|---------|
| **PostgreSQL** | Usuarios, relaciones (follows), notificaciones | ACID, integridad |
| **MongoDB** | Posts, comentarios, mensajes | Flexibilidad, escala |
| **Redis** | Feed cache, contadores (likes, views), sesiones | Velocidad |
| **Neo4j** (opcional) | Grafo social | Recomendaciones |

## 🗂️ Estructura del proyecto

```
03-red-social/
├── README.md              -- este archivo
├── 01-diseno.md           -- decisiones de arquitectura
├── 02-postgres.sql        -- schema SQL
├── 03-mongodb.js          -- colecciones MongoDB
├── 04-redis.md            -- patrones de uso
├── 05-feed.md             -- diseño del feed
└── 06-consultas.md        -- consultas clave
```

## 🎓 Lo que practicarás

- Arquitectura políglota real
- Patrón fan-out del feed
- Contadores con Redis
- Modelado documental para posts
- Relaciones sociales
- Cacheo y TTL