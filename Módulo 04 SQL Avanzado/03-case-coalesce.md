# 03 - CASE y COALESCE

## 🎯 Objetivos

- Transformar valores con CASE
- Manejar NULL con COALESCE, NULLIF
- Escribir consultas con lógica condicional

## 📚 CASE

Es el "if/else" de SQL.

### CASE simple (comparación de igualdad)

```sql
SELECT 
    nombre,
    stock,
    CASE stock
        WHEN 0 THEN 'Sin stock'
        WHEN 1 THEN 'Última unidad'
        ELSE 'Disponible'
    END AS estado
FROM productos;
```

### CASE buscado (condiciones)

```sql
SELECT 
    nombre,
    precio,
    CASE 
        WHEN precio < 50 THEN 'Barato'
        WHEN precio BETWEEN 50 AND 200 THEN 'Medio'
        ELSE 'Caro'
    END AS rango
FROM productos;
```

### CASE con agregados

```sql
SELECT 
    COUNT(CASE WHEN precio < 100 THEN 1 END) AS economicos,
    COUNT(CASE WHEN precio >= 100 THEN 1 END) AS costosos
FROM productos;
```

**Resultado:** una fila con dos conteos condicionales.

### CASE en ORDER BY

```sql
SELECT nombre, categoria, precio
FROM productos
ORDER BY 
    CASE categoria
        WHEN 'Electrónica' THEN 1
        WHEN 'Ropa' THEN 2
        ELSE 3
    END,
    precio DESC;
```

## 📚 COALESCE

Devuelve el **primer valor no NULL** de la lista.

```sql
SELECT 
    nombre,
    COALESCE(email, 'sin-email@dominio.com') AS email
FROM clientes;
```

### Casos de uso

- Reemplazar NULL con un valor por defecto
- Encadenar valores opcionales
- Evitar divisiones por NULL en cálculos

```sql
SELECT 
    nombre,
    COALESCE(email, telefono, 'Sin contacto') AS contacto
FROM clientes;
```

## 📚 NULLIF

Devuelve NULL si los dos argumentos son iguales. Útil para **evitar divisiones por cero**.

```sql
SELECT 
    a,
    b,
    a / NULLIF(b, 0) AS resultado
FROM calculos;
```

Si `b = 0`, `NULLIF` devuelve NULL y la división no falla.

## 📚 ISNULL / IFNULL (según motor)

| Función | Motor |
|---------|-------|
| `COALESCE` | Estándar SQL (todos) |
| `IFNULL(a, b)` | MySQL, SQLite |
| `ISNULL(a, b)` | SQL Server |
| `NVL(a, b)` | Oracle |

> 💡 **Recomendación:** usa siempre `COALESCE` para portabilidad.

## 🎯 Patrones útiles

### Segmentación de clientes

```sql
SELECT 
    nombre,
    edad,
    CASE 
        WHEN edad < 25 THEN 'Joven'
        WHEN edad < 40 THEN 'Adulto'
        ELSE 'Senior'
    END AS segmento
FROM clientes;
```

### Pivotar datos (fila → columnas)

```sql
SELECT 
    categoria,
    COUNT(CASE WHEN stock > 50 THEN 1 END) AS mucho_stock,
    COUNT(CASE WHEN stock BETWEEN 10 AND 50 THEN 1 END) AS medio_stock,
    COUNT(CASE WHEN stock < 10 THEN 1 END) AS poco_stock
FROM productos
GROUP BY categoria;
```

### Ordenar con prioridad personalizada

```sql
SELECT nombre, categoria
FROM productos
ORDER BY 
    CASE 
        WHEN categoria = 'Electrónica' THEN 0
        WHEN categoria = 'Ropa' THEN 1
        ELSE 2
    END,
    nombre;
```

## ⚠️ Errores comunes

- Olvidar `END` al final del CASE
- No incluir `ELSE` (devuelve NULL por defecto)
- Usar `CASE` donde `COALESCE` es más simple
- Confundir `COALESCE` con `NULLIF`

## ✅ Ejercicios

1. Muestra cada cliente con su email o 'sin-email' si es NULL
2. Clasifica productos en: barato (<50), medio (50-200), caro (>200)
3. Cuenta cuántos clientes son mayores de 30 y cuántos menores en una sola fila
4. Muestra productos con una columna "disponibilidad": sin stock, poco, normal
5. Ordena los pedidos poniendo primero los del mes actual
6. Por categoría, cuenta cuántos productos tienen stock alto/medio/bajo

## 🔗 Recursos

- [CASE - PostgreSQL](https://www.postgresql.org/docs/current/functions-conditional.html)