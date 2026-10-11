# 📝 Proyecto 04: API de Tareas

Diseño de base de datos para una API REST de gestión de tareas (tipo Todoist).

## 🎯 Objetivos

- Pensar en las consultas de la app, no solo en los datos
- Diseñar para APIs (paginación, filtros, orden)
- Modelar jerarquías
- Optimizar para lecturas frecuentes

## 📋 Requisitos funcionales

### Usuarios
- Registro y login
- Preferencias (tema, idioma, notificaciones)

### Proyectos
- Agrupan tareas
- Color e ícono
- Archivar

### Tareas
- Título, descripción, fecha límite
- Prioridad (1-4)
- Estado (pendiente, en_progreso, completada)
- Subtareas (jerarquía)
- Etiquetas
- Recordatorios

### Colaboración
- Compartir proyectos
- Asignar tareas
- Comentarios

### Búsqueda
- Por texto
- Por etiqueta
- Por fecha
- Por estado

## 🗂️ Estructura del proyecto

```
04-api-tareas/
├── README.md           -- este archivo
├── 01-diseno.md        -- ER, decisiones
├── 02-schema.sql       -- DDL
├── 03-api-endpoints.md -- consultas por endpoint
├── 04-consultas.sql    -- queries de la API
└── 05-optimizacion.md  -- índices y planes
```

## 🎓 Lo que practicarás

- Modelar para API
- Paginación eficiente
- Filtros dinámicos
- Jerarquías (subtareas)
- Full-text search
- Índices compuestos