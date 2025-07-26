# Despliegue en Railway - Gym Management System

## Configuración del Proyecto

Este proyecto está configurado para desplegarse en Railway con las siguientes características:

- **Runtime**: Java 17
- **Framework**: Spring Boot 3.5.3
- **Base de datos**: MySQL
- **Puerto**: 8080 (configurable via variable `PORT`)

## Pasos para Desplegar

### 1. Preparar el Repositorio

Asegúrate de que los siguientes archivos estén en tu repositorio:
- `Dockerfile` - Configuración de contenedor optimizada para Railway
- `.dockerignore` - Exclusión de archivos innecesarios
- `src/main/resources/application-prod.properties` - Configuración de producción

### 2. Crear Proyecto en Railway

1. Ve a [railway.app](https://railway.app)
2. Conecta tu repositorio de GitHub
3. Selecciona este proyecto

### 3. Configurar Base de Datos MySQL

1. En el dashboard de Railway, haz clic en "Add Service"
2. Selecciona "MySQL" de la lista de servicios
3. Railway creará automáticamente las siguientes variables de entorno:
   - `DATABASE_URL`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`
   - `MYSQLHOST`
   - `MYSQLPORT`
   - `MYSQLDATABASE`

### 4. Variables de Entorno

Railway configurará automáticamente:
- `PORT` - Puerto donde correrá la aplicación
- Variables de MySQL (listadas arriba)

Opcionalmente, puedes configurar:
```
SPRING_PROFILES_ACTIVE=prod
JAVA_OPTS=-Xmx512m -Xms256m
```

### 5. Despliegue

Railway automáticamente:
1. Detectará el `Dockerfile`
2. Construirá la imagen Docker
3. Desplegará la aplicación
4. Proporcionará una URL pública

## Características del Dockerfile

- **Multi-stage build**: Optimiza el tamaño de la imagen
- **Usuario no-root**: Mayor seguridad
- **Health checks**: Monitoreo de salud automático
- **Compresión**: Respuestas HTTP optimizadas

## Monitoreo

La aplicación incluye actuator endpoints:
- `/actuator/health` - Estado de la aplicación
- `/actuator/info` - Información del sistema

## Notas Importantes

1. **Perfil de Producción**: La aplicación usará automáticamente el perfil `prod`
2. **SSL/TLS**: Railway maneja automáticamente los certificados SSL
3. **Logs**: Los logs están configurados para nivel INFO en producción
4. **Conexiones DB**: Pool configurado para 20 conexiones máximas

## Solución de Problemas

### Error de Conexión a Base de Datos
- Verifica que el servicio MySQL esté ejecutándose
- Confirma que las variables de entorno estén configuradas

### Error de Memoria
- Ajusta `JAVA_OPTS` para aumentar la memoria si es necesario
- Railway ofrece planes con más memoria disponible

### Puerto no Disponible
- Railway configura automáticamente la variable `PORT`
- No hardcodees el puerto en la aplicación

## Comandos Útiles

### Build local
```bash
docker build -t gym-management .
```

### Run local
```bash
docker run -p 8080:8080 gym-management
```

### Logs en Railway
```bash
railway logs
```

## Contacto

Para problemas específicos del despliegue, consulta la documentación de Railway o contacta al equipo de desarrollo. 