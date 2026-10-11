# 🧪 Ejercicios adicionales - Sistema de Biblioteca

## Nivel 🟢 Fácil

1. Lista todos los libros ordenados por año de publicación
2. Muestra los socios activos ordenados por fecha de alta
3. ¿Cuántos libros hay por editorial?
4. ¿Cuántos autores son de nacionalidad española?
5. Muestra los préstamos del mes actual

## Nivel 🟡 Intermedio

6. Encuentra los socios que nunca han pedido un libro
7. Muestra los 5 libros más recientes
8. Calcula cuánto ha recaudado la biblioteca en multas pagadas
9. ¿Qué editorial tiene más libros prestados?
10. Duración promedio de préstamo por género
11. Socios con más de 2 préstamos en el último año
12. Libros que se prestan más de lo que se devuelven a tiempo

## Nivel 🔴 Difícil

13. Crea un ranking de socios por puntualidad, mostrando top 5
14. Crea una función que calcule cuántas multas pendientes tiene un socio
15. Crea un trigger que suspenda automáticamente a un socio con 3 multas sin pagar
16. Crea una vista con el "historial completo" de cada socio (préstamos + multas)
17. Encuentra el "libro más esperado": aquel con más tiempo promedio de espera entre devoluciones
18. Ranking mensual de socios más activos con window functions

## 🎯 Retos avanzados

### Reto 1: Sistema de reservas
Añade un sistema de **reservas** de libros:
- Un socio puede reservar un libro no disponible
- Se le notifica cuando se libera
- Prioridad FIFO

Diseña las tablas, triggers y consultas.

### Reto 2: Historial de estados
Añade auditoría de cambios de estado de socios:
- Tabla `socios_historial`
- Trigger que registre cada cambio
- Vista con la línea de tiempo de cada socio

### Reto 3: Dashboard
Crea las consultas para un dashboard con:
- Préstamos activos
- Multas pendientes
- Libros más populares
- Socios más activos
- Tasa de puntualidad del mes

### Reto 4: Optimización
1. Analiza el plan de ejecución de las 5 consultas más lentas
2. Propón índices
3. Mide antes/después
4. Documenta las mejoras