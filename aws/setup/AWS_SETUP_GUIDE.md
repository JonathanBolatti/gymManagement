# 🚀 Guía de Configuración AWS - Gym Management System

## 📋 Prerrequisitos

1. **Cuenta de AWS**: Crear cuenta gratuita en https://aws.amazon.com/
2. **Tarjeta de crédito**: Requerida para verificación (no se cobrará en Free Tier)
3. **AWS CLI**: Lo instalaremos en esta guía

## 🔐 Paso 1: Configurar Usuario IAM

### 1.1 Acceder a IAM Console
1. Inicia sesión en la **AWS Management Console**
2. Busca "IAM" en el buscador de servicios
3. Click en "IAM" (Identity and Access Management)

### 1.2 Crear Usuario para Scripts
1. En el panel izquierdo, click en **"Users"**
2. Click en **"Add users"**
3. **Username**: `gym-management-admin`
4. **Access type**: ✅ "Programmatic access" (esto genera Access Key)
5. Click **"Next: Permissions"**

### 1.3 Asignar Permisos
**Opción 1: Permisos Completos (más fácil, menos seguro)**
1. Click en **"Attach existing policies directly"**
2. Buscar y seleccionar: `AdministratorAccess`
3. Click **"Next: Tags"** → **"Next: Review"** → **"Create user"**

**Opción 2: Permisos Específicos (más seguro, recomendado)**
1. Click en **"Attach existing policies directly"**
2. Buscar y seleccionar estas políticas:
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonS3FullAccess`
   - `AmazonVPCFullAccess`
   - `CloudWatchFullAccess`
   - `IAMFullAccess`
3. Click **"Next: Tags"** → **"Next: Review"** → **"Create user"**

### 1.4 Guardar Credenciales
**🚨 IMPORTANTE: Esta es la ÚNICA vez que verás la Secret Access Key**

1. **Access Key ID**: `AKIA...` (ejemplo: AKIAIOSFODNN7EXAMPLE)
2. **Secret Access Key**: `wJalr...` (ejemplo: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY)

**💾 Guarda estas credenciales en un lugar seguro:**
```
Access Key ID: AKIA...
Secret Access Key: wJalr...
Region: us-east-1
```

## 🖥️ Paso 2: Instalar AWS CLI

### En Windows
```powershell
# Opción 1: Desde el sitio oficial
# Descargar desde: https://awscli.amazonaws.com/AWSCLIV2.msi

# Opción 2: Con Chocolatey (si lo tienes)
choco install awscli

# Opción 3: Con pip
pip install awscli
```

### En macOS
```bash
# Opción 1: Con Homebrew (recomendado)
brew install awscli

# Opción 2: Instalador oficial
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Opción 3: Con pip
pip3 install awscli
```

### En Linux
```bash
# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Amazon Linux 2 / CentOS / RHEL
sudo yum install aws-cli

# Con pip
pip3 install awscli
```

### Verificar Instalación
```bash
aws --version
# Debe mostrar algo como: aws-cli/2.x.x Python/3.x.x ...
```

## ⚙️ Paso 3: Configurar Credenciales

### 3.1 Configuración Básica
```bash
aws configure
```

**Te preguntará:**
```
AWS Access Key ID [None]: AKIA... # Tu Access Key ID
AWS Secret Access Key [None]: wJalr... # Tu Secret Access Key  
Default region name [None]: us-east-1
Default output format [None]: json
```

### 3.2 Verificar Configuración
```bash
# Verificar que las credenciales funcionan
aws sts get-caller-identity
```

**Debe mostrar algo como:**
```json
{
    "UserId": "AIDACK...",
    "Account": "123456789012", 
    "Arn": "arn:aws:iam::123456789012:user/gym-management-admin"
}
```

### 3.3 Configuración de Variables de Entorno (Alternativa)
```bash
# En lugar de aws configure, puedes usar variables de entorno
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=wJalr...
export AWS_DEFAULT_REGION=us-east-1
```

## 🚀 Paso 4: Ejecutar Scripts de Infraestructura

### 4.1 Navegar al Directorio
```bash
cd aws/scripts
```

### 4.2 Hacer Scripts Ejecutables (si no lo están)
```bash
# En macOS/Linux
chmod +x *.sh

# En Windows con Git Bash
chmod +x *.sh
```

### 4.3 Ejecutar Scripts en Orden
```bash
# 1. Configurar VPC y networking (5-10 minutos)
./01-setup-vpc.sh

# 2. Configurar base de datos RDS (10-15 minutos)
./02-setup-rds.sh

# 3. Configurar buckets S3 (2-3 minutos)
./03-setup-s3.sh

# 4. Configurar instancia EC2 (5-8 minutos)
./04-setup-ec2.sh

# 5. Configurar monitoreo CloudWatch (3-5 minutos)
./05-setup-monitoring.sh
```

### 4.4 Variables de Entorno Opcionales
```bash
# Puedes personalizar antes de ejecutar
export ENVIRONMENT=dev
export AWS_REGION=us-east-1
export DB_PASSWORD=miPasswordSegura123!
```

## 📊 Paso 5: Verificar Infraestructura

### 5.1 Verificar Recursos Creados
```bash
# Listar instancias EC2
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table

# Verificar RDS
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' --output table

# Verificar buckets S3
aws s3 ls

# Verificar VPC
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table
```

### 5.2 Conectar a la Instancia EC2
```bash
# El script de EC2 genera estos archivos:
# - gym-management-dev-keypair.pem (clave SSH)
# - connect-ec2.sh (script de conexión)

# Conectar por SSH
./connect-ec2.sh
```

## 🔍 Troubleshooting

### Error: "Unable to locate credentials"
```bash
# Verificar configuración
aws configure list

# Reconfigurar si es necesario
aws configure
```

### Error: "Access Denied"
- Verificar que el usuario IAM tiene los permisos necesarios
- Verificar que las credenciales son correctas

### Error: "Region not specified"
```bash
# Configurar región por defecto
aws configure set region us-east-1
```

### Error de permisos en scripts
```bash
# Dar permisos de ejecución
chmod +x aws/scripts/*.sh
```

## 💰 Monitoreo de Costos

### Configurar Alertas de Billing
1. Ir a **AWS Billing Console**
2. **Preferences** → Habilitar "Receive Billing Alerts"
3. **Budgets** → Crear budget de $5-10 USD

### Verificar Free Tier Usage
1. **AWS Billing Console** → **Free Tier**
2. Monitorear uso mensual de:
   - EC2: 750 horas
   - RDS: 750 horas  
   - S3: 5 GB

## 🗑️ Limpiar Recursos (cuando termines)

### Eliminar Todo
```bash
# CUIDADO: Esto elimina TODOS los recursos
./cleanup.sh
```

### Eliminar Solo Algunos Recursos
```bash
# Terminar instancia EC2
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Eliminar base de datos RDS
aws rds delete-db-instance --db-instance-identifier gym-management-dev-db --skip-final-snapshot
```

## 📞 Soporte

### Recursos Útiles
- **AWS Free Tier**: https://aws.amazon.com/free/
- **AWS CLI Documentation**: https://docs.aws.amazon.com/cli/
- **AWS Support**: https://aws.amazon.com/support/

### Costos Inesperados
Si ves costos inesperados:
1. Ir a **Cost Explorer** en AWS Console
2. Verificar **Free Tier Usage** 
3. Ejecutar `./cleanup.sh` para eliminar recursos

---

## ✅ Checklist Final

- [ ] Cuenta AWS creada
- [ ] Usuario IAM configurado con permisos
- [ ] AWS CLI instalado y configurado
- [ ] Credenciales verificadas con `aws sts get-caller-identity`
- [ ] Scripts ejecutados exitosamente
- [ ] Recursos verificados en AWS Console
- [ ] Alertas de billing configuradas 