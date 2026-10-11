# 🧪 Ejercicios del Módulo 06

## Archivos

| Archivo | Contenido |
|---------|-----------|
| [ejercicios-01.md](./ejercicios-01.md) | Modelado documental |
| [ejercicios-02.md](./ejercicios-02.md) | MongoDB CRUD y aggregation |
| [ejercicios-03.md](./ejercicios-03.md) | Redis |
| [ejercicios-04.md](./ejercicios-04.md) | Desafíos integradores |

## Preparación

1. Carga el dataset en MongoDB:
```bash
mongosh < ../../recursos/datasets/tienda-nosql.js
```

2. Asegúrate de tener Redis corriendo:
```bash
docker run --name redis-practica -p 6379:6379 -d redis:latest
```

## Recomendaciones

- Practica directamente en `mongosh` o `redis-cli`
- Compara con las consultas SQL del Módulo 02
- Piensa cómo modelarías lo mismo en un mundo y otro