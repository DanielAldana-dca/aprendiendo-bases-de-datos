-- ============================================
-- E-commerce - Datos de prueba
-- Ejecutar DESPUÉS de 02-schema.sql
-- ============================================

-- ============ USUARIOS ============
INSERT INTO usuarios (email, password_hash, nombre, apellido, telefono) VALUES
('ana@mail.com',    '$2b$10$abc123', 'Ana',    'García',  '600111111'),
('luis@mail.com',   '$2b$10$abc123', 'Luis',   'Pérez',   '600222222'),
('marta@mail.com',  '$2b$10$abc123', 'Marta',  'López',   '600333333'),
('carlos@mail.com', '$2b$10$abc123', 'Carlos', 'Ruiz',    '600444444'),
('elena@mail.com',  '$2b$10$abc123', 'Elena',  'Sanz',    '600555555'),
('javier@mail.com', '$2b$10$abc123', 'Javier', 'Mora',    '600666666'),
('lucia@mail.com',  '$2b$10$abc123', 'Lucía',  'Torres',  '600777777'),
('pedro@mail.com',  '$2b$10$abc123', 'Pedro',  'Vidal',   '600888888');

-- ============ DIRECCIONES ============
INSERT INTO direcciones (usuario_id, nombre_completo, calle, ciudad, provincia, cp, telefono, principal) VALUES
(1, 'Ana García',    'Gran Vía 10',    'Madrid',    'Madrid',    '28001', '600111111', TRUE),
(1, 'Ana García',    'Mayor 5',        'Madrid',    'Madrid',    '28002', '600111111', FALSE),
(2, 'Luis Pérez',    'Rambla 20',      'Barcelona', 'Barcelona', '08001', '600222222', TRUE),
(3, 'Marta López',   'Alcalá 45',      'Madrid',    'Madrid',    '28003', '600333333', TRUE),
(4, 'Carlos Ruiz',   'Colón 12',       'Valencia',  'Valencia',  '46001', '600444444', TRUE),
(5, 'Elena Sanz',    'Triana 8',       'Sevilla',   'Sevilla',   '41001', '600555555', TRUE),
(6, 'Javier Mora',   'Serrano 100',    'Madrid',    'Madrid',    '28006', '600666666', TRUE),
(7, 'Lucía Torres',  'Gran Vía 30',    'Bilbao',    'Vizcaya',   '48001', '600777777', TRUE),
(8, 'Pedro Vidal',   'Diagonal 200',   'Barcelona', 'Barcelona', '08013', '600888888', TRUE);

-- ============ CATEGORÍAS (con jerarquía) ============
INSERT INTO categorias (nombre, padre_id, descripcion) VALUES
('Electrónica',    NULL, 'Dispositivos electrónicos'),
('Informática',    1,    'Ordenadores y accesorios'),
('Audio',          1,    'Auriculares y altavoces'),
('Muebles',        NULL, 'Mobiliario'),
('Oficina',        4,    'Muebles de oficina'),
('Hogar',          4,    'Muebles de hogar'),
('Ropa',           NULL, 'Prendas de vestir'),
('Hombre',         7,    'Ropa de hombre'),
('Mujer',          7,    'Ropa de mujer');

-- ============ PRODUCTOS ============
INSERT INTO productos (nombre, descripcion, categoria_id, precio_base, activo) VALUES
('Laptop Pro 15',        'Portátil profesional 15"',   2,  1200.00, TRUE),
('Mouse Inalámbrico',    'Mouse ergonómico',            2,    25.50, TRUE),
('Teclado Mecánico',     'Teclado gaming RGB',          2,    89.99, TRUE),
('Monitor 27"',          'Monitor 4K 27 pulgadas',      2,   320.00, TRUE),
('Auriculares BT',       'Auriculares bluetooth',       3,    79.99, TRUE),
('Silla Ergonómica',     'Silla de oficina premium',    5,   250.00, TRUE),
('Escritorio Madera',    'Escritorio 1.5m nogal',       5,   180.00, TRUE),
('Lámpara LED',          'Lámpara de escritorio',       5,    45.00, TRUE),
('Camiseta Básica',      'Camiseta algodón',            8,    15.99, TRUE),
('Zapatillas Running',   'Zapatillas deportivas',       8,    75.00, TRUE),
('Mochila Urban',        'Mochila antirrobo',           8,    55.00, TRUE),
('Blusa Elegante',       'Blusa de seda',               9,    45.00, TRUE),
('Vestido Verano',       'Vestido ligero',              9,    60.00, TRUE),
('Cafetera Express',     'Cafetera italiana',           6,   150.00, TRUE),
('Set Sartenes',         'Set 5 sartenes antiadherentes', 6,  80.00, TRUE);

-- ============ ATRIBUTOS ============
INSERT INTO atributos (nombre, valor) VALUES
('talla', 'S'), ('talla', 'M'), ('talla', 'L'), ('talla', 'XL'),
('color', 'Negro'), ('color', 'Blanco'), ('color', 'Rojo'), ('color', 'Azul'),
('almacenamiento', '256GB'), ('almacenamiento', '512GB'), ('almacenamiento', '1TB');

-- ============ VARIANTES ============
INSERT INTO variantes (producto_id, sku, precio, stock, activa) VALUES
-- Laptop (2 variantes)
(1, 'LAP-PRO-256', 1200.00, 10, TRUE),
(1, 'LAP-PRO-512', 1400.00,  5, TRUE),
-- Mouse (1 variante)
(2, 'MOU-WIR-NEG',   25.50, 100, TRUE),
-- Teclado (1 variante)
(3, 'TEC-MEC-RGB',   89.99,  45, TRUE),
-- Monitor (1 variante)
(4, 'MON-27-4K',    320.00,  20, TRUE),
-- Auriculares (2 variantes)
(5, 'AUR-BT-NEG',    79.99,  30, TRUE),
(5, 'AUR-BT-BLA',    79.99,  25, TRUE),
-- Silla (1 variante)
(6, 'SIL-ERG-NEG',  250.00,  10, TRUE),
-- Escritorio (1 variante)
(7, 'ESC-MAD-15',   180.00,   8, TRUE),
-- Lámpara (1 variante)
(8, 'LAM-LED-BLA',   45.00,  30, TRUE),
-- Camiseta (4 variantes)
(9,  'CAM-S-NEG',    15.99,  50, TRUE),
(9,  'CAM-M-NEG',    15.99,  60, TRUE),
(9,  'CAM-L-NEG',    15.99,  40, TRUE),
(9,  'CAM-M-BLA',    15.99,  50, TRUE),
-- Zapatillas (2 variantes)
(10, 'ZAP-RUN-40',   75.00,  30, TRUE),
(10, 'ZAP-RUN-42',   75.00,  30, TRUE),
-- Mochila (1 variante)
(11, 'MOC-URB-NEG',  55.00,  40, TRUE),
-- Blusa (2 variantes)
(12, 'BLU-S-ROJ',    45.00,  20, TRUE),
(12, 'BLU-M-ROJ',    45.00,  25, TRUE),
-- Vestido (1 variante)
(13, 'VES-VER-M',    60.00,  15, TRUE),
-- Cafetera (1 variante)
(14, 'CAF-EXP-NEG', 150.00,  25, TRUE),
-- Set sartenes (1 variante)
(15, 'SET-SAR-5P',   80.00,  35, TRUE);

-- ============ VARIANTE_ATRIBUTO ============
INSERT INTO variante_atributo (variante_id, atributo_id) VALUES
(1, 9),   -- Laptop 256GB
(2, 10),  -- Laptop 512GB
(3, 5),   -- Mouse negro
(4, 5),   -- Teclado negro
(6, 5),   -- Auriculares negros
(7, 6),   -- Auriculares blancos
(11, 1), (11, 5),  -- Camiseta S negra
(12, 2), (12, 5),  -- Camiseta M negra
(13, 3), (13, 5),  -- Camiseta L negra
(14, 2), (14, 6),  -- Camiseta M blanca
(17, 7),  -- Blusa roja
(18, 7);  -- Blusa roja

-- ============ CUPONES ============
INSERT INTO cupones (codigo, descripcion, tipo, valor, valido_desde, valido_hasta, usos_max, activo) VALUES
('BIENVENIDA10', '10% en primera compra',   'porcentaje', 10.00, '2024-01-01', '2024-12-31', 1000, TRUE),
('VERANO24',     '15€ de descuento',        'fijo',       15.00, '2024-06-01', '2024-09-30',  500, TRUE),
('BLACKFRIDAY',  '25% de descuento',        'porcentaje', 25.00, '2024-11-25', '2024-11-30',  200, TRUE),
('NAVIDAD',      '20€ de descuento',        'fijo',       20.00, '2024-12-15', '2024-12-31',  300, TRUE);

-- ============ PEDIDOS ============
-- Los subtotales se calculan después con UPDATE para evitar errores manuales

INSERT INTO pedidos (usuario_id, direccion_id, cupon_id, fecha, subtotal, descuento, total, estado) VALUES
(1, 1, 1,    '2024-01-10 10:30:00', 1225.50, 122.55, 1102.95, 'entregado'),
(2, 3, NULL, '2024-01-15 14:20:00',   89.99,   0.00,   89.99, 'entregado'),
(3, 4, NULL, '2024-01-20 09:15:00',  275.50,   0.00,  275.50, 'entregado'),
(4, 5, NULL, '2024-02-01 16:45:00',  640.00,   0.00,  640.00, 'entregado'),
(5, 6, NULL, '2024-02-05 11:00:00',   47.97,   0.00,   47.97, 'entregado'),
(6, 7, NULL, '2024-02-10 20:30:00',   75.00,   0.00,   75.00, 'entregado'),
(7, 8, NULL, '2024-02-15 13:00:00',  150.00,   0.00,  150.00, 'entregado'),
(8, 9, NULL, '2024-02-20 18:20:00',  160.00,   0.00,  160.00, 'enviado'),
(1, 1, NULL, '2024-03-01 12:00:00', 1200.00,   0.00, 1200.00, 'enviado'),
(2, 3, 2,    '2024-03-10 15:30:00',   55.00,  15.00,   40.00, 'pendiente'),
(3, 4, NULL, '2024-03-15 10:00:00',   80.00,   0.00,   80.00, 'pendiente');

-- ============ LÍNEAS DE PEDIDO ============
INSERT INTO lineas_pedido (pedido_id, variante_id, producto_nombre, variante_desc, cantidad, precio_unitario, subtotal) VALUES
-- Pedido 1
(1, 1,  'Laptop Pro 15',     'almacenamiento: 256GB', 1, 1200.00, 1200.00),
(1, 3,  'Mouse Inalámbrico', 'color: Negro',          1,   25.50,   25.50),
-- Pedido 2
(2, 4,  'Teclado Mecánico',  'color: Negro',          1,   89.99,   89.99),
-- Pedido 3
(3, 6,  'Silla Ergonómica',  NULL,                    1,  250.00,  250.00),
(3, 3,  'Mouse Inalámbrico', 'color: Negro',          1,   25.50,   25.50),
-- Pedido 4
(4, 5,  'Monitor 27"',       NULL,                    2,  320.00,  640.00),
-- Pedido 5
(5, 11, 'Camiseta Básica',   'talla: S, color: Negro', 3,  15.99,   47.97),
-- Pedido 6
(6, 15, 'Zapatillas Running','talla: 40',             1,   75.00,   75.00),
-- Pedido 7
(7, 22, 'Cafetera Express',  NULL,                    1,  150.00,  150.00),
-- Pedido 8
(8, 23, 'Set Sartenes',      NULL,                    2,   80.00,  160.00),
-- Pedido 9
(9, 2,  'Laptop Pro 15',     'almacenamiento: 512GB', 1, 1400.00, 1400.00),
-- Pedido 10
(10, 19, 'Mochila Urban',    NULL,                    1,   55.00,   55.00),
-- Pedido 11
(11, 23, 'Set Sartenes',     NULL,                    1,   80.00,   80.00);

-- ============ PAGOS ============
INSERT INTO pagos (pedido_id, metodo, monto, estado, referencia, fecha) VALUES
(1,  'tarjeta',        1102.95, 'completado', 'TXN-001', '2024-01-10 10:35:00'),
(2,  'paypal',           89.99, 'completado', 'PP-002',  '2024-01-15 14:25:00'),
(3,  'tarjeta',         275.50, 'completado', 'TXN-003', '2024-01-20 09:20:00'),
(4,  'tarjeta',         640.00, 'completado', 'TXN-004', '2024-02-01 16:50:00'),
(5,  'tarjeta',          47.97, 'completado', 'TXN-005', '2024-02-05 11:05:00'),
(6,  'paypal',           75.00, 'completado', 'PP-006',  '2024-02-10 20:35:00'),
(7,  'tarjeta',         150.00, 'completado', 'TXN-007', '2024-02-15 13:05:00'),
(8,  'tarjeta',         160.00, 'completado', 'TXN-008', '2024-02-20 18:25:00'),
(9,  'tarjeta',        1200.00, 'completado', 'TXN-009', '2024-03-01 12:05:00'),
(10, 'transferencia',    40.00, 'pendiente',  NULL,       '2024-03-10 15:35:00');

-- ============ ENVÍOS ============
INSERT INTO envios (pedido_id, direccion_completa, transportista, tracking, estado, fecha_estimada, fecha_entrega) VALUES
(1,  'Gran Vía 10, 28001 Madrid',        'SEUR',     'SEUR-001', 'entregado',   '2024-01-12', '2024-01-12'),
(2,  'Rambla 20, 08001 Barcelona',       'MRW',      'MRW-002',  'entregado',   '2024-01-17', '2024-01-17'),
(3,  'Alcalá 45, 28003 Madrid',          'Correos',  'COR-003',  'entregado',   '2024-01-22', '2024-01-23'),
(4,  'Colón 12, 46001 Valencia',         'SEUR',     'SEUR-004', 'entregado',   '2024-02-03', '2024-02-03'),
(5,  'Triana 8, 41001 Sevilla',          'MRW',      'MRW-005',  'entregado',   '2024-02-07', '2024-02-07'),
(6,  'Serrano 100, 28006 Madrid',        'Correos',  'COR-006',  'entregado',   '2024-02-12', '2024-02-12'),
(7,  'Gran Vía 30, 48001 Bilbao',        'SEUR',     'SEUR-007', 'entregado',   '2024-02-17', '2024-02-17'),
(8,  'Diagonal 200, 08013 Barcelona',    'MRW',      'MRW-008',  'en_transito', '2024-02-22', NULL),
(9,  'Gran Vía 10, 28001 Madrid',        'SEUR',     'SEUR-009', 'en_transito', '2024-03-03', NULL);

-- ============ VERIFICACIÓN ============
SELECT 'usuarios' AS tabla, COUNT(*) FROM usuarios
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'variantes', COUNT(*) FROM variantes
UNION ALL SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL SELECT 'lineas_pedido', COUNT(*) FROM lineas_pedido;