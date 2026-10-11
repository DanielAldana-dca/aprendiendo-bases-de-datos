# 01 - Introducción a NoSQL

## 🎯 Objetivos

- Entender qué es NoSQL
- Conocer los 4 tipos principales
- Diferenciar SQL de NoSQL
- Saber cuándo usar cada uno

## 📚 ¿Qué es NoSQL?

**NoSQL** = "Not Only SQL". Conjunto de bases de datos que **no usan el modelo relacional** tradicional.

**Características comunes:**
- Esquema flexible (o inexistente)
- Escalabilidad horizontal
- Diseñadas para grandes volúmenes
- Priorizan disponibilidad o rendimiento sobre consistencia estricta

## 🗂️ Los 4 tipos principales

### 1. Documentales
Guardan **documentos** (JSON/BSON). Cada documento es autocontenido.

**Ejemplo MongoDB:**
```javascript
{
    "_id": 1,
    "nombre": "Ana García",
    "email": "ana@mail.com",
    "direccion": {
        "calle": "Gran Vía 10",
        "ciudad": "Madrid",
        "cp": "28001"
    },
    "pedidos": [
        { "id": 1, "total": 1200 },
        { "id": 2, "total": 25.50 }
    ]
}
```

**Uso:** aplicaciones web, catálogos, CMS, perfiles de usuario.

**Ejemplos:** MongoDB, CouchDB, Firestore.

### 2. Clave-Valor
El modelo más simple: una clave → un valor.

**Ejemplo Redis:**
```
SET usuario:1:nombre "Ana"
GET usuario:1:nombre  → "Ana"

SET sesion:abc123 "{\"user_id\":1,\"expira\":\"2024-12-31\"}"
```

**Uso:** caché, sesiones, colas, contadores en tiempo real.

**Ejemplos:** Redis, DynamoDB, Memcached.

### 3. Columnares (Wide Column)
Optimizadas para leer columnas específicas de tablas enormes.

**Ejemplo Cassandra:**
```
CREATE TABLE usuarios (
    id UUID PRIMARY KEY,
    nombre TEXT,
    ciudad TEXT
);
```

**Uso:** analítica, big data, series temporales.

**Ejemplos:** Cassandra, HBase, ScyllaDB.

### 4. Grafos
Nodos y relaciones de primera clase.

**Ejemplo Neo4j:**
```cypher
CREATE (ana:Persona {nombre: "Ana"})
CREATE (luis:Persona {nombre: "Luis"})
CREATE (ana)-[:AMIGO_DE]->(luis)
```

**Uso:** redes sociales, recomendaciones, detección de fraude.

**Ejemplos:** Neo4j, ArangoDB, Amazon Neptune.

## 🆚 SQL vs NoSQL

| Aspecto | SQL | NoSQL |
|---------|-----|-------|
| Esquema | Fijo, definido antes | Flexible, dinámico |
| Modelo | Tablas + relaciones | Documentos, KV, grafos |
| Consultas | SQL estándar | APIs específicas |
| Escalabilidad | Vertical (más CPU/RAM) | Horizontal (más servidores) |
| Consistencia | ACID fuerte | BASE (eventual) |
| JOINs | Nativos | Limitados o manuales |
| Transacciones | Multi-tabla | Por documento (o limitadas) |
| Casos ideales | Datos estructurados, transacciones | Datos semiestructurados, escala masiva |

## 🏛️ Teorema CAP

En un sistema distribuido solo puedes garantizar **2 de 3**:

- **C**onsistency: todos ven los mismos datos a la vez
- **A**vailability: siempre responde
- **P**artition tolerance: sigue funcionando ante fallos de red

**En la práctica:** la P es obligatoria en sistemas distribuidos, así que eliges entre **CP** (consistencia) o **AP** (disponibilidad).

| Categoría | Elige | Ejemplo |
|-----------|-------|---------|
| CP | Consistencia | MongoDB (por defecto), HBase |
| AP | Disponibilidad | Cassandra, DynamoDB, CouchDB |

## 📊 BASE vs ACID

**ACID** (SQL):
- Atomicity
- Consistency
- Isolation
- Durability

**BASE** (NoSQL):
- **B**asically **A**vailable
- **S**oft state
- **E**ventually consistent

**Traducción:** en NoSQL, los datos pueden estar temporalmente inconsistentes pero eventualmente se sincronizan.

## 🎯 ¿Cuándo usar NoSQL?

### ✅ Sí
- Datos sin esquema fijo (logs, JSON de APIs)
- Escala horizontal masiva (millones de usuarios)
- Caché y sesiones (Redis)
- Catálogos con estructura variable
- Redes sociales (grafos)
- IoT y series temporales

### ❌ No
- Transacciones financieras (mejor SQL)
- Datos altamente relacionales (muchos JOINs)
- Reportes complejos con agregaciones
- Cuando necesitas ACID estricto
- Si no tienes claro el modelo de acceso

## 💡 Persistencia políglota

**No es "SQL O NoSQL"**, muchas empresas usan **ambos**:

| Necesidad | Tecnología |
|-----------|-----------|
| Datos de usuarios | PostgreSQL |
| Sesiones y caché | Redis |
| Logs de actividad | MongoDB |
| Búsqueda | Elasticsearch |
| Recomendaciones | Neo4j |

**Ejemplo real:** Instagram usa PostgreSQL para usuarios, Redis para caché, Cassandra para feeds.

## ⚠️ Errores comunes

- Pensar que NoSQL es "mejor" que SQL (depende)
- Usar MongoDB para datos altamente relacionales (sufrirás)
- Elegir NoSQL "porque escala" sin necesitar escalar
- Ignorar que sin esquema, la integridad es tu problema
- No pensar en el modelo de acceso antes de elegir

## ✅ Ejercicios

1. Clasifica estos casos según el tipo de BD ideal:
   - Caché de sesiones
   - Catálogo de productos con atributos variables
   - Red social con amigos de amigos
   - Transacciones bancarias
   - Logs de servidor
   - Contador de "me gusta" en tiempo real

2. ¿Qué significa que un sistema sea "eventualmente consistente"?

3. Explica el teorema CAP con un ejemplo cotidiano.

4. Investiga: ¿qué BD usa Twitter/X para timelines? ¿Por qué?

5. Diseña una arquitectura políglota para una app de delivery.

## 🔗 Recursos

- [NoSQL Databases - MongoDB](https://www.mongodb.com/nosql-explained)
- [CAP Theorem - IBM](https://www.ibm.com/topics/cap-theorem)