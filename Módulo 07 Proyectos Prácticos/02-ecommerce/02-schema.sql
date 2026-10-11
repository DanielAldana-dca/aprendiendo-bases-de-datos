-- ============================================
-- E-commerce - Schema SQL
-- Motor: PostgreSQL
-- ============================================

DROP TABLE IF EXISTS envios CASCADE;
DROP TABLE IF EXISTS pagos CASCADE;
DROP TABLE IF EXISTS lineas_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS cupones CASCADE;
DROP TABLE IF EXISTS variante_atributo CASCADE;
DROP TABLE IF EXISTS atributos CASCADE;
DROP TABLE IF EXISTS variantes CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS direcciones CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- ============================================
-- USUARIOS Y DIRECCIONES
-- ============================================

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE direcciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre_completo VARCHAR(200) NOT NULL,
    calle VARCHAR(200) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    provincia VARCHAR(100),
    cp VARCHAR(10) NOT NULL,
    pais VARCHAR(50) NOT NULL DEFAULT 'España',
    telefono VARCHAR(20),
    principal BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_direcciones_usuario ON direcciones(usuario_id);

-- ============================================
-- CATÁLOGO
-- ============================================

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    padre_id INTEGER REFERENCES categorias(id) ON DELETE CASCADE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE,
    UNIQUE(nombre, padre_id)
);

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INTEGER REFERENCES categorias(id) ON DELETE SET NULL,
    precio_base DECIMAL(10,2) NOT NULL CHECK (precio_base >= 0),
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);

CREATE TABLE variantes (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    sku VARCHAR(50) NOT NULL UNIQUE,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    activa BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_variantes_producto ON variantes(producto_id);
CREATE INDEX idx_variantes_stock ON variantes(stock);

CREATE TABLE atributos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,       -- "talla", "color"
    valor VARCHAR(50) NOT NULL,        -- "M", "Rojo"
    UNIQUE(nombre, valor)
);

CREATE TABLE variante_atributo (
    variante_id INTEGER REFERENCES variantes(id) ON DELETE CASCADE,
    atributo_id INTEGER REFERENCES atributos(id) ON DELETE CASCADE,
    PRIMARY KEY (variante_id, atributo_id)
);

-- ============================================
-- CUPONES
-- ============================================

CREATE TABLE cupones (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('porcentaje', 'fijo')),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    valido_desde DATE NOT NULL,
    valido_hasta DATE NOT NULL,
    usos_max INTEGER,
    usos_actuales INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    CHECK (valido_hasta > valido_desde),
    CHECK (usos_max IS NULL OR usos_actuales <= usos_max)
);

-- ============================================
-- PEDIDOS
-- ============================================

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    direccion_id INTEGER NOT NULL REFERENCES direcciones(id) ON DELETE RESTRICT,
    cupon_id INTEGER REFERENCES cupones(id) ON DELETE SET NULL,
    fecha TIMESTAMP NOT NULL DEFAULT NOW(),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    descuento DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','pagado','preparando','enviado','entregado','cancelado')),
    CHECK (total = subtotal - descuento)
);

CREATE INDEX idx_pedidos_usuario ON pedidos(usuario_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);

CREATE TABLE lineas_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    variante_id INTEGER REFERENCES variantes(id) ON DELETE SET NULL,
    producto_nombre VARCHAR(200) NOT NULL,
    variante_desc VARCHAR(200),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    CHECK (subtotal = cantidad * precio_unitario)
);

CREATE INDEX idx_lineas_pedido ON lineas_pedido(pedido_id);

CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL UNIQUE REFERENCES pedidos(id) ON DELETE CASCADE,
    metodo VARCHAR(30) NOT NULL CHECK (metodo IN ('tarjeta','paypal','transferencia','contra_reembolso')),
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','completado','fallido','reembolsado')),
    referencia VARCHAR(100),
    fecha TIMESTAMP DEFAULT NOW()
);

CREATE TABLE envios (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL UNIQUE REFERENCES pedidos(id) ON DELETE CASCADE,
    direccion_completa TEXT NOT NULL,
    transportista VARCHAR(50),
    tracking VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'preparando'
        CHECK (estado IN ('preparando','en_transito','entregado','devuelto')),
    fecha_estimada DATE,
    fecha_entrega DATE
);

-- ============================================
-- TRIGGERS
-- ============================================

-- Actualizar stock al crear línea de pedido
CREATE OR REPLACE FUNCTION reducir_stock_pedido()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.variante_id IS NOT NULL THEN
        UPDATE variantes
        SET stock = stock - NEW.cantidad
        WHERE id = NEW.variante_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_linea_pedido_stock
AFTER INSERT ON lineas_pedido
FOR EACH ROW
EXECUTE FUNCTION reducir_stock_pedido();

-- Incrementar uso de cupón
CREATE OR REPLACE FUNCTION incrementar_uso_cupon()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cupon_id IS NOT NULL THEN
        UPDATE cupones
        SET usos_actuales = usos_actuales + 1
        WHERE id = NEW.cupon_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_pedido_cupon
AFTER INSERT ON pedidos
FOR EACH ROW
EXECUTE FUNCTION incrementar_uso_cupon();

-- ============================================
-- VISTAS
-- ============================================

CREATE VIEW v_pedidos_resumen AS
SELECT 
    p.id,
    p.fecha,
    u.email AS usuario,
    u.nombre || ' ' || u.apellido AS cliente,
    p.total,
    p.estado,
    COUNT(lp.id) AS num_lineas,
    SUM(lp.cantidad) AS total_items
FROM pedidos p
JOIN usuarios u ON p.usuario_id = u.id
LEFT JOIN lineas_pedido lp ON p.id = lp.pedido_id
GROUP BY p.id, p.fecha, u.email, u.nombre, u.apellido, p.total, p.estado;