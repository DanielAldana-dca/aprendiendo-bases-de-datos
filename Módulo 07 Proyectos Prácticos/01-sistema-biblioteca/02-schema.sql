-- ============================================
-- Sistema de Biblioteca - Schema
-- Motor: PostgreSQL (adaptable a MySQL/SQLite)
-- ============================================

DROP TABLE IF EXISTS multas CASCADE;
DROP TABLE IF EXISTS prestamos CASCADE;
DROP TABLE IF EXISTS libro_autor CASCADE;
DROP TABLE IF EXISTS libros CASCADE;
DROP TABLE IF EXISTS autores CASCADE;
DROP TABLE IF EXISTS editoriales CASCADE;
DROP TABLE IF EXISTS generos CASCADE;
DROP TABLE IF EXISTS socios CASCADE;

-- ============================================
-- CATÁLOGOS
-- ============================================

CREATE TABLE editoriales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    pais VARCHAR(50),
    fundacion INTEGER CHECK (fundacion > 1400 AND fundacion < 2100)
);

CREATE TABLE generos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- ============================================
-- LIBROS
-- ============================================

CREATE TABLE autores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50),
    fecha_nacimiento DATE
);

CREATE TABLE libros (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    anio_publicacion INTEGER CHECK (anio_publicacion > 1000),
    editorial_id INTEGER REFERENCES editoriales(id) ON DELETE SET NULL,
    genero_id INTEGER REFERENCES generos(id) ON DELETE SET NULL,
    num_paginas INTEGER CHECK (num_paginas > 0),
    stock_total INTEGER NOT NULL DEFAULT 1 CHECK (stock_total >= 0),
    stock_disponible INTEGER NOT NULL DEFAULT 1 CHECK (stock_disponible >= 0),
    CHECK (stock_disponible <= stock_total),
    fecha_alta TIMESTAMP DEFAULT NOW()
);

CREATE TABLE libro_autor (
    libro_id INTEGER REFERENCES libros(id) ON DELETE CASCADE,
    autor_id INTEGER REFERENCES autores(id) ON DELETE CASCADE,
    PRIMARY KEY (libro_id, autor_id)
);

-- ============================================
-- SOCIOS
-- ============================================

CREATE TABLE socios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'suspendido', 'baja')),
    fecha_baja DATE
);

-- ============================================
-- PRÉSTAMOS
-- ============================================

CREATE TABLE prestamos (
    id SERIAL PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id) ON DELETE RESTRICT,
    libro_id INTEGER NOT NULL REFERENCES libros(id) ON DELETE RESTRICT,
    fecha_prestamo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'prestado'
        CHECK (estado IN ('prestado', 'devuelto', 'vencido')),
    CHECK (fecha_devolucion_esperada > fecha_prestamo),
    CHECK (fecha_devolucion_real IS NULL OR fecha_devolucion_real >= fecha_prestamo)
);

CREATE TABLE multas (
    id SERIAL PRIMARY KEY,
    prestamo_id INTEGER NOT NULL UNIQUE REFERENCES prestamos(id) ON DELETE CASCADE,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    pagada BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_generacion DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_pago DATE
);

-- ============================================
-- ÍNDICES
-- ============================================

CREATE INDEX idx_libros_titulo ON libros(titulo);
CREATE INDEX idx_libros_genero ON libros(genero_id);
CREATE INDEX idx_libros_editorial ON libros(editorial_id);
CREATE INDEX idx_libro_autor_autor ON libro_autor(autor_id);
CREATE INDEX idx_prestamos_socio ON prestamos(socio_id);
CREATE INDEX idx_prestamos_libro ON prestamos(libro_id);
CREATE INDEX idx_prestamos_estado ON prestamos(estado);
CREATE INDEX idx_prestamos_fecha ON prestamos(fecha_prestamo);
CREATE INDEX idx_socios_estado ON socios(estado);
CREATE INDEX idx_multas_pagada ON multas(pagada);

-- ============================================
-- VISTAS
-- ============================================

CREATE VIEW v_libros_completo AS
SELECT 
    l.id,
    l.titulo,
    l.isbn,
    l.anio_publicacion,
    e.nombre AS editorial,
    g.nombre AS genero,
    l.stock_total,
    l.stock_disponible,
    STRING_AGG(a.nombre || ' ' || a.apellido, ', ') AS autores
FROM libros l
LEFT JOIN editoriales e ON l.editorial_id = e.id
LEFT JOIN generos g ON l.genero_id = g.id
LEFT JOIN libro_autor la ON l.id = la.libro_id
LEFT JOIN autores a ON la.autor_id = a.id
GROUP BY l.id, l.titulo, l.isbn, l.anio_publicacion, e.nombre, g.nombre, 
         l.stock_total, l.stock_disponible;

CREATE VIEW v_prestamos_activos AS
SELECT 
    p.id,
    s.nombre || ' ' || s.apellido AS socio,
    l.titulo AS libro,
    p.fecha_prestamo,
    p.fecha_devolucion_esperada,
    CURRENT_DATE - p.fecha_devolucion_esperada AS dias_retraso
FROM prestamos p
JOIN socios s ON p.socio_id = s.id
JOIN libros l ON p.libro_id = l.id
WHERE p.estado IN ('prestado', 'vencido');

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función: actualizar stock al prestar
CREATE OR REPLACE FUNCTION actualizar_stock_prestamo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE libros 
        SET stock_disponible = stock_disponible - 1
        WHERE id = NEW.libro_id;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' AND NEW.estado = 'devuelto' AND OLD.estado != 'devuelto' THEN
        UPDATE libros 
        SET stock_disponible = stock_disponible + 1
        WHERE id = NEW.libro_id;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_prestamo_stock
AFTER INSERT OR UPDATE ON prestamos
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock_prestamo();

-- Función: calcular multa por retraso
CREATE OR REPLACE FUNCTION calcular_multa(p_prestamo_id INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    dias_retraso INTEGER;
    monto DECIMAL(10,2);
BEGIN
    SELECT GREATEST(0, COALESCE(fecha_devolucion_real, CURRENT_DATE) - fecha_devolucion_esperada)
    INTO dias_retraso
    FROM prestamos
    WHERE id = p_prestamo_id;
    
    monto := dias_retraso * 0.50;  -- 0.50€ por día de retraso
    
    IF monto > 0 THEN
        INSERT INTO multas (prestamo_id, monto)
        VALUES (p_prestamo_id, monto)
        ON CONFLICT (prestamo_id) DO UPDATE SET monto = EXCLUDED.monto;
    END IF;
    
    RETURN monto;
END;
$$ LANGUAGE plpgsql;