-- ============================================
-- Consultas para la API - Tareas
-- ============================================

-- ============ LISTAR TAREAS ============

-- 1. Tareas de un proyecto (paginación básica)
SELECT * FROM v_tareas_completas
WHERE proyecto = 'Mi proyecto'
ORDER BY prioridad ASC, fecha_limite ASC NULLS LAST
LIMIT 20 OFFSET 0;

-- 2. Tareas con filtros dinámicos
SELECT * FROM v_tareas_completas
WHERE estado = 'pendiente'
  AND prioridad <= 2
ORDER BY fecha_limite ASC NULLS LAST
LIMIT 20;

-- 3. Mis tareas (asignadas a mí)
SELECT * FROM v_tareas_completas
WHERE asignado = 'Ana'
  AND estado != 'completada'
ORDER BY fecha_limite ASC NULLS LAST;

-- ============ FILTROS TEMPORALES ============

-- 4. Tareas que vencen hoy
SELECT * FROM v_tareas_completas
WHERE fecha_limite::date = CURRENT_DATE
  AND estado != 'completada'
ORDER BY prioridad ASC;

-- 5. Tareas que vencen esta semana
SELECT * FROM v_tareas_completas
WHERE fecha_limite BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
  AND estado != 'completada'
ORDER BY fecha_limite ASC;

-- 6. Tareas vencidas (retrasadas)
SELECT 
    *,
    CURRENT_DATE - fecha_limite::date AS dias_retraso
FROM v_tareas_completas
WHERE fecha_limite < CURRENT_DATE
  AND estado NOT IN ('completada', 'archivada')
ORDER BY dias_retraso DESC;

-- ============ BÚSQUEDA FULL-TEXT ============

-- 7. Buscar por texto
SELECT id, titulo, 
       ts_rank(to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, '')), 
               to_tsquery('spanish', 'comprar')) AS relevancia
FROM tareas
WHERE to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, '')) 
      @@ to_tsquery('spanish', 'comprar')
ORDER BY relevancia DESC
LIMIT 20;

-- 8. Buscar por etiqueta
SELECT t.id, t.titulo
FROM tareas t
JOIN tarea_etiqueta te ON t.id = te.tarea_id
JOIN etiquetas e ON te.etiqueta_id = e.id
WHERE e.nombre = 'urgente'
ORDER BY t.fecha_limite ASC;

-- ============ SUBTAREAS ============

-- 9. Tareas raíz de un proyecto (sin padre)
SELECT id, titulo, estado, prioridad
FROM tareas
WHERE proyecto_id = 1
  AND padre_id IS NULL
ORDER BY orden, fecha_creacion;

-- 10. Subtareas de una tarea
SELECT id, titulo, estado
FROM tareas
WHERE padre_id = 5
ORDER BY orden;

-- 11. Árbol completo (CTE recursiva)
WITH RECURSIVE arbol AS (
    -- Raíz
    SELECT id, titulo, padre_id, 1 AS nivel, 
           ARRAY[id] AS path
    FROM tareas
    WHERE id = 1
    
    UNION ALL
    
    -- Hijos
    SELECT t.id, t.titulo, t.padre_id, a.nivel + 1, 
           a.path || t.id
    FROM tareas t
    JOIN arbol a ON t.padre_id = a.id
)
SELECT 
    REPEAT('  ', nivel - 1) || titulo AS tarea_jerarquica,
    nivel
FROM arbol
ORDER BY path;

-- ============ DASHBOARD ============

-- 12. Resumen del usuario
SELECT 
    COUNT(*) FILTER (WHERE estado = 'pendiente') AS pendientes,
    COUNT(*) FILTER (WHERE estado = 'en_progreso') AS en_progreso,
    COUNT(*) FILTER (WHERE estado = 'completada') AS completadas,
    COUNT(*) FILTER (WHERE fecha_limite < CURRENT_DATE AND estado NOT IN ('completada','archivada')) AS vencidas,
    COUNT(*) FILTER (WHERE fecha_limite::date = CURRENT_DATE AND estado != 'completada') AS para_hoy
FROM tareas
WHERE asignado_id = 1;

-- 13. Productividad por semana
SELECT 
    DATE_TRUNC('week', fecha_completada) AS semana,
    COUNT(*) AS tareas_completadas
FROM tareas
WHERE asignado_id = 1
  AND estado = 'completada'
  AND fecha_completada >= CURRENT_DATE - INTERVAL '12 weeks'
GROUP BY semana
ORDER BY semana;

-- 14. Top proyectos por tareas pendientes
SELECT 
    p.nombre AS proyecto,
    COUNT(*) FILTER (WHERE t.estado = 'pendiente') AS pendientes,
    COUNT(*) FILTER (WHERE t.estado = 'completada') AS completadas,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.estado = 'completada') / NULLIF(COUNT(*), 0), 1) AS progreso_pct
FROM proyectos p
JOIN tareas t ON p.id = t.proyecto_id
WHERE p.archivado = FALSE
GROUP BY p.id, p.nombre
ORDER BY pendientes DESC;

-- 15. Tareas por prioridad
SELECT 
    prioridad,
    CASE prioridad
        WHEN 1 THEN 'Urgente'
        WHEN 2 THEN 'Alta'
        WHEN 3 THEN 'Media'
        WHEN 4 THEN 'Baja'
    END AS nivel,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE estado = 'completada') AS completadas
FROM tareas
WHERE asignado_id = 1
GROUP BY prioridad
ORDER BY prioridad;

-- ============ ACTIVIDAD ============

-- 16. Últimas acciones en un proyecto
SELECT 
    a.fecha,
    u.nombre AS usuario,
    a.accion,
    t.titulo AS tarea
FROM actividad a
LEFT JOIN usuarios u ON a.usuario_id = u.id
LEFT JOIN tareas t ON a.tarea_id = t.id
JOIN tareas tt ON a.tarea_id = tt.id
WHERE tt.proyecto_id = 1
ORDER BY a.fecha DESC
LIMIT 50;

-- ============ PAGINACIÓN ============

-- 17. Keyset pagination (más eficiente que OFFSET)
SELECT id, titulo, fecha_limite
FROM tareas
WHERE asignado_id = 1
  AND (fecha_limite, id) > ('2024-03-15 10:00:00', 100)
ORDER BY fecha_limite, id
LIMIT 20;

-- ============ ESTADÍSTICAS ============

-- 18. Tiempo promedio de completado
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (fecha_completada - fecha_creacion))/3600)::numeric, 2) AS horas_promedio
FROM tareas
WHERE estado = 'completada'
  AND fecha_completada >= CURRENT_DATE - INTERVAL '30 days';

-- 19. Cumplimiento de plazos
SELECT 
    ROUND(100.0 * COUNT(*) FILTER (WHERE fecha_completada <= fecha_limite) 
          / NULLIF(COUNT(*) FILTER (WHERE fecha_completada IS NOT NULL AND fecha_limite IS NOT NULL), 0), 2) 
    AS pct_a_tiempo
FROM tareas
WHERE estado = 'completada';

-- 20. Etiquetas más usadas
SELECT 
    e.nombre AS etiqueta,
    e.color,
    COUNT(te.tarea_id) AS usos
FROM etiquetas e
LEFT JOIN tarea_etiqueta te ON e.id = te.etiqueta_id
WHERE e.usuario_id = 1
GROUP BY e.id, e.nombre, e.color
ORDER BY usos DESC;