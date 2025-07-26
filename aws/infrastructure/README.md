# 🏗️ Infraestructura AWS - Gym Management System

Este directorio contiene toda la configuración e infraestructura necesaria para desplegar el sistema de gestión de gimnasio en AWS utilizando la capa gratuita.

## 📋 Componentes de la Infraestructura

### 🗄️ Base de Datos
- **RDS MySQL**: Instancia `db.t3.micro` (Free Tier eligible)
- **Almacenamiento**: 20 GB gp2
- **Backup**: Automático diario
- **Multi-AZ**: No (Free Tier)

### 🖥️ Compute
- **EC2**: Instancia `t2.micro` (Free Tier eligible)
- **AMI**: Amazon Linux 2
- **Java**: OpenJDK 17
- **Aplicación**: Spring Boot JAR

### 🌐 Networking
- **VPC**: VPC personalizada con subnets públicas y privadas
- **Security Groups**: 
  - SG para aplicación (puerto 8080)
  - SG para base de datos (puerto 3306)
- **Load Balancer**: Application Load Balancer (ALB)

### 📦 Almacenamiento
- **S3**: Bucket para archivos estáticos y logs
- **CloudFront**: CDN para contenido estático (opcional)

### 📊 Monitoreo
- **CloudWatch**: Métricas y logs
- **Alarmas**: CPU, memoria, errores de aplicación
- **Dashboard**: Visualización de métricas clave

## 🚀 Guía de Despliegue

### Prerrequisitos
1. Cuenta AWS activa
2. AWS CLI configurado
3. Acceso a la consola de AWS
4. Usuario IAM con permisos necesarios

### Variables de Entorno Requeridas
```bash
# Base de datos
export RDS_ENDPOINT=gym-db.xxx.us-east-1.rds.amazonaws.com
export RDS_DB_NAME=gym_management
export RDS_USERNAME=gymuser
export RDS_PASSWORD=secure_password_here

# AWS
export AWS_REGION=us-east-1
export S3_BUCKET_NAME=gym-management-bucket-unique-name

# CloudWatch
export CLOUDWATCH_NAMESPACE=GymManagement
export CLOUDWATCH_METRICS_ENABLED=true

# Servidor
export SERVER_PORT=8080
export SSL_ENABLED=false
```

### Pasos de Configuración

1. **Configuración de VPC y Networking**
   ```bash
   cd aws/scripts
   ./01-setup-vpc.sh
   ```

2. **Configuración de RDS**
   ```bash
   ./02-setup-rds.sh
   ```

3. **Configuración de S3**
   ```bash
   ./03-setup-s3.sh
   ```

4. **Configuración de EC2**
   ```bash
   ./04-setup-ec2.sh
   ```

5. **Configuración de CloudWatch**
   ```bash
   ./05-setup-monitoring.sh
   ```

## 📁 Estructura de Archivos

```
aws/
├── infrastructure/
│   ├── README.md              # Este archivo
│   ├── architecture.md        # Diagrama de arquitectura
│   └── costs.md              # Estimación de costos
├── scripts/
│   ├── 01-setup-vpc.sh       # Configuración de VPC
│   ├── 02-setup-rds.sh       # Configuración de RDS
│   ├── 03-setup-s3.sh        # Configuración de S3
│   ├── 04-setup-ec2.sh       # Configuración de EC2
│   ├── 05-setup-monitoring.sh # Configuración de CloudWatch
│   └── cleanup.sh            # Script de limpieza
├── cloudformation/
│   ├── vpc-stack.yaml        # Template de VPC
│   ├── rds-stack.yaml        # Template de RDS
│   ├── ec2-stack.yaml        # Template de EC2
│   └── monitoring-stack.yaml # Template de CloudWatch
└── docker/
    ├── Dockerfile            # Imagen de la aplicación
    ├── docker-compose.yml    # Para desarrollo local
    └── scripts/
        ├── build.sh          # Script de build
        └── deploy.sh         # Script de deploy
```

## 🔧 Configuración Local para Testing

Para probar la configuración AWS localmente:

```bash
# Usar LocalStack para simular servicios AWS
docker-compose -f docker-compose.localstack.yml up -d

# Configurar variables de entorno para LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1
```

## 🚨 Seguridad

### Configuraciones Importantes
- Todas las contraseñas deben estar en AWS Systems Manager Parameter Store
- Security Groups con acceso mínimo necesario
- RDS en subnet privada
- Backup automático habilitado
- Logs de CloudTrail habilitados

### Buenas Prácticas
- Usar IAM roles en lugar de claves de acceso
- Rotar credenciales regularmente
- Monitorear costos constantemente
- Implementar alertas de seguridad

## 💰 Estimación de Costos (Free Tier)

| Servicio | Cantidad | Costo Mensual |
|----------|----------|---------------|
| EC2 t2.micro | 750 horas | $0.00* |
| RDS t3.micro | 750 horas | $0.00* |
| S3 Standard | 5 GB | $0.00* |
| CloudWatch | Métricas básicas | $0.00* |
| Data Transfer | 1 GB/mes | $0.00* |

*Durante el primer año con Free Tier

## 📞 Soporte

Para problemas con la infraestructura:
1. Revisar CloudWatch Logs
2. Verificar Security Groups
3. Consultar documentación de AWS
4. Contactar al equipo de DevOps 