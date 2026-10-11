# 02 - Diagramas Entidad-Relación

## 🎯 Objetivos

- Conocer la notación de diagramas ER
- Diferenciar los tipos de cardinalidad
- Representar entidades débiles
- Leer y crear diagramas ER en Mermaid

## 📚 ¿Qué es un diagrama ER?

Representación visual de entidades, atributos y relaciones. Es el **plano** de la BD.

## 🎨 Notaciones

| Notación | Uso |
|----------|-----|
| Chen | Académica, con rombos y óvalos |
| Crow's Foot (pata de gallo) | La más usada en la industria |
| UML | Orientada a objetos |
| Mermaid | Diagramas en texto (útil para Markdown) |

Aquí usaremos **Crow's Foot** y **Mermaid** (compatible con GitHub).

## 📊 Símbolos Crow's Foot

```
───||  Uno y solo uno
───o|  Cero o uno
───|{  Uno o muchos
───o{  Cero o muchos
```

### Ejemplos

| Símbolo | Significado |
|---------|-------------|
| `||──||` | 1 a 1 |
| `||──o{` | 1 a N (opcional) |
| `||──|{` | 1 a N (obligatorio) |
| `}o──o{` | N a M |

## 💻 Mermaid: sintaxis básica

```mermaid
erDiagram
    CLIENTE ||--o{ PEDIDO : realiza
    PEDIDO ||--|{ LINEA_PEDIDO : contiene
    PRODUCTO ||--o{ LINEA_PEDIDO : aparece
```

**Resultado visual:**

```mermaid
erDiagram
    CLIENTE ||--o{ PEDIDO : realiza
    PEDIDO ||--|{ LINEA_PEDIDO : contiene
    PRODUCTO ||--o{ LINEA_PEDIDO : aparece
```

## 💻 Añadir atributos

```mermaid
erDiagram
    CLIENTE {
        int id PK
        string nombre
        string email UK
        date fecha_registro
    }
    PEDIDO {
        int id PK
        int cliente_id FK
        date fecha
        decimal total
    }
    CLIENTE ||--o{ PEDIDO : realiza
```

**Resultado:**

```mermaid
erDiagram
    CLIENTE {
        int id PK
        string nombre
        string email UK
        date fecha_registro
    }
    PEDIDO {
        int id PK
        int cliente_id FK
        date fecha
        decimal total
    }
    CLIENTE ||--o{ PEDIDO : realiza
```

### Marcadores de atributos

| Marcador | Significado |
|----------|-------------|
| `PK` | Primary Key |
| `FK` | Foreign Key |
| `UK` | Unique Key |

## 💻 Relación 1:1

```mermaid
erDiagram
    USUARIO ||--|| PERFIL : tiene
    USUARIO {
        int id PK
        string username
    }
    PERFIL {
        int id PK
        int usuario_id FK
        string bio
        string avatar_url
    }
```

**Cuándo:** cuando quieres separar datos (ej: por seguridad o frecuencia de uso).

## 💻 Relación N:M

```mermaid
erDiagram
    ESTUDIANTE }o--o{ CURSO : se_inscribe
    ESTUDIANTE {
        int id PK
        string nombre
    }
    CURSO {
        int id PK
        string nombre
    }
```

**Cómo se implementa:** con tabla intermedia.

```mermaid
erDiagram
    ESTUDIANTE ||--o{ INSCRIPCION : tiene
    CURSO ||--o{ INSCRIPCION : tiene
    ESTUDIANTE {
        int id PK
        string nombre
    }
    CURSO {
        int id PK
        string nombre
    }
    INSCRIPCION {
        int estudiante_id PK,FK
        int curso_id PK,FK
        date fecha
        decimal nota
    }
```

## 📚 Entidades débiles

Entidad que **no puede existir sin otra**.

**Ejemplo:** una línea de pedido no existe sin el pedido.

```mermaid
erDiagram
    PEDIDO ||--|{ LINEA_PEDIDO : contiene
    PEDIDO {
        int id PK
        date fecha
    }
    LINEA_PEDIDO {
        int pedido_id PK,FK
        int numero_linea PK
        int producto_id FK
        int cantidad
    }
```

La PK de `LINEA_PEDIDO` es compuesta: `(pedido_id, numero_linea)`.

## 📚 Relaciones con atributos

Una relación N:M puede tener sus propios atributos.

**Ejemplo:** un estudiante se inscribe en un curso en una fecha y obtiene una nota.

```mermaid
erDiagram
    ESTUDIANTE ||--o{ INSCRIPCION : tiene
    CURSO ||--o{ INSCRIPCION : tiene
    INSCRIPCION {
        int estudiante_id PK,FK
        int curso_id PK,FK
        date fecha_inscripcion
        decimal nota
    }
```

## 🎯 Ejemplo completo: e-commerce

```mermaid
erDiagram
    CLIENTE ||--o{ PEDIDO : realiza
    PEDIDO ||--|{ LINEA_PEDIDO : contiene
    PRODUCTO ||--o{ LINEA_PEDIDO : aparece
    CATEGORIA ||--o{ PRODUCTO : agrupa

    CLIENTE {
        int id PK
        string nombre
        string email UK
        string direccion
    }
    PEDIDO {
        int id PK
        int cliente_id FK
        date fecha
        string estado
    }
    LINEA_PEDIDO {
        int pedido_id PK,FK
        int producto_id PK,FK
        int cantidad
        decimal precio_unitario
    }
    PRODUCTO {
        int id PK
        string nombre
        int categoria_id FK
        decimal precio
        int stock
    }
    CATEGORIA {
        int id PK
        string nombre
    }
```

## 🛠️ Herramientas recomendadas

| Herramienta | Uso |
|-------------|-----|
| [dbdiagram.io](https://dbdiagram.io/) | Rápido y gratis, exporta a SQL |
| [draw.io](https://app.diagrams.net/) | Diagramas genéricos |
| [Mermaid Live](https://mermaid.live/) | Probar diagramas Mermaid |
| [DBeaver](https://dbeaver.io/) | Cliente BD con ER integrado |

## 💡 Cómo diseñar paso a paso

1. **Lista entidades** (sustantivos clave)
2. **Lista atributos** de cada una
3. **Identifica la PK** de cada entidad
4. **Dibuja relaciones** entre entidades
5. **Define cardinalidades** (1:1, 1:N, N:M)
6. **Resuelve N:M** con tablas intermedias
7. **Revisa**: ¿hay datos duplicados? ¿faltan relaciones?

## ⚠️ Errores comunes

- Confundir `1:N` con `N:1` (mira la dirección)
- Olvidar resolver N:M con tabla intermedia
- No marcar PK/FK en el diagrama
- Poner atributos que pertenecen a otra entidad
- Diagramas tan grandes que no se entienden

## ✅ Ejercicios

1. Dibuja el ER de una red social (usuarios, posts, likes, comentarios)
2. Dibuja el ER de una biblioteca (libros, autores, socios, préstamos)
3. Dibuja el ER de un sistema de facturación (clientes, facturas, líneas)
4. Convierte el ER de la red social a SQL
5. Identifica la entidad débil en un sistema de pedidos y explica por qué

## 🔗 Recursos

- [dbdiagram.io](https://dbdiagram.io/)
- [Mermaid ER](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)