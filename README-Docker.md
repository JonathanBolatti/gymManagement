# Docker Compose - Desarrollo Local

Este archivo te permite levantar una base de datos MySQL localmente para desarrollo.

## 🚀 Inicio Rápido

### 1. Levantar la Base de Datos

```bash
# Levantar MySQL + PhpMyAdmin en background
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f mysql-dev
```

### 2. Verificar que Está Funcionando

```bash
# Verificar status de los contenedores
docker-compose ps

# Deberías ver algo así:
# CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS                   PORTS                    NAMES
# abc123...      mysql:8.0 "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:3306->3306/tcp   gym-mysql-dev
```

### 3. Ejecutar tu Aplicación Spring Boot

```bash
# Asegúrate de usar el perfil 'dev'
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# O desde tu IDE con perfil activo: dev
```

## 🔧 Servicios Disponibles

### **MySQL Database**
- **Host**: localhost
- **Puerto**: 3306
- **Database**: gym_management
- **Usuario**: gymuser
- **Password**: gympass
- **Root Password**: rootpass

### **PhpMyAdmin** (Interfaz Web)
- **URL**: http://localhost:8081
- **Usuario**: root
- **Password**: rootpass

## 📋 Comandos Útiles

```bash
# Levantar servicios
docker-compose up -d

# Parar servicios (mantiene datos)
docker-compose stop

# Parar y eliminar contenedores (mantiene datos)
docker-compose down

# Eliminar TODO (contenedores + datos)
docker-compose down -v

# Ver logs de MySQL
docker-compose logs mysql-dev

# Conectarse a MySQL directamente
docker-compose exec mysql-dev mysql -u root -p gym_management

# Reiniciar solo MySQL
docker-compose restart mysql-dev

# Ver uso de recursos
docker stats gym-mysql-dev
```

## 🗄️ Gestión de Datos

### **Datos de Prueba**
Los datos de prueba (5 miembros) se cargan automáticamente desde `data-dev.sql` cuando inicias la aplicación Spring Boot.

### **Persistencia**
Los datos se mantienen entre reinicios gracias al volumen `mysql_data`. Para empezar desde cero:

```bash
# Eliminar todos los datos
docker-compose down -v

# Levantar de nuevo
docker-compose up -d
```

### **Backup Manual**
```bash
# Crear backup
docker-compose exec mysql-dev mysqldump -u root -prootpass gym_management > backup.sql

# Restaurar backup
docker-compose exec -T mysql-dev mysql -u root -prootpass gym_management < backup.sql
```

## 🐛 Solución de Problemas

### **Puerto 3306 ya en uso**
```bash
# Ver qué está usando el puerto
lsof -i :3306

# Cambiar puerto en docker-compose.yml
ports:
  - "3307:3306"  # Cambiar 3306 por 3307

# Actualizar application-dev.properties
spring.datasource.url=jdbc:mysql://localhost:3307/gym_management...
```

### **MySQL no inicia**
```bash
# Ver logs detallados
docker-compose logs mysql-dev

# Reiniciar contenedor
docker-compose restart mysql-dev

# Eliminar y recrear
docker-compose down
docker-compose up -d
```

### **Conexión rechazada desde Spring Boot**
1. Verifica que MySQL esté corriendo: `docker-compose ps`
2. Espera que el health check sea "healthy"
3. Verifica la configuración en `application-dev.properties`

## 📊 Monitoreo

### **Logs en Tiempo Real**
```bash
# Todos los servicios
docker-compose logs -f

# Solo MySQL
docker-compose logs -f mysql-dev

# Solo PhpMyAdmin
docker-compose logs -f phpmyadmin
```

### **Performance**
```bash
# Uso de CPU/Memoria
docker stats

# Información del contenedor
docker inspect gym-mysql-dev
```

## 🔗 Integración con IDE

### **IntelliJ IDEA / Spring Tool Suite**
1. Ve a **Run Configuration**
2. Añade **Environment Variable**: `SPRING_PROFILES_ACTIVE=dev`
3. Ejecuta la aplicación

### **VS Code**
Añade en tu `.vscode/launch.json`:
```json
{
  "name": "Spring Boot Dev",
  "type": "java",
  "request": "launch",
  "mainClass": "com.gym_management.system.SystemApplication",
  "env": {
    "SPRING_PROFILES_ACTIVE": "dev"
  }
}
```

¡Tu entorno de desarrollo con MySQL está listo! 🎉 