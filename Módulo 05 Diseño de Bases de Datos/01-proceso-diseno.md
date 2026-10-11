# 01 - Proceso de Diseño de Bases de Datos

## 🎯 Objetivos

- Conocer las fases del diseño de una BD
- Diferenciar modelo conceptual, lógico y físico
- Identificar entidades, atributos y relaciones

## 📚 Fases del diseño

```
1. Análisis de requisitos
        ↓
2. Modelo conceptual (¿qué datos?)
        ↓
3. Modelo lógico (¿cómo se relacionan?)
        ↓
4. Modelo físico (¿cómo se implementa?)
        ↓
5. Implementación y pruebas
```

### 1. Análisis de requisitos

**Pregunta clave:** ¿qué problema resuelve la BD?

Recopila:
- Qué datos hay que guardar
- Quién los va a usar
- Qué consultas serán frecuentes
- Restricciones (legales, técnicas, presupuesto)

**Técnica:** entrevistas, formularios, revisión de sistemas existentes.

### 2. Modelo conceptual

- Identifica **entidades** (cosas del mundo real)
- Define **atributos** (características)
- Establece **relaciones** entre ellas

**Herramienta:** diagrama ER (ver siguiente archivo).

No importa el motor de BD ni el SQL todavía.

### 3. Modelo lógico

- Traduce el modelo conceptual a **tablas**
- Define **PK** y **FK**
- Aplica **normalización**
- No depende aún del motor específico

### 4. Modelo físico

- Adapta al motor (PostgreSQL, MySQL...)
- Define tipos de datos exactos
- Crea **índices**
- Considera particionado, tablespaces, etc.

### 5. Implementación y pruebas

- Ejecuta el DDL
- Carga datos de prueba
- Valida las consultas más frecuentes
- Optimiza según necesidad

## 🔍 Identificar entidades

Una **entidad** es algo sobre lo que queremos guardar información.

### Preguntas guía
- ¿Es un sustantivo importante del dominio? (Cliente, Producto, Pedido)
- ¿Necesitamos guardar múltiples instancias? (sí → entidad)
- ¿Tiene atributos propios? (sí → entidad)

### Ejemplos por dominio

| Dominio | Entidades |
|---------|-----------|
| Biblioteca | Libro, Autor, Usuario, Préstamo |
| E-commerce | Cliente, Producto, Pedido, Categoría |
| Red social | Usuario, Publicación, Comentario, Amistad |
| Hospital | Paciente, Médico, Cita, Diagnóstico |

## 🔍 Identificar atributos

Un **atributo** es una propiedad de la entidad.

### Reglas
- Cada atributo debe ser **atómico** (no listas)
- Cada atributo debe describir **directamente** a la entidad
- Los atributos repetidos se convierten en **relaciones**

### Ejemplo

❌ Mal:
```
Cliente: id, nombre, teléfonos (lista), dirección_completa
```

✅ Bien:
```
Cliente: id, nombre, email
Teléfono: id, cliente_id, número, tipo
Dirección: id, cliente_id, calle, ciudad, cp, país
```

## 🔍 Identificar relaciones

Una **relación** conecta dos o más entidades.

### Preguntas guía
- ¿Qué entidades se afectan mutuamente?
- ¿Cuántas instancias de A se relacionan con B? (cardinalidad)

### Cardinalidades

| Notación | Significado | Ejemplo |
|----------|-------------|---------|
| 1:1 | Uno a uno | Usuario ↔ Perfil |
| 1:N | Uno a muchos | Cliente → Pedidos |
| N:M | Muchos a muchos | Estudiante ↔ Curso |

## 💡 Ejemplo completo: sistema de biblioteca

### Requisitos
- Gestionar libros, autores, socios y préstamos
- Un libro puede tener varios autores
- Un socio puede pedir varios libros
- Registrar fechas de préstamo y devolución

### Modelo conceptual

**Entidades:**
- Libro (id, título, ISBN, año)
- Autor (id, nombre, nacionalidad)
- Socio (id, nombre, email, fecha_alta)
- Préstamo (id, fecha_prestamo, fecha_devolución)

**Relaciones:**
- Libro N:M Autor
- Socio 1:N Préstamo
- Préstamo N:1 Libro

### Modelo lógico

```
libros(id PK, titulo, isbn UNIQUE, anio)
autores(id PK, nombre, nacionalidad)
libro_autor(libro_id FK, autor_id FK)  -- N:M
socios(id PK, nombre, email UNIQUE, fecha_alta)
prestamos(id PK, socio_id FK, libro_id FK, fecha_prestamo, fecha_devolucion)
```

### Modelo físico (PostgreSQL)

```sql
CREATE TABLE libros (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    anio INTEGER
);

CREATE TABLE autores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libro_autor (
    libro_id INTEGER REFERENCES libros(id),
    autor_id INTEGER REFERENCES autores(id),
    PRIMARY KEY (libro_id, autor_id)
);

CREATE TABLE socios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    fecha_alta DATE DEFAULT CURRENT_DATE
);

CREATE TABLE prestamos (
    id SERIAL PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id),
    libro_id INTEGER NOT NULL REFERENCES libros(id),
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE
);

CREATE INDEX idx_prestamos_socio ON prestamos(socio_id);
CREATE INDEX idx_prestamos_libro ON prestamos(libro_id);
```

## ⚠️ Errores comunes

- Empezar a escribir SQL sin haber modelado
- Confundir entidad con atributo
- Guardar listas en una columna (viola 1FN)
- Duplicar información en varias tablas
- Ignorar las consultas frecuentes al diseñar

## ✅ Ejercicios

1. Lista entidades, atributos y relaciones para una app de tareas (tipo Trello)
2. Diseña el modelo lógico de un sistema de facturación
3. ¿Cuál es la diferencia entre modelo conceptual y físico?
4. Diseña una BD para un gimnasio (socios, clases, monitores, reservas)

## 🔗 Recursos

- [Database Design - Lucidchart](https://www.lucidchart.com/pages/database-diagram/database-design)