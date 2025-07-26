# 🏗️ Arquitectura AWS - Gym Management System

## 📋 Descripción General

La infraestructura de AWS para el sistema de gestión de gimnasio está diseñada siguiendo las mejores prácticas de seguridad, escalabilidad y costos optimizados utilizando la capa gratuita de AWS.

## 🎯 Componentes de la Arquitectura

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                       │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                           │
│                                                                 │
│  ┌──────────────────┐              ┌──────────────────┐        │
│  │  Public Subnet 1  │              │  Public Subnet 2  │        │
│  │   (10.0.1.0/24)  │              │   (10.0.2.0/24)  │        │
│  │                  │              │                  │        │
│  │  ┌─────────────┐ │              │                  │        │
│  │  │    EC2      │ │              │  ┌─────────────┐ │        │
│  │  │ Application │ │              │  │    ALB      │ │        │
│  │  │   Server    │ │              │  │ (Future)    │ │        │
│  │  └─────────────┘ │              │  └─────────────┘ │        │
│  └──────────────────┘              └──────────────────┘        │
│                                                                 │
│  ┌──────────────────┐              ┌──────────────────┐        │
│  │ Private Subnet 1 │              │ Private Subnet 2 │        │
│  │  (10.0.3.0/24)  │              │  (10.0.4.0/24)  │        │
│  │                  │              │                  │        │
│  │  ┌─────────────┐ │              │  ┌─────────────┐ │        │
│  │  │     RDS     │ │              │  │    RDS      │ │        │
│  │  │    MySQL    │ │              │  │  (Standby)  │ │        │
│  │  │   Primary   │ │              │  │ (Future)    │ │        │
│  │  └─────────────┘ │              │  └─────────────┘ │        │
│  └──────────────────┘              └──────────────────┘        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       Servicios Adicionales                     │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │      S3      │  │  CloudWatch  │  │     IAM      │         │
│  │   Buckets    │  │  Monitoring  │  │    Roles     │         │
│  │              │  │   & Logs     │  │  Policies    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Detallados

### 1. Networking (VPC)

**VPC Principal**
- **CIDR Block**: 10.0.0.0/16
- **DNS Resolution**: Habilitado
- **DNS Hostnames**: Habilitado

**Subnets Públicas**
- **Subnet 1**: 10.0.1.0/24 (AZ-1) - Servidor de aplicación
- **Subnet 2**: 10.0.2.0/24 (AZ-2) - Load balancer (futuro)
- **Características**: Auto-assign public IP habilitado

**Subnets Privadas**
- **Subnet 1**: 10.0.3.0/24 (AZ-1) - RDS Primary
- **Subnet 2**: 10.0.4.0/24 (AZ-2) - RDS Standby (futuro)
- **Características**: Sin acceso directo a internet

**Internet Gateway**
- **Función**: Permite acceso a internet para subnets públicas
- **Route Table**: Configurada para direccionar tráfico 0.0.0.0/0

### 2. Compute (EC2)

**Instancia de Aplicación**
- **Tipo**: t2.micro (Free Tier eligible)
- **AMI**: Amazon Linux 2 (última versión)
- **vCPUs**: 1
- **Memory**: 1 GB
- **Storage**: 8 GB EBS gp2
- **Network**: Subnet pública con IP elástica

**Configuración de Software**
- **Java**: OpenJDK 17 (Amazon Corretto)
- **Application Server**: Spring Boot embedded Tomcat
- **System Service**: systemd service configurado
- **Monitoring**: CloudWatch Agent instalado

**Security Groups**
- **Puertos abiertos**: 22 (SSH), 8080 (Aplicación), 80/443 (HTTP/HTTPS)
- **Source**: 0.0.0.0/0 (controlado por ALB en producción)

### 3. Base de Datos (RDS)

**Instancia RDS MySQL**
- **Tipo**: db.t3.micro (Free Tier eligible)
- **Engine**: MySQL 8.0.35
- **Storage**: 20 GB gp2 (encriptado)
- **Backup**: 7 días de retención
- **Multi-AZ**: Deshabilitado (Free Tier)

**Configuración de Red**
- **Subnet Group**: Subnets privadas en 2 AZs
- **Security Group**: Acceso solo desde EC2 (puerto 3306)
- **Public Access**: Deshabilitado

**Parámetros Optimizados**
- **innodb_buffer_pool_size**: 75% de memoria disponible
- **Connection Pool**: Configurado en aplicación

### 4. Almacenamiento (S3)

**Bucket Principal**
- **Propósito**: Archivos de aplicación (imágenes, documentos)
- **Versioning**: Habilitado
- **Encryption**: AES256
- **Lifecycle**: Standard → IA (30 días) → Glacier (90 días)

**Bucket de Logs**
- **Propósito**: Logs de acceso y auditoría
- **Retention**: 30 días
- **Access Logging**: Configurado para bucket principal

**Estructura de Directorios**
```
bucket-principal/
├── members/          # Imágenes de miembros
├── documents/        # Documentos del sistema
├── temp/            # Archivos temporales
└── config/          # Archivos de configuración
```

### 5. Monitoreo (CloudWatch)

**Métricas Monitoreadas**
- **EC2**: CPU, Memory, Network, Disk
- **RDS**: CPU, Connections, Latency
- **Application**: Errors, Requests, Response Time

**Alarmas Configuradas**
- **EC2 CPU > 80%**: Notificación de alta utilización
- **RDS CPU > 80%**: Alerta de base de datos
- **Instance Status**: Check de disponibilidad
- **DB Connections > 15**: Alerta de conexiones

**Logs Centralizados**
- **Application Logs**: /aws/ec2/gym-management-dev
- **System Logs**: Integrados con CloudWatch Agent
- **Access Logs**: S3 access logging

**Dashboard**
- **Métricas en tiempo real**: CPU, Memory, Network
- **Application Metrics**: Errores, requests, tiempo de respuesta
- **Database Metrics**: Conexiones, latencia, throughput

### 6. Seguridad (IAM)

**Roles Configurados**
- **EC2 Instance Role**: Acceso a S3 y CloudWatch
- **Application Role**: Permisos mínimos necesarios

**Políticas de Seguridad**
- **S3 Access**: Read/Write solo en bucket de aplicación
- **CloudWatch**: Envío de métricas y logs
- **Parameter Store**: Acceso a configuraciones seguras

**Security Groups**
- **Application SG**: Puertos 22, 80, 443, 8080
- **Database SG**: Puerto 3306 solo desde Application SG
- **Principle of Least Privilege**: Aplicado en todos los componentes

## 📊 Métricas de Rendimiento

### Capacidades Actuales
- **Concurrent Users**: ~50-100 usuarios
- **Request Throughput**: ~1000 requests/min
- **Database Connections**: Max 20 concurrent
- **Storage**: 20GB database + 5GB S3 (Free Tier)

### Limites de Free Tier
- **EC2**: 750 horas/mes t2.micro
- **RDS**: 750 horas/mes db.t3.micro
- **S3**: 5GB storage + 20,000 GET + 2,000 PUT
- **CloudWatch**: 10 métricas custom + logs básicos

## 🔄 Escalabilidad Futura

### Fase de Crecimiento
1. **Load Balancer**: Application Load Balancer en subnet pública
2. **Auto Scaling**: Auto Scaling Group para EC2 instances
3. **Multi-AZ RDS**: Habilitar Multi-AZ para alta disponibilidad
4. **ElastiCache**: Redis para cache de sesiones
5. **CloudFront**: CDN para contenido estático

### Optimizaciones de Costos
1. **Reserved Instances**: Para cargas de trabajo predecibles
2. **Spot Instances**: Para tareas de procesamiento batch
3. **S3 Intelligent Tiering**: Optimización automática de costos
4. **CloudWatch Retention**: Configurar retención apropiada

## 🛡️ Consideraciones de Seguridad

### Implementadas
- **Encryption in Transit**: HTTPS/TLS para todas las comunicaciones
- **Encryption at Rest**: RDS y S3 encriptados
- **Network Isolation**: Subnets privadas para base de datos
- **Access Control**: IAM roles con permisos mínimos

### Recomendadas para Producción
- **WAF**: Web Application Firewall
- **VPN/DirectConnect**: Conexión segura para administración
- **Secrets Manager**: Gestión de credenciales
- **GuardDuty**: Detección de amenazas
- **Config**: Compliance y auditoria

## 📈 Monitoring y Alertas

### Dashboards Principales
1. **Application Health**: Estado general de la aplicación
2. **Infrastructure Metrics**: CPU, Memory, Network, Storage
3. **Database Performance**: Connections, Queries, Latency
4. **Business Metrics**: Usuarios activos, transacciones

### Alertas Críticas
1. **Application Down**: Instance status check failed
2. **High Error Rate**: Application errors > 5%
3. **Database Issues**: High CPU o connection limit
4. **Storage Space**: Disk usage > 85%

## 🔧 Deployment y Maintenance

### Proceso de Deployment
1. **Build**: Maven build del JAR
2. **Upload**: SCP del JAR a EC2
3. **Deploy**: Restart del servicio systemd
4. **Health Check**: Verificación de endpoints

### Backup Strategy
- **Database**: Automated backups cada 24h (7 días retención)
- **Application Files**: Versionado en S3
- **Configuration**: Backup en repository Git
- **Disaster Recovery**: Manual restore procedures documented

### Maintenance Windows
- **Preferred**: Domingos 04:00-05:00 UTC
- **Database Maintenance**: Configured en RDS
- **OS Updates**: Automatic security patches
- **Application Updates**: Manual deployment process 