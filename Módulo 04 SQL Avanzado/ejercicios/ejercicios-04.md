# 🧪 Ejercicios - Desafíos Integradores

> ⚠️ Sin soluciones. Combina CTEs + window functions + CASE.

## 🎯 Desafío 1: Reporte ejecutivo

Genera un reporte con:
1. Total de ingresos por mes (con CTE)
2. Variación porcentual respecto al mes anterior (LAG)
3. Ranking de meses por ingresos (RANK)

## 🎯 Desafío 2: Análisis de cohortes

1. Clasifica clientes por mes de registro (CTE)
2. Cuenta cuántos clientes hay por cohorte
3. Calcula el gasto promedio por cohorte

## 🎯 Desafío 3: Top performers

1. Top 3 clientes por gasto
2. Top 3 productos por ingresos
3. Top 3 categorías por ingresos
4. Top 3 ciudades por ingresos

Todo en **una sola consulta** con CTEs y `UNION ALL`.

## 🎯 Desafío 4: Análisis temporal

1. Días entre el primer y último pedido de cada cliente
2. Clientes que compraron en meses consecutivos
3. Ticket promedio por mes con window function

## 🎯 Desafío 5: Dashboard de negocio

Crea una consulta que devuelva en una sola fila:
- Total de clientes
- Clientes activos (con al menos 1 pedido)
- Clientes inactivos
- Ticket promedio global
- Producto más vendido
- Categoría más rentable
- Mes con más ventas

> 💡 **Pista:** usa subconsultas escalares dentro del SELECT.

## 🎯 Desafío 6: Optimización

Para cada consulta compleja que hayas escrito:
1. Crea los índices necesarios
2. Analiza el plan de ejecución antes y después
3. Documenta la mejora en tiempo