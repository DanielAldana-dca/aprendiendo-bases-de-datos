-- ============================================
-- Datos de prueba: Sistema de Biblioteca
-- ============================================

-- ============ EDITORIALES ============
INSERT INTO editoriales (nombre, pais, fundacion) VALUES
('Penguin Random House', 'EE.UU.', 2013),
('Planeta', 'España', 1949),
('Anagrama', 'España', 1969),
('Alfaguara', 'España', 1964),
('Salamandra', 'España', 1989),
('O''Reilly Media', 'EE.UU.', 1978);

-- ============ GÉNEROS ============
INSERT INTO generos (nombre, descripcion) VALUES
('Novela', 'Narrativa larga de ficción'),
('Ciencia Ficción', 'Ficción especulativa científica'),
('Fantasía', 'Mundos imaginarios y magia'),
('Terror', 'Búsqueda de emociones fuertes'),
('Ensayo', 'Reflexión y análisis'),
('Técnico', 'Libros de programación y tecnología'),
('Historia', 'Relatos históricos'),
('Poesía', 'Obra poética');

-- ============ AUTORES ============
INSERT INTO autores (nombre, apellido, nacionalidad, fecha_nacimiento) VALUES
('Gabriel', 'García Márquez', 'Colombiana', '1927-03-06'),
('Jorge Luis', 'Borges', 'Argentina', '1899-08-24'),
('Isaac', 'Asimov', 'Rusa/EE.UU.', '1920-01-02'),
('J.R.R.', 'Tolkien', 'Británica', '1892-01-03'),
('George', 'Orwell', 'Británica', '1903-06-25'),
('Stephen', 'King', 'EE.UU.', '1947-09-21'),
('Yuval Noah', 'Harari', 'Israelí', '1976-02-24'),
('Robert', 'Martin', 'EE.UU.', '1952-12-05'),
('Martin', 'Fowler', 'Británica', '1963-12-18'),
('Isabel', 'Allende', 'Chilena', '1942-08-02');

-- ============ LIBROS ============
INSERT INTO libros (titulo, isbn, anio_publicacion, editorial_id, genero_id, num_paginas, stock_total, stock_disponible) VALUES
('Cien años de soledad', '978-0307474728', 1967, 1, 1, 471, 3, 3),
('El amor en los tiempos del cólera', '978-0307389732', 1985, 1, 1, 368, 2, 2),
('Ficciones', '978-0802130303', 1944, 3, 1, 224, 2, 2),
('El Aleph', '978-0142437889', 1949, 3, 1, 224, 1, 1),
('Fundación', '978-0553293357', 1951, 1, 2, 296, 4, 4),
('Yo, Robot', '978-0553294385', 1950, 1, 2, 224, 3, 3),
('El Señor de los Anillos', '978-0618640157', 1954, 5, 3, 1216, 2, 2),
('El Hobbit', '978-0547928227', 1937, 5, 3, 310, 3, 3),
('1984', '978-0451524935', 1949, 2, 2, 328, 5, 5),
('Rebelión en la granja', '978-0452284241', 1945, 2, 1, 144, 3, 3),
('It', '978-1501142970', 1986, 4, 4, 1184, 2, 2),
('El resplandor', '978-0307743657', 1977, 4, 4, 688, 2, 2),
('Sapiens', '978-0062316097', 2011, 1, 7, 464, 4, 4),
('Homo Deus', '978-0062464316', 2015, 1, 7, 464, 3, 3),
('Clean Code', '978-0132350884', 2008, 6, 6, 464, 5, 5),
('The Pragmatic Programmer', '978-0135957059', 1999, 6, 6, 352, 3, 3),
('Refactoring', '978-0134757599', 1999, 6, 6, 448, 2, 2),
('La casa de los espíritus', '978-1501119170', 1982, 1, 1, 496, 2, 2),
('Patrones de diseño', '978-0201633610', 1994, 6, 6, 416, 2, 2),
('Los detectives salvajes', '978-8433968548', 1998, 3, 1, 624, 1, 1);

-- ============ LIBRO_AUTOR ============
INSERT INTO libro_autor (libro_id, autor_id) VALUES
(1, 1),   -- Cien años - García Márquez
(2, 1),   -- Amor - García Márquez
(3, 2),   -- Ficciones - Borges
(4, 2),   -- El Aleph - Borges
(5, 3),   -- Fundación - Asimov
(6, 3),   -- Yo Robot - Asimov
(7, 4),   -- Señor Anillos - Tolkien
(8, 4),   -- Hobbit - Tolkien
(9, 5),   -- 1984 - Orwell
(10, 5),  -- Rebelión - Orwell
(11, 6),  -- It - King
(12, 6),  -- Resplandor - King
(13, 7),  -- Sapiens - Harari
(14, 7),  -- Homo Deus - Harari
(15, 8),  -- Clean Code - Martin
(16, 8),  -- Pragmatic - Martin (con Hunt, pero simplificamos)
(17, 9),  -- Refactoring - Fowler
(18, 10), -- Casa espíritus - Allende
(19, 8),  -- Patrones - Martin (GoF, simplificamos)
(20, 2);  -- Detectives salvajes - Bolaño (simplificamos con Borges)

-- ============ SOCIOS ============
INSERT INTO socios (nombre, apellido, email, telefono, fecha_alta, estado) VALUES
('Ana', 'García', 'ana@mail.com', '600111111', '2023-01-15', 'activo'),
('Luis', 'Pérez', 'luis@mail.com', '600222222', '2023-02-20', 'activo'),
('Marta', 'López', 'marta@mail.com', '600333333', '2023-03-05', 'activo'),
('Carlos', 'Ruiz', 'carlos@mail.com', '600444444', '2023-03-22', 'activo'),
('Elena', 'Sanz', 'elena@mail.com', '600555555', '2023-04-10', 'activo'),
('Javier', 'Mora', 'javier@mail.com', '600666666', '2023-05-01', 'suspendido'),
('Lucía', 'Torres', 'lucia@mail.com', '600777777', '2023-05-18', 'activo'),
('Pedro', 'Vidal', 'pedro@mail.com', '600888888', '2023-06-02', 'activo'),
('Sara', 'Núñez', 'sara@mail.com', '600999999', '2023-06-25', 'activo'),
('Diego', 'Romero', 'diego@mail.com', '600101010', '2023-07-14', 'baja'),
('Laura', 'Gil', 'laura@mail.com', '600111213', '2023-08-01', 'activo'),
('Raúl', 'Vega', 'raul@mail.com', '600141516', '2023-09-10', 'activo'),
('Nuria', 'Pinto', 'nuria@mail.com', '600171819', '2023-10-05', 'activo'),
('Tomás', 'Blanco', 'tomas@mail.com', '600202122', '2023-11-12', 'activo'),
('Irene', 'Castro', 'irene@mail.com', '600232425', '2024-01-08', 'activo');

-- ============ PRÉSTAMOS ============
INSERT INTO prestamos (socio_id, libro_id, fecha_prestamo, fecha_devolucion_esperada, fecha_devolucion_real, estado) VALUES
(1, 1, '2024-01-10', '2024-01-24', '2024-01-22', 'devuelto'),
(1, 5, '2024-02-01', '2024-02-15', '2024-02-14', 'devuelto'),
(2, 9, '2024-01-15', '2024-01-29', '2024-02-05', 'devuelto'),  -- con retraso
(3, 7, '2024-01-20', '2024-02-03', '2024-02-01', 'devuelto'),
(3, 13, '2024-02-10', '2024-02-24', '2024-02-20', 'devuelto'),
(4, 15, '2024-02-01', '2024-02-15', NULL, 'vencido'),
(5, 3, '2024-02-05', '2024-02-19', '2024-02-18', 'devuelto'),
(7, 11, '2024-02-15', '2024-03-01', '2024-02-28', 'devuelto'),
(8, 2, '2024-02-20', '2024-03-05', '2024-03-10', 'devuelto'),  -- con retraso
(9, 6, '2024-03-01', '2024-03-15', NULL, 'prestado'),
(11, 4, '2024-03-05', '2024-03-19', NULL, 'prestado'),
(12, 8, '2024-03-10', '2024-03-24', NULL, 'prestado'),
(13, 10, '2024-03-12', '2024-03-26', NULL, 'prestado'),
(14, 12, '2024-03-15', '2024-03-29', NULL, 'prestado'),
(1, 17, '2024-03-18', '2024-04-01', NULL, 'prestado'),
(3, 19, '2024-03-20', '2024-04-03', NULL, 'prestado'),
(5, 16, '2024-03-22', '2024-04-05', NULL, 'prestado'),
(2, 18, '2024-03-25', '2024-04-08', NULL, 'prestado'),
(9, 14, '2024-03-28', '2024-04-11', NULL, 'prestado'),
(11, 20, '2024-03-30', '2024-04-13', NULL, 'prestado');

-- ============ MULTAS ============
INSERT INTO multas (prestamo_id, monto, pagada, fecha_generacion) VALUES
(3, 3.50, TRUE, '2024-02-05'),   -- 7 días de retraso
(9, 2.50, FALSE, '2024-03-10');  -- 5 días de retraso