# 🧪 Ejercicios - Módulo 02 (Parte 2: Desafíos)

Ejercicios que combinan todo lo aprendido. **Sin soluciones** — el reto es tuyo.

## 🎯 Desafío 1: Análisis de tienda

Escribe consultas para responder:

1. ¿Cuántos productos hay en cada categoría? (pista: `GROUP BY` — lo verás en módulo 3, investígalo)
2. ¿Cuál es el producto más caro y el más barato?
3. ¿Qué clientes se registraron en el primer trimestre de 2023?
4. Lista los productos ordenados por relación stock/precio (más stock por euro gastado)

## 🎯 Desafío 2: Simulación de tienda

1. Inserta 5 clientes nuevos de diferentes ciudades
2. Inserta 3 pedidos para cada uno
3. Actualiza el stock de los productos vendidos (resta la cantidad pedida)
4. Muestra todos los clientes que hayan hecho al menos un pedido

## 🎯 Desafío 3: Limpieza de datos

Simula que eres el DBA:

1. Detecta los productos con stock = 0
2. Elimina los clientes sin email **pero** antes debes borrar sus pedidos (integridad referencial)
3. Actualiza todos los emails de clientes agregando el dominio si no lo tienen (ej: `ana` → `ana@mail.com`)

## 🎯 Desafío 4 (Bonus): Inventario

Crea las consultas para un reporte de inventario:

- Total de productos por categoría
- Valor total del inventario (suma de `precio * stock`)
- Productos que necesitan reabastecimiento (stock < 10)
- Top 5 productos con mayor valor en stock

> 💡 Estos desafíos te preparan para el Módulo 03 (JOINs y funciones agregadas).