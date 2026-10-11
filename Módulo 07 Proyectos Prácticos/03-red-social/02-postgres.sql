-- ============================================
-- Red Social - PostgreSQL
-- ============================================

DROP TABLE IF EXISTS notificaciones CASCADE;
DROP TABLE IF EXISTS bloqueos CASCADE;
DROP TABLE IF EXISTS follows CASCADE;
DROP TABLE IF EXISTS perfiles CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- ============================================
-- USUARIOS
-- ============================================

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE,
    verificado BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

CREATE TABLE perfiles (
    usuario_id INTEGER PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    fecha_nacimiento DATE,
    ubicacion VARCHAR(100),
    sitio_web VARCHAR(200),
    actualizado TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- RELACIONES SOCIALES
-- ============================================

CREATE TABLE follows (
    seguidor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    seguido_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    fecha TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (seguidor_id, seguido_id),
    CHECK (seguidor_id != seguido_id)
);

CREATE INDEX idx_follows_seguidor ON follows(seguidor_id);
CREATE INDEX idx_follows_seguido ON follows(seguido_id);

CREATE TABLE bloqueos (
    bloqueador_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    bloqueado_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    fecha TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (bloqueador_id, bloqueado_id),
    CHECK (bloqueador_id != bloqueado_id)
);

-- ============================================
-- NOTIFICACIONES
-- ============================================

CREATE TABLE notificaciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL 
        CHECK (tipo IN ('follow','like','comentario','mencion','mensaje')),
    actor_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    referencia_id VARCHAR(50),      -- ID del post/comentario (ObjectId string)
    contenido TEXT,
    leida BOOLEAN DEFAULT FALSE,
    fecha TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notif_usuario_leida ON notificaciones(usuario_id, leida);
CREATE INDEX idx_notif_fecha ON notificaciones(fecha);

-- ============================================
-- FUNCIONES
-- ============================================

-- Contar seguidores
CREATE OR REPLACE FUNCTION contar_seguidores(p_usuario_id INTEGER)
RETURNS INTEGER AS $$
    SELECT COUNT(*) FROM follows WHERE seguido_id = p_usuario_id;
$$ LANGUAGE sql;

-- Contar seguidos
CREATE OR REPLACE FUNCTION contar_seguidos(p_usuario_id INTEGER)
RETURNS INTEGER AS $$
    SELECT COUNT(*) FROM follows WHERE seguidor_id = p_usuario_id;
$$ LANGUAGE sql;

-- Verificar si A sigue a B
CREATE OR REPLACE FUNCTION sigue_a(p_seguidor INTEGER, p_seguido INTEGER)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM follows 
        WHERE seguidor_id = p_seguidor AND seguido_id = p_seguido
    );
$$ LANGUAGE sql;

-- ============================================
-- VISTAS
-- ============================================

CREATE VIEW v_usuarios_stats AS
SELECT 
    u.id,
    u.username,
    p.nombre,
    p.avatar_url,
    (SELECT COUNT(*) FROM follows WHERE seguido_id = u.id) AS seguidores,
    (SELECT COUNT(*) FROM follows WHERE seguidor_id = u.id) AS siguiendo
FROM usuarios u
LEFT JOIN perfiles p ON u.id = p.usuario_id
WHERE u.activo = TRUE;