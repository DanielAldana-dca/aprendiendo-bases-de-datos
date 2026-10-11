# 🧪 Ejercicios - Desafíos Integradores

> ⚠️ Sin soluciones. Combina todo lo aprendido: JOINs + GROUP BY + subconsultas.

## 🎯 Desafío 1: Análisis de ventas

Escribe las consultas para obtener:

1. **Ranking de clientes** por dinero gastado (nombre, total, número de pedidos)
2. **Ranking de productos** por ingresos generados (`SUM(cantidad * precio)`)
3. **Ventas por categoría** con su porcentaje sobre el total
4. **Ticket promedio** por cliente (gasto total / número de pedidos)

## 🎯 Desafío 2: Análisis de comportamiento

1. **Clientes fieles:** aquellos que han hecho más de 1 pedido
2. **Clientes dormidos:** registrados antes de junio 2023 y sin pedidos
3. **Productos estrella:** los 3 más vendidos y los 3 menos vendidos
4. **Ciudades top:** ranking de ciudades por ingresos totales

## 🎯 Desafío 3: Reportes avanzados

1. **Evolución mensual:** pedidos y unidades vendidas por mes
2. **Clientes por rango de gasto:** segmenta clientes en:
   - Bajo: menos de 100
   - Medio: entre 100 y 500
   - Alto: más de 500
3. **Productos sin movimiento:** stock actual pero nunca vendidos
4. **Categorías más rentables:** top 3 por ingresos totales

## 🎯 Desafío 4 (Bonus): Análisis cruzado

1. ¿Qué porcentaje de clientes ha comprado en más de una categoría?
2. ¿Cuál es el producto más vendido en cada categoría?
3. ¿Qué clientes han comprado tanto electrónica como ropa?
4. ¿Cuál es el día de la semana con más ventas?

> 💡 **Pista:** para el día de la semana, busca `EXTRACT(DOW FROM fecha)` en PostgreSQL o `strftime('%w', fecha)` en SQLite.

## 🎯 Desafío 5 (Extra): Optimización

Toma las 3 consultas más complejas que hayas escrito y:

1. Identifica qué índices crearías para acelerarlas
2. ¿Podrías reescribir alguna subconsulta como JOIN?
3. ¿Alguna podría beneficiarse de una CTE? (lo verás en el módulo 04)