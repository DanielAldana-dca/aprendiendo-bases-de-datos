# 🎯 Proyecto Integrador - Módulo 05

> Diseña una base de datos completa desde cero.

## 🎯 Escenario: sistema de gestión de un gimnasio

### Requisitos

**Socios:**
- Datos personales (nombre, email, teléfono)
- Fecha de alta y estado (activo/inactivo)
- Tipo de membresía (básica, premium, VIP)

**Clases:**
- Nombre, descripción, duración
- Monitor asignado
- Capacidad máxima
- Horarios (día, hora inicio, hora fin)

**Monitores:**
- Datos personales
- Especialidad
- Salario

**Reservas:**
- Un socio reserva una clase en un horario
- Estado: confirmada, cancelada, asistió, no asistió
- Fecha de la reserva

**Pagos:**
- Cuotas de membresía
- Fecha, importe, método de pago
- Estado

**Salas:**
- Nombre, capacidad, ubicación

## 📋 Lo que debes entregar

### 1. Diagrama ER completo

Usa Mermaid o dbdiagram.io. Debe incluir:
- Todas las entidades
- Atributos con tipos
- PK y FK marcados
- Cardinalidades

### 2. Modelo normalizado

Justifica:
- Que estás en 1FN, 2FN y 3FN
- Si desnormalizaste algo, por qué

### 3. Script SQL

Debe incluir:
- `CREATE TABLE` con constraints (CHECK, FK, UNIQUE)
- Índices en FK
- Al menos 1 vista
- Al menos 1 función o trigger

### 4. Datos de prueba

Inserta datos coherentes:
- 5 socios
- 3 monitores
- 5 clases
- 10 reservas
- 5 pagos

### 5. Consultas de ejemplo

Escribe 5 consultas útiles:
- Socios con membresía premium activos
- Clases más reservadas
- Ingresos por mes
- Monitores con más clases
- Socios que no han reservado en 30 días

## 📁 Estructura de entrega

```
05-diseno-bd/proyecto/
├── README.md           -- explicación del diseño
├── diagrama-er.md      -- con Mermaid
├── schema.sql          -- DDL completo
├── datos-prueba.sql    -- inserts
└── consultas.sql       -- 5 queries
```

## ✅ Checklist de autoevaluación

- [ ] Todas las entidades tienen PK
- [ ] Las FK tienen ON DELETE/UPDATE definido
- [ ] No hay datos duplicados (3FN)
- [ ] Los campos tienen tipos apropiados
- [ ] Los CHECK limitan valores inválidos
- [ ] Hay índices en las FK
- [ ] Los nombres son descriptivos (no `tabla1`, `col1`)
- [ ] Los inserts de prueba son coherentes
- [ ] Las 5 consultas funcionan

## 💡 Pistas

- **Socio ↔ Clase** es N:M → necesita tabla `reservas`
- **Clase ↔ Sala** puede ser 1:N o N:M según diseño
- **Clase ↔ Horario** podría ser 1:N (una clase tiene varios horarios)
- **Monitor ↔ Clase** puede ser 1:N o N:M
- Considera usar `ENUM` o `CHECK` para estados
- Para pagos, guarda `metodo` con CHECK

## 🎁 Bonus

- Añade un sistema de **lista de espera** cuando una clase está llena
- Añade **historial de cambios** de membresía
- Diseña un **dashboard SQL** con vistas materializadas