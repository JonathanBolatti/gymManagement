# 🏋️ Gym Management - Colección de Postman

Esta colección contiene **todos los endpoints** de la API de miembros del sistema de gestión de gimnasio.

## 📥 **Cómo Importar la Colección**

### **Opción 1: Importar desde archivo**
1. Abre **Postman**
2. Haz click en **"Import"** (arriba a la izquierda)
3. Selecciona **"Upload Files"**
4. Selecciona el archivo `Gym_Management_Members_API.postman_collection.json`
5. Haz click en **"Import"**

### **Opción 2: Importar desde URL**
1. Abre **Postman**
2. Haz click en **"Import"**
3. Selecciona **"Link"**
4. Pega la URL del archivo raw desde GitHub
5. Haz click en **"Continue"** y luego **"Import"**

## 🚀 **Configuración Inicial**

### **Variables de Entorno**
La colección usa una variable `{{baseUrl}}` que está configurada por defecto a:
- **baseUrl:** `http://localhost:8080`

Si tu servidor está en un puerto diferente, puedes:
1. Ir a la pestaña **"Variables"** de la colección
2. Cambiar el valor de `baseUrl`

## 📋 **Endpoints Incluidos**

### **👥 Members CRUD**
- `POST /api/members` - Crear nuevo miembro
- `GET /api/members` - Obtener todos (con paginación)
- `GET /api/members/{id}` - Obtener por ID
- `PUT /api/members/{id}` - Actualizar miembro
- `DELETE /api/members/{id}` - Eliminar (borrado lógico)

### **🔍 Búsqueda y Filtros**
- `GET /api/members/email/{email}` - Buscar por email
- `GET /api/members/search?name=` - Buscar por nombre
- `GET /api/members/active` - Obtener miembros activos

### **📊 Estadísticas y Monitoreo**
- `GET /api/members/stats` - Estadísticas de miembros
- `GET /api/members/health` - Health check del servicio

### **🗄️ Base de Datos y Sistema**
- `GET /h2-console` - Acceso a consola H2
- `GET /actuator/health` - Estado del sistema
- `GET /actuator/metrics` - Métricas del sistema

## 🔧 **Cómo Usar**

### **1. Verificar que el servidor esté corriendo**
Ejecuta primero el endpoint **"💚 Health Check"** para confirmar que la API responde.

### **2. Crear un miembro de prueba**
Usa **"➕ Crear Miembro"** con los datos de ejemplo incluidos.

### **3. Probar otros endpoints**
Una vez creado un miembro, puedes probar los demás endpoints usando el ID devuelto.

## 📝 **Datos de Ejemplo**

### **Crear Miembro (POST)**
```json
{
  "firstName": "Juan Carlos",
  "lastName": "Pérez González",
  "email": "juan.perez@email.com",
  "phone": "+56987654321",
  "birthDate": "1990-05-15",
  "gender": "M",
  "height": 1.75,
  "weight": 75.5,
  "emergencyContact": "María Pérez",
  "emergencyPhone": "+56987654322",
  "observations": "Interesado en entrenamiento funcional"
}
```

### **Actualizar Miembro (PUT)**
```json
{
  "firstName": "Juan Carlos",
  "lastName": "Pérez González",
  "email": "juan.perez.updated@email.com",
  "phone": "+56987654321",
  "weight": 76.0,
  "observations": "Actualizado - Entrenamiento funcional avanzado"
}
```

## 🔑 **Credenciales H2 Console**

Para acceder a la consola H2:
- **URL:** http://localhost:8080/h2-console
- **JDBC URL:** `jdbc:h2:mem:gymdb`
- **Usuario:** `root`
- **Contraseña:** `root`

## ⚡ **Consejos de Uso**

1. **Orden recomendado:** Empezar con Health Check → Crear Miembro → Probar otros endpoints
2. **Paginación:** Los endpoints de listado soportan parámetros `page`, `size`, `sortBy`, `sortDirection`
3. **Búsquedas:** Las búsquedas por nombre son case-insensitive y permiten coincidencias parciales
4. **Borrado lógico:** DELETE no elimina físicamente, solo desactiva (isActive = false)

## 🐛 **Solución de Problemas**

### **Error de conexión**
- Verificar que el servidor Spring Boot esté corriendo
- Confirmar el puerto (por defecto 8080)
- Verificar la variable `baseUrl` en Postman

### **Error 404**
- Verificar que la ruta del endpoint sea correcta
- Confirmar que el ID del miembro existe (para endpoints con {id})

### **Error de validación (400)**
- Verificar que todos los campos obligatorios estén presentes
- Confirmar que el formato de fecha sea `YYYY-MM-DD`
- Verificar que el gender sea `M`, `F`, o `O`

¡Ya está todo listo para probar la API! 🎉 