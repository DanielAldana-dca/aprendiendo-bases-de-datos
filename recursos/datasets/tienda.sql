-- ============================================
-- Dataset: Tienda
-- Compatible con SQLite, PostgreSQL y MySQL
-- ============================================

DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    ciudad VARCHAR(50),
    edad INTEGER,
    fecha_registro DATE
);

CREATE TABLE productos (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    stock INTEGER
);

CREATE TABLE pedidos (
    id INTEGER PRIMARY KEY,
    cliente_id INTEGER,
    producto_id INTEGER,
    cantidad INTEGER,
    fecha DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- ============ CLIENTES ============
INSERT INTO clientes VALUES
(1, 'Ana García',     'ana@mail.com',    'Madrid',    28, '2023-01-15'),
(2, 'Luis Pérez',     'luis@mail.com',   'Barcelona', 34, '2023-02-20'),
(3, 'Marta López',    'marta@mail.com',  'Madrid',    25, '2023-03-05'),
(4, 'Carlos Ruiz',    'carlos@mail.com', 'Valencia',  41, '2023-03-22'),
(5, 'Elena Sanz',     'elena@mail.com',  'Sevilla',   30, '2023-04-10'),
(6, 'Javier Mora',    'javier@mail.com', 'Madrid',    22, '2023-05-01'),
(7, 'Lucía Torres',   'lucia@mail.com',  'Bilbao',    37, '2023-05-18'),
(8, 'Pedro Vidal',    NULL,              'Barcelona', 29, '2023-06-02'),
(9, 'Sara Núñez',     'sara@mail.com',   'Madrid',    33, '2023-06-25'),
(10,'Diego Romero',   'diego@mail.com',  'Valencia',  26, '2023-07-14');

-- ============ PRODUCTOS ============
INSERT INTO productos VALUES
(1, 'Laptop Pro 15',      'Electrónica', 1200.00, 15),
(2, 'Mouse Inalámbrico',  'Electrónica',   25.50, 100),
(3, 'Teclado Mecánico',   'Electrónica',   89.99, 45),
(4, 'Monitor 27"',        'Electrónica',  320.00, 20),
(5, 'Silla Ergonómica',   'Muebles',      250.00, 10),
(6, 'Escritorio Madera',  'Muebles',      180.00,  8),
(7, 'Lámpara LED',        'Muebles',       45.00, 30),
(8, 'Camiseta Básica',    'Ropa',          15.99, 200),
(9, 'Zapatillas Running', 'Ropa',          75.00, 60),
(10,'Mochila Urban',      'Ropa',          55.00, 40),
(11,'Cafetera Express',   'Hogar',        150.00, 25),
(12,'Set Sartenes',       'Hogar',         80.00, 35);

-- ============ PEDIDOS ============
INSERT INTO pedidos VALUES
(1,  1, 1,  1, '2024-01-10'),
(2,  1, 2,  2, '2024-01-10'),
(3,  2, 3,  1, '2024-01-15'),
(4,  3, 5,  1, '2024-01-20'),
(5,  3, 2,  1, '2024-01-20'),
(6,  4, 4,  2, '2024-02-01'),
(7,  5, 8,  3, '2024-02-05'),
(8,  6, 9,  1, '2024-02-10'),
(9,  7, 11, 1, '2024-02-15'),
(10, 8, 12, 2, '2024-02-20'),
(11, 9, 1,  1, '2024-03-01'),
(12, 9, 7,  2, '2024-03-01'),
(13,10, 3,  1, '2024-03-05'),
(14, 2, 10, 1, '2024-03-10'),
(15, 4, 6,  1, '2024-03-15');