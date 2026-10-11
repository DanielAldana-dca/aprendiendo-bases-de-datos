# 02 - Tipos de Bases de Datos

## 🎯 Objetivos
- Conocer los principales tipos de BD
- Saber cuándo usar cada una
- Diferenciar SQL vs NoSQL

## 📚 Clasificación principal

### 1. Bases de datos relacionales (SQL)
Organizan los datos en **tablas** con filas y columnas relacionadas entre sí.

**Características:**
- Esquema fijo (defines las tablas antes)
- Usan SQL como lenguaje
- Cumplen propiedades ACID
- Ideales para datos estructurados

**Ejemplos:** PostgreSQL, MySQL, SQLite, SQL Server, Oracle

**Cuándo usarlas:**
- Datos con relaciones claras (clientes → pedidos)
- Cuando necesitas integridad fuerte (bancos)
- Reportes y consultas complejas

### 2. Bases de datos NoSQL
No usan el modelo tabular. Se dividen en subtipos:

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| **Documentales** | Guardan documentos JSON/BSON | MongoDB, CouchDB |
| **Clave-Valor** | Pares clave → valor | Redis, DynamoDB |
| **Columnas** | Optimizadas para análisis masivo | Cassandra, HBase |
| **Grafos** | Nodos y relaciones | Neo4j |

**Cuándo usarlas:**
- Datos sin esquema fijo
- Escalabilidad horizontal masiva
- Caché y sesiones (Redis)
- Redes sociales y recomendaciones (Neo4j)

### 3. Bases de datos en memoria
Guardan datos en RAM. Súper rápidas pero costosas.
- **Ejemplos:** Redis, Memcached

### 4. Bases de datos analíticas (OLAP)
Optimizadas para análisis y reportes sobre grandes volúmenes.
- **Ejemplos:** Snowflake, BigQuery, Redshift

## 🆚 SQL vs NoSQL

| Característica | SQL | NoSQL |
|----------------|-----|-------|
| Esquema | Fijo | Flexible |
| Escalabilidad | Vertical | Horizontal |
| Consistencia | Fuerte (ACID) | Eventual (BASE) |
| Relaciones | Joins | Embebidos/referencias |
| Casos de uso | Transacciones, reportes | Big Data, tiempo real |

## 💡 Consejo práctico
> No es "SQL **o** NoSQL", muchas empresas usan **ambos** según el caso. A esto se le llama **persistencia políglota**.

## ⚠️ Errores comunes
- Pensar que NoSQL es "mejor" que SQL (depende del caso)
- Usar MongoDB para datos altamente relacionales (sufrirás)
- Elegir tecnología por moda sin analizar requisitos

## ✅ Ejercicios
1. Clasifica los siguientes casos según el tipo de BD ideal:
   - Un banco con transferencias
   - Un chat en tiempo real
   - Un sistema de recomendaciones de amigos
   - Un carrito de compras temporal
2. Investiga 2 empresas que usen SQL y 2 que usen NoSQL ¿por qué?
3. ¿Qué significa que una BD sea "eventualmente consistente"?

## 🔗 Recursos
- [NoSQL vs SQL - MongoDB](https://www.mongodb.com/nosql-explained)