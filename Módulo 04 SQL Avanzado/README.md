# 📕 Módulo 04: SQL Avanzado

Temas que separan a un usuario de SQL de un **profesional**. CTEs, window functions, índices, transacciones y más.

## 📂 Contenido

| # | Tema | Enlace |
|---|------|--------|
| 01 | CTEs (WITH) | [01-ctes.md](./01-ctes.md) |
| 02 | Window Functions | [02-window-functions.md](./02-window-functions.md) |
| 03 | CASE y COALESCE | [03-case-coalesce.md](./03-case-coalesce.md) |
| 04 | Índices | [04-indices.md](./04-indices.md) |
| 05 | Transacciones | [05-transacciones.md](./05-transacciones.md) |
| 06 | Vistas y Procedimientos | [06-vistas-procedimientos.md](./06-vistas-procedimientos.md) |
| 07 | Ejercicios | [ejercicios/](./ejercicios/) |

## 🎯 Objetivos

- Escribir consultas legibles con CTEs
- Dominar window functions (ROW_NUMBER, RANK, LAG, LEAD...)
- Transformar datos con CASE y manejar NULL con COALESCE
- Entender y crear índices
- Usar transacciones con seguridad
- Crear vistas y procedimientos almacenados

## 📦 Dataset

Sigue usando [`recursos/datasets/tienda.sql`](../recursos/datasets/tienda.sql)

## ⚠️ Compatibilidad

- **CTEs, Window Functions, CASE, COALESCE:** funcionan en PostgreSQL, MySQL 8+, SQLite 3.25+, SQL Server
- **Índices, Transacciones, Vistas:** todos los motores
- **Procedimientos:** sintaxis muy distinta entre motores (ejemplos para PostgreSQL)

## ⏱️ Tiempo estimado

10-12 horas