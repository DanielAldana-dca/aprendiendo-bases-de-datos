# 📗 Módulo 02: SQL Básico

Tu primera interacción real con bases de datos. Aquí aprendes a **consultar** y **modificar** datos.

## 📂 Contenido

| # | Tema | Enlace |
|---|------|--------|
| 01 | SELECT | [01-select.md](./01-select.md) |
| 02 | WHERE | [02-where.md](./02-where.md) |
| 03 | ORDER BY y LIMIT | [03-order-by-limit.md](./03-order-by-limit.md) |
| 04 | INSERT, UPDATE, DELETE | [04-insert-update-delete.md](./04-insert-update-delete.md) |
| 05 | Ejercicios | [ejercicios/](./ejercicios/) |

## 🎯 Objetivos

- Consultar datos con SELECT
- Filtrar con WHERE
- Ordenar y limitar resultados
- Insertar, actualizar y borrar registros

## 🛠️ Preparación del entorno

Elige **una** opción para practicar:

### Opción A: SQLite (más fácil, sin instalar servidor)

```bash
# Linux/Mac
sqlite3 practica.db

# O usa https://sqliteonline.com/
```

### Opción B: PostgreSQL

```bash
docker run --name pg-practica -e POSTGRES_PASSWORD=pass -p 5432:5432 -d postgres
```

### Opción C: MySQL

```bash
docker run --name mysql-practica -e MYSQL_ROOT_PASSWORD=pass -p 3306:3306 -d mysql
```

## 📦 Dataset de práctica

Antes de empezar, carga el dataset: [`recursos/datasets/tienda.sql`](../recursos/datasets/tienda.sql)

## ⏱️ Tiempo estimado

6-8 horas