# 🧪 Ejercicios - Normalización

## Nivel 🟢 Fácil

### 1. Detectar violación de 1FN
¿Qué viola 1FN?

| id | nombre | telefono |
|----|--------|----------|
| 1 | Ana | 111, 222 |
| 2 | Luis | 333 |

<details>
<summary>💡 Solución</summary>

La columna `telefono` contiene **múltiples valores** en una celda (111, 222).

**Solución:**

**Personas:**
| id | nombre |
|----|--------|
| 1 | Ana |
| 2 | Luis |

**Telefonos:**
| persona_id | telefono |
|------------|----------|
| 1 | 111 |
| 1 | 222 |
| 2 | 333 |

</details>

### 2. Detectar violación de 2FN
PK compuesta `(pedido_id, producto_id)`:

| pedido_id | producto_id | cantidad | producto_nombre | precio |
|-----------|-------------|----------|-----------------|--------|
| 1 | 1 | 2 | Laptop | 1200 |
| 1 | 2 | 1 | Mouse | 25.50 |

¿Qué viola 2FN?

<details>
<summary>💡 Solución</summary>

`producto_nombre` y `precio` dependen solo de `producto_id`, no de toda la PK.

**Solución:**

**Pedido_detalle:**
| pedido_id | producto_id | cantidad |
|-----------|-------------|----------|
| 1 | 1 | 2 |
| 1 | 2 | 1 |

**Productos:**
| id | nombre | precio |
|----|--------|--------|
| 1 | Laptop | 1200 |
| 2 | Mouse | 25.50 |

</details>

---

## Nivel 🟡 Intermedio

### 3. Normalizar hasta 3FN
Normaliza:

| empleado_id | empleado | dept_id | dept_nombre | jefe |
|-------------|----------|---------|-------------|------|
| 1 | Ana | 10 | Ventas | Luis |
| 2 | Marta | 10 | Ventas | Luis |
| 3 | Pedro | 20 | IT | Sara |

<details>
<summary>💡 Solución</summary>

**Empleados:**
| id | nombre | dept_id |
|----|--------|---------|
| 1 | Ana | 10 |
| 2 | Marta | 10 |
| 3 | Pedro | 20 |

**Departamentos:**
| id | nombre | jefe |
|----|--------|------|
| 10 | Ventas | Luis |
| 20 | IT | Sara |

`dept_nombre` y `jefe` dependían de `dept_id`, no de `empleado_id` (viola 3FN).

</details>

### 4. Normalizar factura

| factura | fecha | cliente | email | ciudad | productos | precios |
|---------|-------|---------|-------|--------|-----------|---------|
| F1 | 2024-01-01 | Ana | ana@x.com | Madrid | Laptop, Mouse | 1200, 25.50 |
| F2 | 2024-01-02 | Luis | luis@x.com | Barcelona | Silla | 250 |

<details>
<summary>💡 Solución</summary>

**Clientes:**
| id | nombre | email | ciudad |
|----|--------|-------|--------|
| 1 | Ana | ana@x.com | Madrid |
| 2 | Luis | luis@x.com | Barcelona |

**Facturas:**
| id | fecha | cliente_id |
|----|-------|------------|
| F1 | 2024-01-01 | 1 |
| F2 | 2024-01-02 | 2 |

**Productos:**
| id | nombre | precio |
|----|--------|--------|
| 1 | Laptop | 1200 |
| 2 | Mouse | 25.50 |
| 3 | Silla | 250 |

**Factura_detalle:**
| factura_id | producto_id | cantidad | precio_unitario |
|------------|-------------|----------|-----------------|
| F1 | 1 | 1 | 1200 |
| F1 | 2 | 1 | 25.50 |
| F2 | 3 | 1 | 250 |

> Nota: `precio_unitario` se guarda para preservar el precio histórico.

</details>

---

## Nivel 🔴 Difícil

### 5. Normalizar a BCNF

| curso | profesor | aula | horario | alumno |
|-------|----------|------|---------|--------|
| SQL | Ana | A1 | Lunes 10h | Luis |
| SQL | Ana | A1 | Lunes 10h | Marta |
| Python | Pedro | B2 | Martes 15h | Luis |

<details>
<summary>💡 Solución</summary>

**Profesores:**
| id | nombre |
|----|--------|
| 1 | Ana |
| 2 | Pedro |

**Cursos:**
| id | nombre | profesor_id | aula | horario |
|----|--------|-------------|------|---------|
| 1 | SQL | 1 | A1 | Lunes 10h |
| 2 | Python | 2 | B2 | Martes 15h |

**Alumnos:**
| id | nombre |
|----|--------|
| 1 | Luis |
| 2 | Marta |

**Inscripciones:**
| curso_id | alumno_id |
|----------|-----------|
| 1 | 1 |
| 1 | 2 |
| 2 | 1 |

</details>

### 6. Detectar todas las violaciones
Analiza y normaliza:

| venta_id | fecha | vendedor | email_vendedor | producto | categoria | cantidad | precio |
|----------|-------|----------|----------------|----------|-----------|----------|--------|
| 1 | 2024-01-01 | Ana | ana@x.com | Laptop | Electrónica | 1 | 1200 |
| 1 | 2024-01-01 | Ana | ana@x.com | Mouse | Electrónica | 2 | 25.50 |

<details>
<summary>💡 Solución</summary>

**Vendedores:**
| id | nombre | email |
|----|--------|-------|
| 1 | Ana | ana@x.com |

**Categorias:**
| id | nombre |
|----|--------|
| 1 | Electrónica |

**Productos:**
| id | nombre | categoria_id | precio |
|----|--------|--------------|--------|
| 1 | Laptop | 1 | 1200 |
| 2 | Mouse | 1 | 25.50 |

**Ventas:**
| id | fecha | vendedor_id |
|----|-------|-------------|
| 1 | 2024-01-01 | 1 |

**Venta_detalle:**
| venta_id | producto_id | cantidad | precio_unitario |
|----------|-------------|----------|-----------------|
| 1 | 1 | 1 | 1200 |
| 1 | 2 | 2 | 25.50 |

</details>