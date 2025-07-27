# 🏋️ Gym Management - Complete API Collection

Esta colección contiene **todos los endpoints** del sistema de gestión de gimnasio, incluyendo gestión de miembros (clientes) y usuarios (empleados/administradores).

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

### **Autenticación (Opcional)**
Algunos endpoints pueden requerir autenticación:
- **Usuario:** `admin` (o cualquier username de usuario creado)
- **Contraseña:** Ver logs de la aplicación para el password generado por Spring Security

## 📋 **Endpoints Incluidos**

### **👥 Members CRUD (Clientes del Gimnasio)**
- `POST /api/members` - Crear nuevo miembro
- `GET /api/members` - Obtener todos (con paginación)
- `GET /api/members/{id}` - Obtener por ID
- `PUT /api/members/{id}` - Actualizar miembro
- `DELETE /api/members/{id}` - Eliminar (borrado lógico)

### **👨‍💼 Users CRUD (Empleados/Administradores)**
- `POST /api/users` - Crear nuevo usuario
- `GET /api/users` - Obtener todos los usuarios
- `GET /api/users/active` - Obtener usuarios activos
- `GET /api/users/{id}` - Obtener por ID
- `GET /api/users/username/{username}` - Obtener por username
- `GET /api/users/email/{email}` - Obtener por email
- `PUT /api/users/{id}` - Actualizar usuario
- `PATCH /api/users/{id}/activate` - Activar usuario
- `PATCH /api/users/{id}/deactivate` - Desactivar usuario
- `DELETE /api/users/{id}` - Eliminar usuario (física)

### **🔍 Members - Búsqueda y Filtros**
- `GET /api/members/email/{email}` - Buscar por email
- `GET /api/members/search?name=` - Buscar por nombre
- `GET /api/members/active` - Obtener miembros activos

### **🔍 Users - Búsqueda y Filtros**
- `GET /api/users/role/{role}` - Obtener por rol (ADMIN, MANAGER, RECEPTIONIST)
- `GET /api/users/role/{role}/active` - Usuarios activos por rol
- `GET /api/users/search?q={term}` - Buscar usuarios por nombre, apellido, username o email

### **✅ Users - Validaciones**
- `GET /api/users/exists/username/{username}` - Verificar si username existe
- `GET /api/users/exists/email/{email}` - Verificar si email existe

### **📊 Members - Estadísticas y Monitoreo**
- `GET /api/members/stats` - Estadísticas de miembros
- `GET /api/members/health` - Health check del servicio

### **🗄️ Base de Datos y Sistema**
- `GET /h2-console` - Acceso a consola H2 (desarrollo)
- `GET /actuator/health` - Estado del sistema
- `GET /actuator/metrics` - Métricas del sistema

## 🎭 **Roles de Usuario**

El sistema maneja tres tipos de roles para usuarios:

- **ADMIN**: Administrador del sistema (acceso completo)
- **MANAGER**: Manager/Gerente (gestión operativa) 
- **RECEPTIONIST**: Recepcionista (operaciones básicas)

## 🔧 **Cómo Usar**

### **1. Verificar que el servidor esté corriendo**
Ejecuta primero el endpoint **"💚 Health Check"** para confirmar que la API responde.

### **2. Explorar datos pre-cargados**
La aplicación incluye datos de prueba:
- **Usuarios:** admin, manager.juan, recep.maria, etc.
- **Miembros:** Ana García, Carlos López, Sofia Martínez, etc.

### **3. Probar endpoints GET (no requieren autenticación)**
- Obtener todos los usuarios: `GET /api/users`
- Obtener usuarios por rol: `GET /api/users/role/ADMIN`
- Buscar usuarios: `GET /api/users/search?q=admin`

### **4. Crear nuevos registros**
Usa los endpoints POST para crear nuevos usuarios y miembros.

## 📝 **Datos de Ejemplo**

### **Crear Usuario (POST /api/users)**
```json
{
  "username": "nuevo.empleado",
  "email": "empleado@gym.com",
  "password": "password123",
  "firstName": "Nuevo",
  "lastName": "Empleado",
  "phone": "+56999888777",
  "role": "RECEPTIONIST"
}
```

### **Crear Miembro (POST /api/members)**
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

### **Actualizar Usuario (PUT /api/users/{id})**
```json
{
  "firstName": "Nombre Actualizado",
  "lastName": "Apellido Actualizado",
  "phone": "+56888777666",
  "role": "MANAGER"
}
```

## 🗃️ **Datos Pre-cargados**

### **Usuarios del Sistema**
- **admin** (admin@gym.com) - ADMIN
- **manager.juan** (juan.manager@gym.com) - MANAGER  
- **recep.maria** (maria.recep@gym.com) - RECEPTIONIST
- **manager.ana** (ana.manager@gym.com) - MANAGER
- **recep.carlos** (carlos.recep@gym.com) - RECEPTIONIST (inactivo)

### **Miembros/Clientes**
- **Ana García** (ana.garcia@email.com) - Activa
- **Carlos López** (carlos.lopez@email.com) - Activo
- **Sofia Martínez** (sofia.martinez@email.com) - Activa
- **Diego Rodríguez** (diego.rodriguez@email.com) - Activo
- **Valentina Torres** (valentina.torres@email.com) - Inactiva

## 🔑 **Credenciales Base de Datos**

### **MySQL (Producción/Desarrollo)**
Ver configuración en `application-dev.properties`

### **H2 Console (Desarrollo local)**
- **URL:** http://localhost:8080/h2-console
- **JDBC URL:** `jdbc:h2:mem:gymdb`
- **Usuario:** `root`
- **Contraseña:** `root`

## ⚡ **Consejos de Uso**

### **1. Orden recomendado de pruebas:**
1. **Health Check** → Verificar que todo funciona
2. **GET Endpoints** → Explorar datos existentes
3. **Validaciones** → Probar verificación de duplicados
4. **POST Endpoints** → Crear nuevos registros
5. **PUT/PATCH** → Actualizar datos
6. **DELETE** → Eliminar registros

### **2. Validaciones importantes:**
- **Usernames y emails únicos** (para usuarios)
- **Emails únicos** (para miembros)
- **Contraseñas mínimo 8 caracteres**
- **Roles válidos:** ADMIN, MANAGER, RECEPTIONIST
- **Géneros válidos:** M, F, O

### **3. Funcionalidades especiales:**
- **Paginación:** Endpoints de members soportan `page`, `size`, `sortBy`, `sortDirection`
- **Búsquedas:** Case-insensitive con coincidencias parciales
- **Borrado lógico:** Members se desactivan, Users se eliminan físicamente
- **Estados:** Users y Members pueden activarse/desactivarse

## 🧪 **Testing Endpoints**

### **Pruebas rápidas con curl:**
```bash
# Obtener todos los usuarios
curl -X GET http://localhost:8080/api/users

# Buscar usuarios por rol
curl -X GET http://localhost:8080/api/users/role/ADMIN

# Verificar si username existe
curl -X GET http://localhost:8080/api/users/exists/username/admin

# Obtener miembros activos
curl -X GET http://localhost:8080/api/members/active
```

## 🐛 **Solución de Problemas**

### **Error de conexión**
- Verificar que Spring Boot esté corriendo (`mvn spring-boot:run`)
- Confirmar el puerto (por defecto 8080)
- Verificar la variable `baseUrl` en Postman

### **Error 401 (Unauthorized)**
- Configurar autenticación básica en Postman
- Usar credenciales: username y password (ver logs de la aplicación)

### **Error 404**
- Verificar que la ruta del endpoint sea correcta
- Confirmar que el ID existe (para endpoints con {id})

### **Error 409 (Conflict)**
- Username o email ya existe (para usuarios)
- Email ya existe (para miembros)

### **Error de validación (400)**
- Verificar campos obligatorios
- Confirmar formato de fecha `YYYY-MM-DD`
- Verificar que role sea: ADMIN, MANAGER, o RECEPTIONIST
- Verificar que gender sea: M, F, o O

### **Error 500 (Internal Server Error)**
- Verificar logs de la aplicación
- Confirmar configuración de base de datos
- Verificar que Spring Security esté configurado correctamente

## 📊 **Estadísticas de la Colección**

- **Total Endpoints:** 25+
- **Entidades:** Members (clientes) y Users (empleados)
- **Operaciones CRUD:** Completas para ambas entidades
- **Búsquedas:** Por múltiples campos
- **Validaciones:** Duplicados y formato
- **Monitoreo:** Health checks y métricas

¡Todo listo para gestionar tu gimnasio! 💪🏋️‍♀️ 