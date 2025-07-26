#!/bin/bash

# Script para configurar EC2 para Gym Management System
# Autor: Equipo DevOps
# Fecha: $(date +%Y-%m-%d)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables de configuración
PROJECT_NAME="gym-management"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Configuración de EC2
INSTANCE_TYPE="t3.micro"  # Free Tier eligible
KEY_PAIR_NAME="${PROJECT_NAME}-${ENVIRONMENT}-keypair"
INSTANCE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-instance"

echo -e "${BLUE}🖥️  Configurando EC2 para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
echo "==============================================="

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Verificar que AWS CLI está configurado
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    error "AWS CLI no está configurado correctamente. Ejecuta 'aws configure' primero."
fi

# Cargar IDs de infraestructura
INFRASTRUCTURE_FILE="aws-infrastructure-ids.txt"
if [ ! -f "$INFRASTRUCTURE_FILE" ]; then
    error "Archivo $INFRASTRUCTURE_FILE no encontrado. Ejecuta primero ./01-setup-vpc.sh"
fi

log "Cargando configuración de infraestructura..."
source $INFRASTRUCTURE_FILE

# Verificar que las variables necesarias están definidas
if [ -z "$VPC_ID" ] || [ -z "$PUBLIC_SUBNET_1_ID" ] || [ -z "$APP_SG_ID" ]; then
    error "Variables de infraestructura no encontradas. Ejecuta primero ./01-setup-vpc.sh"
fi

log "Usando VPC: $VPC_ID"
log "Usando Subnet: $PUBLIC_SUBNET_1_ID"
log "Usando Security Group: $APP_SG_ID"

# 1. Crear Key Pair para acceso SSH
log "Configurando Key Pair..."

if aws ec2 describe-key-pairs --key-names $KEY_PAIR_NAME --region $AWS_REGION > /dev/null 2>&1; then
    warning "Key Pair $KEY_PAIR_NAME ya existe"
else
    log "Creando Key Pair: $KEY_PAIR_NAME"
    aws ec2 create-key-pair \
        --key-name $KEY_PAIR_NAME \
        --query 'KeyMaterial' \
        --output text \
        --region $AWS_REGION > ${KEY_PAIR_NAME}.pem
    
    chmod 400 ${KEY_PAIR_NAME}.pem
    log "Key Pair creado y guardado como ${KEY_PAIR_NAME}.pem"
fi

# 2. Obtener AMI ID (Amazon Linux 2)
log "Obteniendo AMI ID para Amazon Linux 2..."
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters 'Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2' \
              'Name=state,Values=available' \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text \
    --region $AWS_REGION)

log "Usando AMI: $AMI_ID"

# 3. Crear User Data script para configurar la instancia
log "Creando User Data script..."
cat > user-data.sh << 'EOF'
#!/bin/bash

# Script de inicialización para EC2
# Instala Java 17, MySQL client y configura la aplicación

# Actualizar sistema
yum update -y

# Instalar Java 17
yum install -y java-17-amazon-corretto-devel

# Instalar MySQL client
yum install -y mysql

# Instalar herramientas adicionales
yum install -y wget curl unzip htop

# Crear usuario para la aplicación
useradd -m -s /bin/bash gymapp
mkdir -p /home/gymapp/app
mkdir -p /home/gymapp/logs
chown -R gymapp:gymapp /home/gymapp

# Crear directorio para la aplicación
mkdir -p /opt/gym-management
chown -R gymapp:gymapp /opt/gym-management

# Crear script de inicio de la aplicación
cat > /opt/gym-management/start-app.sh << 'STARTSCRIPT'
#!/bin/bash

# Variables de entorno (serán configuradas después)
export SPRING_PROFILES_ACTIVE=aws
export SERVER_PORT=8080

# Configuración de JVM
export JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"

# Directorio de la aplicación
APP_DIR="/opt/gym-management"
APP_JAR="gym-management-system.jar"
LOG_FILE="/home/gymapp/logs/application.log"

cd $APP_DIR

# Verificar que el JAR existe
if [ ! -f "$APP_JAR" ]; then
    echo "ERROR: $APP_JAR no encontrado en $APP_DIR"
    exit 1
fi

# Iniciar aplicación
echo "Iniciando aplicación..."
java $JAVA_OPTS -jar $APP_JAR > $LOG_FILE 2>&1 &

# Guardar PID
echo $! > /var/run/gym-management.pid

echo "Aplicación iniciada con PID: $(cat /var/run/gym-management.pid)"
echo "Log file: $LOG_FILE"
STARTSCRIPT

chmod +x /opt/gym-management/start-app.sh
chown gymapp:gymapp /opt/gym-management/start-app.sh

# Crear script de parada
cat > /opt/gym-management/stop-app.sh << 'STOPSCRIPT'
#!/bin/bash

PID_FILE="/var/run/gym-management.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    echo "Deteniendo aplicación con PID: $PID"
    kill $PID
    rm $PID_FILE
    echo "Aplicación detenida"
else
    echo "Archivo PID no encontrado. La aplicación puede no estar ejecutándose."
fi
STOPSCRIPT

chmod +x /opt/gym-management/stop-app.sh
chown gymapp:gymapp /opt/gym-management/stop-app.sh

# Crear servicio systemd
cat > /etc/systemd/system/gym-management.service << 'SYSTEMDSERVICE'
[Unit]
Description=Gym Management System
After=network.target

[Service]
Type=forking
User=gymapp
Group=gymapp
WorkingDirectory=/opt/gym-management
ExecStart=/opt/gym-management/start-app.sh
ExecStop=/opt/gym-management/stop-app.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SYSTEMDSERVICE

# Habilitar servicio
systemctl daemon-reload
systemctl enable gym-management

# Instalar AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

# Configurar CloudWatch Agent (opcional)
yum install -y amazon-cloudwatch-agent

# Configurar logrotate para los logs de la aplicación
cat > /etc/logrotate.d/gym-management << 'LOGROTATE'
/home/gymapp/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
LOGROTATE

# Crear archivo de configuración para variables de entorno
cat > /opt/gym-management/app.env << 'APPENV'
# Variables de entorno para la aplicación
# Estas serán configuradas durante el deployment

SPRING_PROFILES_ACTIVE=aws
SERVER_PORT=8080

# Database (configurar después)
# RDS_ENDPOINT=
# RDS_DB_NAME=
# RDS_USERNAME=
# RDS_PASSWORD=

# AWS (configurar después)
# AWS_REGION=
# S3_BUCKET_NAME=

# Logging
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_GYM_MANAGEMENT=DEBUG
APPENV

chown gymapp:gymapp /opt/gym-management/app.env

# Configurar firewall básico
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --reload

echo "✅ Configuración inicial completada"
EOF

# 4. Crear rol IAM para EC2 (acceso a S3 y CloudWatch)
log "Creando rol IAM para EC2..."

IAM_ROLE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-ec2-role"
IAM_INSTANCE_PROFILE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-ec2-profile"

# Crear política de confianza
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

# Verificar si el rol ya existe
if aws iam get-role --role-name $IAM_ROLE_NAME --region $AWS_REGION > /dev/null 2>&1; then
    warning "Rol IAM $IAM_ROLE_NAME ya existe"
else
    # Crear rol IAM
    aws iam create-role \
        --role-name $IAM_ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json \
        --description "Rol para instancia EC2 de ${PROJECT_NAME}" \
        --region $AWS_REGION
    
    log "Rol IAM creado: $IAM_ROLE_NAME"
    
    # Adjuntar políticas necesarias
    aws iam attach-role-policy \
        --role-name $IAM_ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
        --region $AWS_REGION
    
    # Adjuntar política de S3 si existe
    if [ ! -z "$IAM_POLICY_NAME" ]; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        aws iam attach-role-policy \
            --role-name $IAM_ROLE_NAME \
            --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${IAM_POLICY_NAME}" \
            --region $AWS_REGION
    fi
fi

# Crear instance profile
if aws iam get-instance-profile --instance-profile-name $IAM_INSTANCE_PROFILE_NAME --region $AWS_REGION > /dev/null 2>&1; then
    warning "Instance profile $IAM_INSTANCE_PROFILE_NAME ya existe"
else
    aws iam create-instance-profile \
        --instance-profile-name $IAM_INSTANCE_PROFILE_NAME \
        --region $AWS_REGION
    
    aws iam add-role-to-instance-profile \
        --instance-profile-name $IAM_INSTANCE_PROFILE_NAME \
        --role-name $IAM_ROLE_NAME \
        --region $AWS_REGION
    
    log "Instance profile creado: $IAM_INSTANCE_PROFILE_NAME"
    
    # Esperar un poco para que el instance profile esté disponible
    sleep 10
fi

rm trust-policy.json

# 5. Lanzar instancia EC2
log "Lanzando instancia EC2..."

# Verificar si ya existe una instancia con el mismo nombre
EXISTING_INSTANCE=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
              "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text \
    --region $AWS_REGION)

if [ ! -z "$EXISTING_INSTANCE" ]; then
    warning "Ya existe una instancia con el nombre $INSTANCE_NAME: $EXISTING_INSTANCE"
    INSTANCE_ID=$EXISTING_INSTANCE
else
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_PAIR_NAME \
        --security-group-ids $APP_SG_ID \
        --subnet-id $PUBLIC_SUBNET_1_ID \
        --iam-instance-profile Name=$IAM_INSTANCE_PROFILE_NAME \
        --user-data file://user-data.sh \
        --tag-specifications 'ResourceType=instance,Tags=[
            {Key=Name,Value="'$INSTANCE_NAME'"},
            {Key=Environment,Value="'$ENVIRONMENT'"},
            {Key=Project,Value="'$PROJECT_NAME'"}
        ]' \
        --query 'Instances[0].InstanceId' \
        --output text \
        --region $AWS_REGION)
    
    log "Instancia EC2 lanzada: $INSTANCE_ID"
    log "Esperando que la instancia esté en running..."
    
    aws ec2 wait instance-running \
        --instance-ids $INSTANCE_ID \
        --region $AWS_REGION
    
    log "✅ Instancia EC2 en estado running"
fi

# 6. Obtener IP pública
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region $AWS_REGION)

log "IP pública: $PUBLIC_IP"

# Limpiar archivos temporales
rm user-data.sh

# 7. Crear archivos de configuración y scripts
EC2_CONFIG_FILE="ec2-config.txt"
log "Guardando configuración EC2 en $EC2_CONFIG_FILE..."

cat > $EC2_CONFIG_FILE << EOF
# EC2 Configuration for ${PROJECT_NAME}-${ENVIRONMENT}
# Generated on $(date)

INSTANCE_ID=$INSTANCE_ID
PUBLIC_IP=$PUBLIC_IP
PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text --region $AWS_REGION)
KEY_PAIR_NAME=$KEY_PAIR_NAME
AMI_ID=$AMI_ID
INSTANCE_TYPE=$INSTANCE_TYPE
IAM_ROLE_NAME=$IAM_ROLE_NAME
IAM_INSTANCE_PROFILE_NAME=$IAM_INSTANCE_PROFILE_NAME

# Comandos útiles
# SSH: ssh -i ${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP
# SCP: scp -i ${KEY_PAIR_NAME}.pem archivo.jar ec2-user@$PUBLIC_IP:/tmp/
EOF

# 8. Crear script de conexión SSH
SSH_SCRIPT="connect-ec2.sh"
cat > $SSH_SCRIPT << EOF
#!/bin/bash

# Script para conectar por SSH a la instancia EC2

if [ ! -f "${KEY_PAIR_NAME}.pem" ]; then
    echo "❌ Archivo de clave ${KEY_PAIR_NAME}.pem no encontrado"
    exit 1
fi

echo "🔗 Conectando a la instancia EC2..."
echo "IP: $PUBLIC_IP"
echo "Usuario: ec2-user"

ssh -i ${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP
EOF

chmod +x $SSH_SCRIPT

# 9. Crear script de deployment
DEPLOY_SCRIPT="deploy-app.sh"
cat > $DEPLOY_SCRIPT << 'EOF'
#!/bin/bash

# Script para desplegar la aplicación en EC2

# Cargar configuración
source ec2-config.txt

JAR_FILE="${1:-target/system-0.0.1-SNAPSHOT.jar}"
KEY_FILE="${KEY_PAIR_NAME}.pem"

if [ ! -f "$JAR_FILE" ]; then
    echo "❌ Archivo JAR no encontrado: $JAR_FILE"
    echo "Uso: $0 [ruta-al-jar]"
    exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Archivo de clave no encontrado: $KEY_FILE"
    exit 1
fi

echo "🚀 Desplegando aplicación en EC2..."
echo "JAR: $JAR_FILE"
echo "Instancia: $INSTANCE_ID ($PUBLIC_IP)"

# Subir JAR a la instancia
echo "📤 Subiendo JAR..."
scp -i $KEY_FILE $JAR_FILE ec2-user@$PUBLIC_IP:/tmp/

# Conectar y configurar
echo "⚙️  Configurando aplicación..."
ssh -i $KEY_FILE ec2-user@$PUBLIC_IP << 'REMOTE'
# Detener aplicación si está ejecutándose
sudo systemctl stop gym-management 2>/dev/null || true

# Mover JAR al directorio de la aplicación
sudo mv /tmp/system-0.0.1-SNAPSHOT.jar /opt/gym-management/gym-management-system.jar
sudo chown gymapp:gymapp /opt/gym-management/gym-management-system.jar

# Configurar variables de entorno (cargar desde archivos de configuración locales)
# Esto se debe personalizar con los valores reales

# Iniciar aplicación
sudo systemctl start gym-management
sudo systemctl status gym-management

echo "✅ Aplicación desplegada"
echo "🌐 URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
REMOTE

echo "✅ Deployment completado"
echo "🌐 Aplicación disponible en: http://$PUBLIC_IP:8080"
EOF

chmod +x $DEPLOY_SCRIPT

# 10. Mostrar información de la instancia
echo ""
echo -e "${GREEN}✅ EC2 configurado exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Información de la instancia:${NC}"
echo "• Instance ID: $INSTANCE_ID"
echo "• IP Pública: $PUBLIC_IP"
echo "• Tipo: $INSTANCE_TYPE"
echo "• AMI: $AMI_ID"
echo "• Key Pair: $KEY_PAIR_NAME"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo "• $EC2_CONFIG_FILE - Configuración de EC2"
echo "• $SSH_SCRIPT - Script de conexión SSH"
echo "• $DEPLOY_SCRIPT - Script de deployment"
echo "• ${KEY_PAIR_NAME}.pem - Clave privada SSH"
echo ""
echo -e "${BLUE}Comandos útiles:${NC}"
echo "• Conectar SSH: ./$SSH_SCRIPT"
echo "• Desplegar app: ./$DEPLOY_SCRIPT [jar-file]"
echo "• Ver logs: ssh -i ${KEY_PAIR_NAME}.pem ec2-user@$PUBLIC_IP 'tail -f /home/gymapp/logs/application.log'"
echo ""
echo -e "${YELLOW}⚠️  Importante:${NC}"
echo "• Guarda el archivo ${KEY_PAIR_NAME}.pem en un lugar seguro"
echo "• La instancia puede tardar unos minutos en estar completamente configurada"
echo "• Verifica el estado con: aws ec2 describe-instance-status --instance-ids $INSTANCE_ID"
echo ""
echo -e "${YELLOW}Próximo paso: Ejecutar ./05-setup-monitoring.sh${NC}"
echo "==============================================="

# Actualizar archivo de infraestructura con información de EC2
cat >> $INFRASTRUCTURE_FILE << EOF

# EC2 Configuration
INSTANCE_ID=$INSTANCE_ID
PUBLIC_IP=$PUBLIC_IP
KEY_PAIR_NAME=$KEY_PAIR_NAME
IAM_ROLE_NAME=$IAM_ROLE_NAME
IAM_INSTANCE_PROFILE_NAME=$IAM_INSTANCE_PROFILE_NAME
EOF 