-- ============================================
-- API de Tareas - Schema
-- ============================================

DROP TABLE IF EXISTS actividad CASCADE;
DROP TABLE IF EXISTS recordatorios CASCADE;
DROP TABLE IF EXISTS comentarios CASCADE;
DROP TABLE IF EXISTS tarea_etiqueta CASCADE;
DROP TABLE IF EXISTS etiquetas CASCADE;
DROP TABLE IF EXISTS tareas CASCADE;
DROP TABLE IF EXISTS proyecto_miembro CASCADE;
DROP TABLE IF EXISTS proyectos CASCADE;
DROP TABLE IF EXISTS preferencias CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- ============================================
-- USUARIOS
-- ============================================

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE preferencias (
    usuario_id INTEGER PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
    tema VARCHAR(20) DEFAULT 'claro' CHECK (tema IN ('claro','oscuro','auto')),
    idioma VARCHAR(10) DEFAULT 'es',
    notif_email BOOLEAN DEFAULT TRUE,
    zona_horaria VARCHAR(50) DEFAULT 'Europe/Madrid'
);

-- ============================================
-- PROYECTOS
-- ============================================

CREATE TABLE proyectos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#3B82F6',
    icono VARCHAR(50),
    archivado BOOLEAN DEFAULT FALSE,
    orden INTEGER DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_proyectos_usuario ON proyectos(usuario_id);
CREATE INDEX idx_proyectos_archivado ON proyectos(archivado);

CREATE TABLE proyecto_miembro (
    proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol VARCHAR(20) NOT NULL DEFAULT 'miembro' 
        CHECK (rol IN ('propietario','admin','miembro','lector')),
    fecha TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (proyecto_id, usuario_id)
);

CREATE INDEX idx_proyecto_miembro_usuario ON proyecto_miembro(usuario_id);

-- ============================================
-- TAREAS
-- ============================================

CREATE TABLE tareas (
    id SERIAL PRIMARY KEY,
    proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    asignado_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    padre_id INTEGER REFERENCES tareas(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    prioridad INTEGER NOT NULL DEFAULT 4 CHECK (prioridad BETWEEN 1 AND 4),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','en_progreso','completada','archivada')),
    fecha_limite TIMESTAMP,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_completada TIMESTAMP,
    orden INTEGER DEFAULT 0
);

CREATE INDEX idx_tareas_proyecto ON tareas(proyecto_id);
CREATE INDEX idx_tareas_padre ON tareas(padre_id);
CREATE INDEX idx_tareas_asignado ON tareas(asignado_id);
CREATE INDEX idx_tareas_fecha_limite ON tareas(fecha_limite) WHERE fecha_limite IS NOT NULL;
CREATE INDEX idx_tareas_estado ON tareas(estado);
CREATE INDEX idx_tareas_usuario ON tareas(usuario_id);

-- Índice compuesto para filtros comunes
CREATE INDEX idx_tareas_proyecto_estado_prioridad 
ON tareas(proyecto_id, estado, prioridad);

-- Full-text search
CREATE INDEX idx_tareas_fts ON tareas 
USING GIN(to_tsvector('spanish', titulo || ' ' || COALESCE(descripcion, '')));

-- ============================================
-- ETIQUETAS
-- ============================================

CREATE TABLE etiquetas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(50) NOT NULL,
    color VARCHAR(20) DEFAULT '#94A3B8',
    UNIQUE(usuario_id, nombre)
);

CREATE INDEX idx_etiquetas_usuario ON etiquetas(usuario_id);

CREATE TABLE tarea_etiqueta (
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    etiqueta_id INTEGER NOT NULL REFERENCES etiquetas(id) ON DELETE CASCADE,
    PRIMARY KEY (tarea_id, etiqueta_id)
);

CREATE INDEX idx_tarea_etiqueta_etiqueta ON tarea_etiqueta(etiqueta_id);

-- ============================================
-- COMENTARIOS Y RECORDATORIOS
-- ============================================

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_comentarios_tarea ON comentarios(tarea_id);

CREATE TABLE recordatorios (
    id SERIAL PRIMARY KEY,
    tarea_id INTEGER NOT NULL REFERENCES tareas(id) ON DELETE CASCADE,
    fecha TIMESTAMP NOT NULL,
    tipo VARCHAR(20) DEFAULT 'notificacion' 
        CHECK (tipo IN ('notificacion','email','push')),
    enviado BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_recordatorios_pendientes ON recordatorios(fecha) WHERE enviado = FALSE;

-- ============================================
-- ACTIVIDAD (auditoría)
-- ============================================

CREATE TABLE actividad (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    tarea_id INTEGER REFERENCES tareas(id) ON DELETE CASCADE,
    accion VARCHAR(30) NOT NULL,
    datos JSONB,
    fecha TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_actividad_tarea ON actividad(tarea_id);
CREATE INDEX idx_actividad_fecha ON actividad(fecha);

-- ============================================
-- TRIGGERS
-- ============================================

-- Marcar fecha_completada automáticamente
CREATE OR REPLACE FUNCTION tarea_completada_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'completada' AND (OLD.estado IS NULL OR OLD.estado != 'completada') THEN
        NEW.fecha_completada := NOW();
    ELSIF NEW.estado != 'completada' THEN
        NEW.fecha_completada := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_tarea_completada
BEFORE INSERT OR UPDATE ON tareas
FOR EACH ROW
EXECUTE FUNCTION tarea_completada_trigger();

-- ============================================
-- VISTAS
-- ============================================

CREATE VIEW v_tareas_completas AS
SELECT 
    t.id,
    t.titulo,
    t.descripcion,
    t.estado,
    t.prioridad,
    t.fecha_limite,
    t.fecha_creacion,
    p.nombre AS proyecto,
    u.nombre AS creador,
    a.nombre AS asignado,
    (SELECT COUNT(*) FROM tareas WHERE padre_id = t.id) AS num_subtareas,
    (SELECT COUNT(*) FROM comentarios WHERE tarea_id = t.id) AS num_comentarios,
    COALESCE(
        (SELECT array_agg(e.nombre) FROM tarea_etiqueta te 
         JOIN etiquetas e ON te.etiqueta_id = e.id 
         WHERE te.tarea_id = t.id),
        ARRAY[]::VARCHAR[]
    ) AS etiquetas
FROM tareas t
JOIN proyectos p ON t.proyecto_id = p.id
JOIN usuarios u ON t.usuario_id = u.id
LEFT JOIN usuarios a ON t.asignado_id = a.id;