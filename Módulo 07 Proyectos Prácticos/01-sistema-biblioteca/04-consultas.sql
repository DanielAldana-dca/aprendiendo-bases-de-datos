-- ============================================
-- Consultas útiles: Sistema de Biblioteca
-- ============================================

-- ============ LIBROS ============

-- 1. Todos los libros con su editorial, género y autores
SELECT * FROM v_libros_completo ORDER BY titulo;

-- 2. Libros disponibles (con stock)
SELECT titulo, stock_disponible
FROM libros
WHERE stock_disponible > 0
ORDER BY titulo;

-- 3. Libros por género
SELECT g.nombre AS genero, COUNT(*) AS total_libros
FROM libros l
JOIN generos g ON l.genero_id = g.id
GROUP BY g.nombre
ORDER BY total_libros DESC;

-- 4. Libros de un autor específico (García Márquez, id=1)
SELECT l.titulo, l.anio_publicacion
FROM libros l
JOIN libro_autor la ON l.id = la.libro_id
WHERE la.autor_id = 1;

-- ============ PRÉSTAMOS ============

-- 5. Préstamos activos (no devueltos)
SELECT * FROM v_prestamos_activos ORDER BY dias_retraso DESC;

-- 6. Préstamos vencidos con multa calculada
SELECT 
    p.id,
    s.nombre || ' ' || s.apellido AS socio,
    l.titulo AS libro,
    p.fecha_devolucion_esperada,
    CURRENT_DATE - p.fecha_devolucion_esperada AS dias_retraso,
    (CURRENT_DATE - p.fecha_devolucion_esperada) * 0.50 AS multa_estimada
FROM prestamos p
JOIN socios s ON p.socio_id = s.id
JOIN libros l ON p.libro_id = l.id
WHERE p.fecha_devolucion_real IS NULL
  AND p.fecha_devolucion_esperada < CURRENT_DATE
ORDER BY dias_retraso DESC;

-- 7. Préstamos de un socio específico (con historial)
SELECT 
    p.id,
    l.titulo,
    p.fecha_prestamo,
    p.fecha_devolucion_esperada,
    p.fecha_devolucion_real,
    p.estado,
    CASE 
        WHEN p.fecha_devolucion_real IS NULL AND p.fecha_devolucion_esperada < CURRENT_DATE 
        THEN 'VENCIDO'
        ELSE p.estado
    END AS estado_actual
FROM prestamos p
JOIN libros l ON p.libro_id = l.id
WHERE p.socio_id = 1
ORDER BY p.fecha_prestamo DESC;

-- 8. Préstamos por mes
SELECT 
    TO_CHAR(fecha_prestamo, 'YYYY-MM') AS mes,
    COUNT(*) AS total_prestamos,
    COUNT(DISTINCT socio_id) AS socios_unicos
FROM prestamos
GROUP BY mes
ORDER BY mes;

-- ============ RANKINGS ============

-- 9. Top 10 libros más prestados
SELECT 
    l.titulo,
    COUNT(p.id) AS veces_prestado
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY l.id, l.titulo
ORDER BY veces_prestado DESC, l.titulo
LIMIT 10;

-- 10. Top 10 socios más activos
SELECT 
    s.nombre || ' ' || s.apellido AS socio,
    COUNT(p.id) AS total_prestamos,
    COUNT(CASE WHEN p.estado = 'devuelto' THEN 1 END) AS devueltos,
    COUNT(CASE WHEN p.estado = 'prestado' THEN 1 END) AS activos
FROM socios s
LEFT JOIN prestamos p ON s.id = p.socio_id
GROUP BY s.id, s.nombre, s.apellido
ORDER BY total_prestamos DESC
LIMIT 10;

-- 11. Autores con más obras en la biblioteca
SELECT 
    a.nombre || ' ' || a.apellido AS autor,
    COUNT(la.libro_id) AS num_libros
FROM autores a
LEFT JOIN libro_autor la ON a.id = la.autor_id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY num_libros DESC, autor
LIMIT 10;

-- ============ MULTAS ============

-- 12. Multas pendientes de pago
SELECT 
    m.id,
    s.nombre || ' ' || s.apellido AS socio,
    l.titulo AS libro,
    m.monto,
    m.fecha_generacion
FROM multas m
JOIN prestamos p ON m.prestamo_id = p.id
JOIN socios s ON p.socio_id = s.id
JOIN libros l ON p.libro_id = l.id
WHERE m.pagada = FALSE
ORDER BY m.fecha_generacion DESC;

-- 13. Ingresos por multas por mes
SELECT 
    TO_CHAR(fecha_pago, 'YYYY-MM') AS mes,
    COUNT(*) AS num_multas,
    SUM(monto) AS total
FROM multas
WHERE pagada = TRUE AND fecha_pago IS NOT NULL
GROUP BY mes
ORDER BY mes;

-- ============ ANÁLISIS ============

-- 14. Socios con préstamos vencidos
SELECT DISTINCT
    s.id,
    s.nombre || ' ' || s.apellido AS socio,
    s.email,
    COUNT(p.id) AS prestamos_vencidos
FROM socios s
JOIN prestamos p ON s.id = p.socio_id
WHERE p.estado = 'vencido' OR (p.estado = 'prestado' AND p.fecha_devolucion_esperada < CURRENT_DATE)
GROUP BY s.id, s.nombre, s.apellido, s.email
ORDER BY prestamos_vencidos DESC;

-- 15. Géneros más populares (por préstamos)
SELECT 
    g.nombre AS genero,
    COUNT(p.id) AS total_prestamos,
    COUNT(DISTINCT p.socio_id) AS socios_unicos
FROM generos g
JOIN libros l ON g.id = l.genero_id
LEFT JOIN prestamos p ON l.id = p.libro_id
GROUP BY g.id, g.nombre
ORDER BY total_prestamos DESC;

-- 16. Tasa de devolución a tiempo
SELECT 
    ROUND(100.0 * COUNT(CASE WHEN fecha_devolucion_real <= fecha_devolucion_esperada THEN 1 END) 
          / NULLIF(COUNT(CASE WHEN fecha_devolucion_real IS NOT NULL THEN 1 END), 0), 2) 
    AS tasa_a_tiempo_pct
FROM prestamos;

-- 17. Duración promedio de préstamos (en días)
SELECT 
    ROUND(AVG(fecha_devolucion_real - fecha_prestamo), 1) AS duracion_promedio_dias
FROM prestamos
WHERE fecha_devolucion_real IS NOT NULL;

-- 18. Libros nunca prestados
SELECT l.titulo
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
WHERE p.id IS NULL;

-- 19. Ranking de socios por puntualidad
WITH socios_stats AS (
    SELECT 
        s.id,
        s.nombre || ' ' || s.apellido AS socio,
        COUNT(p.id) AS total_prestamos,
        COUNT(CASE WHEN p.fecha_devolucion_real <= p.fecha_devolucion_esperada THEN 1 END) AS a_tiempo
    FROM socios s
    JOIN prestamos p ON s.id = p.socio_id
    WHERE p.fecha_devolucion_real IS NOT NULL
    GROUP BY s.id, s.nombre, s.apellido
)
SELECT 
    socio,
    total_prestamos,
    a_tiempo,
    ROUND(100.0 * a_tiempo / total_prestamos, 1) AS puntualidad_pct,
    RANK() OVER (ORDER BY 100.0 * a_tiempo / total_prestamos DESC) AS ranking
FROM socios_stats
WHERE total_prestamos >= 2
ORDER BY puntualidad_pct DESC;

-- 20. Libros más populares por género
WITH ranking AS (
    SELECT 
        g.nombre AS genero,
        l.titulo,
        COUNT(p.id) AS prestamos,
        ROW_NUMBER() OVER (PARTITION BY g.id ORDER BY COUNT(p.id) DESC) AS rn
    FROM generos g
    JOIN libros l ON g.id = l.genero_id
    LEFT JOIN prestamos p ON l.id = p.libro_id
    GROUP BY g.id, g.nombre, l.id, l.titulo
)
SELECT genero, titulo, prestamos
FROM ranking
WHERE rn = 1
ORDER BY prestamos DESC;