# 05 - SQL vs NoSQL: Cuándo Usar Cada Uno

## 🎯 Objetivos

- Tomar decisiones informadas sobre BD
- Conocer criterios prácticos
- Diseñar arquitecturas políglotas
- Evitar elecciones por moda

## 📊 Tabla comparativa completa

| Criterio | SQL | NoSQL |
|----------|-----|-------|
| **Modelo** | Tablas relacionales | Documentos, KV, grafos |
| **Esquema** | Fijo, migraciones | Flexible |
| **Consultas** | SQL estándar | APIs específicas |
| **JOINs** | Nativos y eficientes | Limitados (`$lookup`) |
| **Transacciones** | Multi-tabla ACID | Por documento / limitadas |
| **Consistencia** | Fuerte | Eventual (a veces) |
| **Escalabilidad** | Vertical (más RAM/CPU) | Horizontal (más nodos) |
| **Madurez** | 40+ años | 15-20 años |
| **Curva aprendizaje** | Alta (SQL) | Media (API) |
| **Casos ideales** | Transacciones, reportes | Escala, flexibilidad |

## 🎯 Criterios de decisión

### 1. ¿Necesitas transacciones ACID multi-tabla?

**Sí → SQL.**  
No → NoSQL puede servir.

Ejemplo: transferencias bancarias → **PostgreSQL**.

### 2. ¿Cuál es tu patrón de acceso?

- **Consultas complejas con JOINs** → SQL
- **Consultas por clave, documentos completos** → NoSQL

### 3. ¿Cómo crecerá?

- **Vertical (más potente)** → SQL
- **Horizontal (más nodos)** → NoSQL

### 4. ¿Qué tan estable es el esquema?

- **Estable, bien definido** → SQL
- **Cambiante, semiestructurado** → NoSQL

### 5. ¿Qué consistencia necesitas?

- **Fuerte** → SQL
- **Eventual aceptable** → NoSQL

## 📋 Guía rápida

| Necesito... | Mejor opción |
|-------------|--------------|
| Transacciones financieras | PostgreSQL |
| Catálogo con atributos variables | MongoDB |
| Caché de sesiones | Redis |
| Ranking en tiempo real | Redis |
| Red social (amigos de amigos) | Neo4j |
| Logs de aplicación | MongoDB, Elasticsearch |
| Reportes analíticos complejos | PostgreSQL, Snowflake |
| Carrito de compras | Redis (sesión) + SQL (pedido) |
| Feed de noticias a escala | Cassandra |
| Búsqueda full-text | Elasticsearch |
| Contador de likes | Redis |
| CMS con contenido flexible | MongoDB |
| IoT (millones de métricas) | InfluxDB, TimescaleDB |

## 🏗️ Arquitectura políglota

Usar la herramienta adecuada para cada trabajo.

### Ejemplo: e-commerce moderno

```
┌─────────────────────────────────────────────┐
│              Frontend                       │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│              API Gateway                    │
└──────┬──────┬──────┬──────┬─────────────────┘
       │      │      │      │
   ┌───▼──┐ ┌─▼───┐ ┌▼───┐ ┌▼────────┐
   │ PG   │ │Mongo│ │Redis│ │Elastic  │
   │      │ │     │ │     │ │         │
   │Users │ │Catá-│ │Caché│ │Búsqueda │
   │Orders│ │logo │ │Sesio│ │         │
   │Pagos │ │     │ │nes  │ │         │
   └──────┘ └─────┘ └─────┘ └─────────┘
```

**Justificación:**
- **PostgreSQL:** usuarios, pedidos, pagos → necesitas ACID
- **MongoDB:** catálogo con atributos variables por categoría
- **Redis:** carrito, sesiones, caché
- **Elasticsearch:** búsqueda con filtros y relevancia

### Ejemplo: red social

```
- PostgreSQL: usuarios, relaciones de amistad, posts
- Redis: feeds de timeline (cache), contadores
- Neo4j: recomendaciones "amigos de amigos"
- Cassandra: mensajes directos (alta escritura)
- S3: imágenes y videos
```

### Ejemplo: app de delivery

```
- PostgreSQL: usuarios, restaurantes, pedidos
- Redis: ubicación de repartidores en tiempo real
- MongoDB: menús con variaciones por restaurante
- Elasticsearch: búsqueda de restaurantes
- InfluxDB: métricas y tiempos de entrega
```

## ⚠️ Anti-patrones

### 1. "Vamos a usar NoSQL porque escala"
- ¿Realmente necesitas escalar horizontalmente?
- ¿Has medido que PostgreSQL no aguanta?

### 2. "SQL es antiguo"
- PostgreSQL aguanta millones de filas sin problema
- Muchas apps "grandes" usan SQL

### 3. "MongoDB para todo"
- Transacciones financieras en Mongo → sufrimiento
- Relaciones complejas en Mongo → sufrimiento

### 4. "Voy a migrar de SQL a NoSQL"
- ¿El problema es el motor o tu diseño?
- Migraciones masivas rara vez son la solución

### 5. "SQL no escala"
- Falso. Stack Overflow sirve con SQL Server
- Instagram usa PostgreSQL
- GitHub usa MySQL

## 🎯 Reglas prácticas

1. **Empieza con SQL** si dudas
2. **Añade NoSQL** cuando tengas un caso específico
3. **Mide antes de migrar**
4. **No dupliques datos sin estrategia de sincronización**
5. **Documenta por qué elegiste cada BD**

## 📈 Escalabilidad real

### SQL escala bien si:
- Índices correctos
- Particionado
- Réplicas de lectura
- Caché (Redis) delante
- Sharding (PostgreSQL, MySQL)

### Ejemplos reales
- **Instagram:** PostgreSQL (con sharding)
- **GitHub:** MySQL
- **Stack Overflow:** SQL Server (millones de visitas)
- **Notion:** PostgreSQL
- **Figma:** PostgreSQL

**Conclusión:** SQL no es el cuello de botella. El mal diseño sí.

## 💡 Decision tree simplificado

```
¿Necesitas ACID multi-tabla?
├── SÍ → SQL (PostgreSQL)
└── NO
    ├── ¿Datos en RAM para máxima velocidad?
    │   └── SÍ → Redis
    ├── ¿Datos semiestructurados con esquema variable?
    │   └── SÍ → MongoDB
    ├── ¿Relaciones complejas (grafos)?
    │   └── SÍ → Neo4j
    ├── ¿Escritura masiva distribuida?
    │   └── SÍ → Cassandra
    └── No estoy seguro → PostgreSQL
```

## ✅ Ejercicios

1. Para cada caso, elige BD y justifica:
   - Sistema bancario
   - Chat en tiempo real
   - Motor de búsqueda de productos
   - Sistema de reservas de hotel
   - Recomendaciones de amigos
   - Sesiones de usuario
   - Logs de servidor

2. Diseña arquitectura políglota para una app de streaming (tipo Netflix).

3. ¿Por qué Stack Overflow usa SQL Server y no MongoDB?

4. Cuando Instagram migró de PostgreSQL a Cassandra para feeds, ¿por qué lo hizo?

5. ¿Cuándo NO usarías NoSQL aunque pudieras?

## 🔗 Recursos

- [SQL vs NoSQL - MongoDB](https://www.mongodb.com/nosql-explained)
- [How Discord Stores Billions of Messages](https://discord.com/blog/how-discord-stores-billions-of-messages)