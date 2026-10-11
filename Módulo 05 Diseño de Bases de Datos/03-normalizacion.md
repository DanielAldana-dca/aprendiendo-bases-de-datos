# 03 - Normalización

## 🎯 Objetivos

- Entender por qué normalizar
- Aplicar 1FN, 2FN, 3FN
- Detectar dependencias funcionales
- Conocer BCNF (mención)

## 📚 ¿Qué es la normalización?

Proceso de organizar los datos para **eliminar redundancia** y **evitar anomalías**.

**Objetivo:** cada dato en un solo lugar.

## 🔥 Problemas sin normalizar

### Anomalías de inserción
No puedes insertar un dato sin insertar otro que no corresponde.

### Anomalías de actualización
Cambiar un dato requiere actualizarlo en muchos lugares (y puede que se te olvide alguno).

### Anomalías de borrado
Borrar una fila elimina información que querías conservar.

### Ejemplo clásico

Tabla `pedidos` sin normalizar:

| pedido_id | cliente | cliente_email | productos | precios |
|-----------|---------|---------------|-----------|---------|
| 1 | Ana | ana@mail.com | Laptop, Mouse | 1200, 25.50 |
| 2 | Ana | ana@mail.com | Monitor | 320 |
| 3 | Luis | luis@mail.com | Teclado | 89.99 |

**Problemas:**
- `ana@mail.com` repetido
- `productos` con múltiples valores (viola 1FN)
- `precios` con múltiples valores
- Si Ana cambia de email → hay que actualizar 2 filas

## 📚 Primera Forma Normal (1FN)

**Regla:** cada celda contiene **un solo valor atómico**. No hay listas ni grupos repetidos.

### Antes (viola 1FN)

| id | cliente | productos |
|----|---------|-----------|
| 1 | Ana | Laptop, Mouse |

### Después (1FN)

**Pedidos:**
| id | cliente |
|----|---------|
| 1 | Ana |

**Pedido_productos:**
| pedido_id | producto |
|-----------|----------|
| 1 | Laptop |
| 1 | Mouse |

### Cómo detectar violaciones
- Celdas con comas, `;`, `|` separando valores
- Columnas como `telefono1`, `telefono2`, `telefono3`
- Arrays o JSON (a veces válido en NoSQL, no en relacional puro)

## 📚 Segunda Forma Normal (2FN)

**Reglas:**
1. Estar en 1FN
2. Todos los atributos no-clave dependen de **toda** la PK (no de una parte)

> Aplica solo si la PK es compuesta.

### Antes (viola 2FN)

**Pedido_detalle** (PK compuesta: `pedido_id, producto_id`)

| pedido_id | producto_id | cantidad | producto_nombre | producto_precio |
|-----------|-------------|----------|-----------------|-----------------|
| 1 | 1 | 2 | Laptop | 1200 |
| 1 | 2 | 1 | Mouse | 25.50 |

`producto_nombre` y `producto_precio` dependen solo de `producto_id`, **no de toda la PK**.

### Después (2FN)

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

## 📚 Tercera Forma Normal (3FN)

**Reglas:**
1. Estar en 2FN
2. Ningún atributo no-clave depende de otro atributo no-clave (dependencia transitiva)

### Antes (viola 3FN)

**Clientes:**

| id | nombre | ciudad | codigo_postal |
|----|--------|--------|---------------|
| 1 | Ana | Madrid | 28001 |
| 2 | Luis | Madrid | 28001 |
| 3 | Marta | Barcelona | 08001 |

`codigo_postal` depende de `ciudad`, no de `id`.

### Después (3FN)

**Clientes:**
| id | nombre | ciudad_id |
|----|--------|-----------|
| 1 | Ana | 1 |
| 2 | Luis | 1 |
| 3 | Marta | 2 |

**Ciudades:**
| id | nombre | codigo_postal |
|----|--------|---------------|
| 1 | Madrid | 28001 |
| 2 | Barcelona | 08001 |

## 📚 Forma Normal de Boyce-Codd (BCNF)

Versión más estricta de 3FN. Se cumple cuando **todo determinante es clave candidata**.

Se menciona por completitud. En la práctica, si estás en 3FN, casi siempre estás en BCNF.

## 🎯 Ejemplo completo paso a paso

### Datos crudos

| pedido | cliente | email | productos | precio_unit | cantidad | categoria |
|--------|---------|-------|-----------|-------------|----------|-----------|
| 1 | Ana | ana@x.com | Laptop | 1200 | 1 | Electrónica |
| 1 | Ana | ana@x.com | Mouse | 25.50 | 2 | Electrónica |
| 2 | Luis | luis@x.com | Silla | 250 | 1 | Muebles |

### 1FN: eliminar multivaluados

Ya están atómicos (cada fila un producto).

### 2FN: eliminar dependencias parciales

`cliente`, `email` dependen de `pedido` (parte de la PK).
`productos`, `precio_unit`, `categoria` dependen de `producto`.

**Pedidos:**
| id | cliente_id |
|----|------------|
| 1 | 1 |
| 2 | 2 |

**Pedido_detalle:**
| pedido_id | producto_id | cantidad |
|-----------|-------------|----------|
| 1 | 1 | 1 |
| 1 | 2 | 2 |
| 2 | 3 | 1 |

**Productos:**
| id | nombre | precio | categoria |
|----|--------|--------|-----------|
| 1 | Laptop | 1200 | Electrónica |
| 2 | Mouse | 25.50 | Electrónica |
| 3 | Silla | 250 | Muebles |

### 3FN: eliminar dependencias transitivas

`email` depende de `cliente`, `categoria` depende de `producto`. Hay que separar.

**Clientes:**
| id | nombre | email |
|----|--------|-------|
| 1 | Ana | ana@x.com |
| 2 | Luis | luis@x.com |

**Categorías:**
| id | nombre |
|----|--------|
| 1 | Electrónica |
| 2 | Muebles |

**Productos:**
| id | nombre | precio | categoria_id |
|----|--------|--------|--------------|
| 1 | Laptop | 1200 | 1 |
| 2 | Mouse | 25.50 | 1 |
| 3 | Silla | 250 | 2 |

## 📊 Resumen

| Forma | Regla |
|-------|-------|
| 1FN | Sin valores multivaluados |
| 2FN | 1FN + sin dependencias parciales |
| 3FN | 2FN + sin dependencias transitivas |
| BCNF | 3FN + todo determinante es clave |

## 🎯 Regla mnemotécnica

> **"Cada hecho, en su lugar."**
>
> Cada tabla representa un hecho, cada columna un atributo de ese hecho, y todo depende de la clave.

## ⚠️ Errores comunes

- Normalizar en exceso (demasiadas tablas con 2 columnas)
- No normalizar nunca (redundancia masiva)
- Confundir 2FN con "eliminar repetidos" (eso es otra cosa)
- Aplicar 3FN a tablas que nunca se actualizan (ej: logs)

## ✅ Ejercicios

1. Normaliza esta tabla hasta 3FN:

| factura | cliente | email | productos | precio | fecha |
|---------|---------|-------|-----------|--------|-------|
| F1 | Ana | ana@x.com | Laptop, Mouse | 1200, 25.50 | 2024-01-10 |

2. ¿Qué forma normal viola esta tabla?

| id | nombre | telefono1 | telefono2 |
|----|--------|-----------|-----------|
| 1 | Ana | 111 | 222 |

3. Normaliza hasta 3FN:

| empleado | departamento | jefe_departamento | ciudad_departamento |
|----------|--------------|-------------------|---------------------|
| Ana | Ventas | Luis | Madrid |
| Marta | Ventas | Luis | Madrid |

4. ¿Por qué `codigo_postal` con `ciudad` viola 3FN?

5. Normaliza el dataset de la tienda (módulo 02) si encontraras redundancias.

## 🔗 Recursos

- [Normalización - Wikipedia](https://es.wikipedia.org/wiki/Normalizaci%C3%B3n_de_bases_de_datos)