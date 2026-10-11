# 🧪 Ejercicios - Modelado Documental

## Nivel 🟢 Fácil

### 1. Embeber o referenciar
Para un blog con posts y comentarios, ¿qué elegirías? Justifica.

<details>
<summary>💡 Solución</summary>

Depende del volumen:

- **Pocos comentarios (típico):** embeber
```javascript
{
    "_id": 1,
    "titulo": "Intro a NoSQL",
    "comentarios": [
        { "autor": "Luis", "texto": "Buen post" },
        { "autor": "Marta", "texto": "Gracias!" }
    ]
}
```

- **Miles de comentarios:** referenciar
```javascript
// posts
{ "_id": 1, "titulo": "Intro a NoSQL" }

// comentarios
{ "_id": 1, "post_id": 1, "autor": "Luis", "texto": "Buen post" }
```

**Regla:** si el array puede crecer mucho → referenciar.

</details>

### 2. Identificar anti-patrón
¿Qué problema tiene este documento?

```javascript
{
    "_id": 1,
    "usuario": "Ana",
    "logs": [/* 500.000 entradas */]
}
```

<details>
<summary>💡 Solución</summary>

**Array sin límite.** Crecerá hasta superar los 16 MB del límite de MongoDB.

**Solución:** colección separada `logs` con `usuario_id`.

</details>

---

## Nivel 🟡 Intermedio

### 3. Modelar e-commerce
Diseña las colecciones para un e-commerce con clientes, productos, pedidos.

<details>
<summary>💡 Solución</summary>

```javascript
// clientes
{
    "_id": ObjectId(),
    "nombre": "Ana",
    "email": "ana@x.com",
    "direcciones": [
        { "calle": "Gran Vía 10", "ciudad": "Madrid", "principal": true },
        { "calle": "Mayor 5", "ciudad": "Madrid", "principal": false }
    ]
}

// productos
{
    "_id": ObjectId(),
    "nombre": "Laptop",
    "categoria": "Electrónica",
    "precio": 1200,
    "atributos": { "ram": "16GB", "cpu": "i7" }  // flexible por categoría
}

// pedidos (embebe snapshot histórico)
{
    "_id": ObjectId(),
    "cliente_id": ObjectId(),
    "fecha": ISODate(),
    "productos": [
        { "producto_id": ObjectId(), "nombre": "Laptop", "precio": 1200, "cantidad": 1 }
    ],
    "total": 1200,
    "estado": "pendiente"
}
```

**Decisiones:**
- Direcciones embebidas (pocas, siempre con el cliente)
- Atributos flexibles por categoría
- Productos del pedido embebidos con precio histórico

</details>

### 4. Modelar red social
Diseña usuarios con seguidores.

<details>
<summary>💡 Solución</summary>

```javascript
// usuarios
{
    "_id": ObjectId(),
    "username": "ana",
    "nombre": "Ana",
    "siguiendo": [ObjectId("..."), ObjectId("...")],
    "seguidores": [ObjectId("...")]
}
```

**O referenciado:**
```javascript
// usuarios
{ "_id": ObjectId(), "username": "ana", "nombre": "Ana" }

// follows
{ "seguidor_id": ObjectId(), "seguido_id": ObjectId(), "fecha": ISODate() }
```

**Decisión:**
- Arrays si < 10.000 (cabe en 16 MB)
- Colección aparte si millones

</details>

---

## Nivel 🔴 Difícil

### 5. Chat de mensajería
Modela conversaciones y mensajes.

<details>
<summary>💡 Solución</summary>

**Opción 1: conversación con mensajes embebidos (para chats pequeños)**
```javascript
{
    "_id": ObjectId(),
    "participantes": [1, 2],
    "mensajes": [
        { "autor": 1, "texto": "Hola", "fecha": ISODate() },
        { "autor": 2, "texto": "Qué tal", "fecha": ISODate() }
    ]
}
```

**Opción 2: conversación + colección mensajes (para chats grandes)**
```javascript
// conversaciones
{ "_id": ObjectId(), "participantes": [1, 2], "ultimo_mensaje": ISODate() }

// mensajes
{ "_id": ObjectId(), "conversacion_id": ObjectId(), "autor": 1, "texto": "Hola", "fecha": ISODate() }
```

**Recomendación:** Opción 2 para chats activos. Los arrays crecen demasiado.

</details>

### 6. IoT con millones de eventos
Modela sensores que envían datos cada segundo.

<details>
<summary>💡 Solución</summary>

**Patrón Bucket:** agrupar por hora/día.

```javascript
{
    "_id": ObjectId(),
    "sensor_id": "sensor-001",
    "fecha": ISODate("2024-01-01T10:00:00Z"),
    "hora": 10,
    "lecturas": [
        { "t": "10:00:01", "temperatura": 22.5 },
        { "t": "10:00:02", "temperatura": 22.6 },
        // ... 3600 lecturas en una hora
    ],
    "total_lecturas": 3600,
    "temp_max": 23.1,
    "temp_min": 22.0,
    "temp_promedio": 22.4
}
```

**Ventajas:**
- Un documento por hora en lugar de 3600
- Pre-agregados listos
- Sin arrays infinitos

</details>