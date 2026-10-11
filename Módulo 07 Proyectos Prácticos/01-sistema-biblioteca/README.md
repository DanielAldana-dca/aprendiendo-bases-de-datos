# 📚 Proyecto 01: Sistema de Biblioteca

Sistema completo para gestionar libros, autores, socios y préstamos.

## 🎯 Objetivos

- Diseñar un ER desde cero
- Normalizar hasta 3FN
- Escribir DDL con constraints
- Crear consultas útiles
- Documentar el proyecto

## 📋 Requisitos funcionales

### Gestión de libros
- Registrar libros con título, ISBN, año, editorial
- Un libro puede tener varios autores
- Un autor puede escribir varios libros
- Categorizar libros por género

### Gestión de socios
- Registrar socios con datos personales
- Un socio puede tener un estado (activo, suspendido, baja)
- Registrar fecha de alta

### Gestión de préstamos
- Un socio puede pedir varios libros
- Un libro puede estar prestado a un solo socio a la vez
- Registrar fecha de préstamo y devolución
- Calcular multas por retraso

### Reportes
- Libros más prestados
- Socios más activos
- Préstamos vencidos
- Disponibilidad de un libro

## 🗂️ Estructura del proyecto

```
01-sistema-biblioteca/
├── README.md           -- este archivo
├── 01-diseno.md        -- ER y modelo
├── 02-schema.sql       -- DDL
├── 03-datos-prueba.sql -- inserts
├── 04-consultas.sql    -- queries útiles
└── 05-ejercicios.md    -- retos adicionales
```

## 📅 Fases del proyecto

1. **Diseño** (2-3 horas)
   - Diagrama ER en Mermaid
   - Normalización a 3FN

2. **DDL** (2 horas)
   - CREATE TABLE con constraints
   - Índices apropiados

3. **Datos de prueba** (1 hora)
   - 20 libros, 10 autores, 15 socios, 30 préstamos

4. **Consultas** (2-3 horas)
   - 15 queries que resuelvan los reportes

5. **Optimización** (1 hora)
   - EXPLAIN y ajuste de índices

## ✅ Entregables

- [ ] `01-diseno.md` con diagrama ER
- [ ] `02-schema.sql` ejecutable sin errores
- [ ] `03-datos-prueba.sql` con datos coherentes
- [ ] `04-consultas.sql` con 15 consultas comentadas
- [ ] Justificación de índices
- [ ] README explicando decisiones

## 🎓 Lo que practicarás

- Modelado ER
- Normalización
- FK y constraints
- JOINs complejos
- GROUP BY y agregadas
- Índices