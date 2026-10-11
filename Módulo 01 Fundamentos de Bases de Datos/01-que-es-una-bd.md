# 01 - ¿Qué es una base de datos?

## 🎯 Objetivos
- Entender qué es una base de datos
- Conocer la diferencia entre dato, información y base de datos
- Identificar cuándo necesitas una BD

## 📚 Conceptos clave

### ¿Qué es un dato?
Un **dato** es un valor sin contexto. Por ejemplo: `25`.

### ¿Qué es información?
La **información** es un dato con contexto. Por ejemplo: `"La edad de Ana es 25 años"`.

### ¿Qué es una base de datos?
Una **base de datos (BD)** es una colección organizada de datos que se almacena y se puede consultar de forma eficiente.

> 📌 Definición formal: sistema que permite almacenar, modificar y consultar datos de forma estructurada, garantizando integridad y seguridad.

### ¿Qué es un SGBD?
Un **SGBD** (Sistema Gestor de Bases de Datos) es el software que administra la base de datos.

Ejemplos:
- PostgreSQL
- MySQL / MariaDB
- SQLite
- SQL Server
- Oracle
- MongoDB

### ¿Por qué no usar solo archivos Excel o CSV?
| Característica | Excel/CSV | Base de datos |
|----------------|-----------|---------------|
| Manejo de millones de filas | ❌ Lento | ✅ Optimizado |
| Concurrencia (varios usuarios) | ❌ Problemas | ✅ Soportado |
| Integridad de datos | ❌ Manual | ✅ Automática |
| Seguridad y permisos | ❌ Básico | ✅ Avanzado |
| Consultas complejas | ❌ Limitado | ✅ SQL |

### ¿Cuándo necesitas una BD?
- Cuando varios usuarios acceden a los mismos datos
- Cuando los datos crecen constantemente
- Cuando necesitas relaciones entre datos (un cliente → muchos pedidos)
- Cuando necesitas garantizar que los datos sean correctos

## 💻 Ejemplo conceptual

Imagina una tienda. Sin BD tendrías:
- Un Excel con clientes
- Otro Excel con productos
- Otro Excel con ventas
- Y rezar para que no se desincronicen 😅

Con BD tienes:
```sql
SELECT c.nombre, p.producto, v.fecha
FROM clientes c
JOIN ventas v ON v.cliente_id = c.id
JOIN productos p ON p.id = v.producto_id;
```

## ⚠️ Errores comunes
- Confundir "base de datos" con "SGBD" (uno es el conjunto de datos, el otro el software)
- Pensar que Excel es suficiente para todo
- Creer que una BD es solo para grandes empresas (¡SQLite es perfecto para apps pequeñas!)

## ✅ Ejercicios
1. Explica con tus palabras la diferencia entre dato e información
2. Menciona 3 ejemplos de la vida cotidiana donde se usen bases de datos
3. ¿Por qué una hoja de Excel no es una buena opción para una red social?

## 🔗 Recursos
- [¿Qué es una base de datos? - Oracle](https://www.oracle.com/database/what-is-database/)