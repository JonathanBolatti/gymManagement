#!/bin/bash

# Script para configurar VPC y networking para Gym Management System
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
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_1_CIDR="10.0.1.0/24"
PUBLIC_SUBNET_2_CIDR="10.0.2.0/24"
PRIVATE_SUBNET_1_CIDR="10.0.3.0/24"
PRIVATE_SUBNET_2_CIDR="10.0.4.0/24"

echo -e "${BLUE}🏗️  Configurando VPC para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
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

log "Verificando región: $AWS_REGION"

# 1. Crear VPC
log "Creando VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --query 'Vpc.VpcId' \
    --output text \
    --region $AWS_REGION)

if [ $? -eq 0 ]; then
    log "VPC creada: $VPC_ID"
    aws ec2 create-tags \
        --resources $VPC_ID \
        --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-vpc" \
               Key=Environment,Value=$ENVIRONMENT \
               Key=Project,Value=$PROJECT_NAME \
        --region $AWS_REGION
else
    error "Error al crear VPC"
fi

# 2. Crear Internet Gateway
log "Creando Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text \
    --region $AWS_REGION)

log "Internet Gateway creado: $IGW_ID"
aws ec2 create-tags \
    --resources $IGW_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-igw" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
    --region $AWS_REGION

# 3. Attachar Internet Gateway al VPC
log "Attachando Internet Gateway al VPC..."
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID \
    --region $AWS_REGION

# 4. Obtener Availability Zones
AZ1=$(aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[0].ZoneName' \
    --output text \
    --region $AWS_REGION)
AZ2=$(aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[1].ZoneName' \
    --output text \
    --region $AWS_REGION)

log "Usando AZs: $AZ1, $AZ2"

# 5. Crear Subnets Públicas
log "Creando subnet pública 1..."
PUBLIC_SUBNET_1_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_SUBNET_1_CIDR \
    --availability-zone $AZ1 \
    --query 'Subnet.SubnetId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $PUBLIC_SUBNET_1_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-public-subnet-1" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
           Key=Type,Value=Public \
    --region $AWS_REGION

log "Creando subnet pública 2..."
PUBLIC_SUBNET_2_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_SUBNET_2_CIDR \
    --availability-zone $AZ2 \
    --query 'Subnet.SubnetId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $PUBLIC_SUBNET_2_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-public-subnet-2" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
           Key=Type,Value=Public \
    --region $AWS_REGION

# 6. Crear Subnets Privadas
log "Creando subnet privada 1..."
PRIVATE_SUBNET_1_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PRIVATE_SUBNET_1_CIDR \
    --availability-zone $AZ1 \
    --query 'Subnet.SubnetId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $PRIVATE_SUBNET_1_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-private-subnet-1" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
           Key=Type,Value=Private \
    --region $AWS_REGION

log "Creando subnet privada 2..."
PRIVATE_SUBNET_2_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PRIVATE_SUBNET_2_CIDR \
    --availability-zone $AZ2 \
    --query 'Subnet.SubnetId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $PRIVATE_SUBNET_2_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-private-subnet-2" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
           Key=Type,Value=Private \
    --region $AWS_REGION

# 7. Crear Route Table para subnets públicas
log "Creando route table pública..."
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $PUBLIC_ROUTE_TABLE_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-public-rt" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
    --region $AWS_REGION

# 8. Agregar ruta al Internet Gateway
log "Agregando ruta al Internet Gateway..."
aws ec2 create-route \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID \
    --region $AWS_REGION

# 9. Asociar subnets públicas con route table
log "Asociando subnets públicas con route table..."
aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_1_ID \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --region $AWS_REGION

aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_2_ID \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --region $AWS_REGION

# 10. Habilitar auto-assign IP pública para subnets públicas
log "Habilitando auto-assign IP pública..."
aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_1_ID \
    --map-public-ip-on-launch \
    --region $AWS_REGION

aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_2_ID \
    --map-public-ip-on-launch \
    --region $AWS_REGION

# 11. Crear Security Groups
log "Creando Security Group para aplicación..."
APP_SG_ID=$(aws ec2 create-security-group \
    --group-name "${PROJECT_NAME}-${ENVIRONMENT}-app-sg" \
    --description "Security group for application ${PROJECT_NAME}" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $APP_SG_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-app-sg" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
    --region $AWS_REGION

# Reglas para Security Group de aplicación
aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION

aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION

aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION

aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION

log "Creando Security Group para base de datos..."
DB_SG_ID=$(aws ec2 create-security-group \
    --group-name "${PROJECT_NAME}-${ENVIRONMENT}-db-sg" \
    --description "Security group for database ${PROJECT_NAME}" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text \
    --region $AWS_REGION)

aws ec2 create-tags \
    --resources $DB_SG_ID \
    --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-db-sg" \
           Key=Environment,Value=$ENVIRONMENT \
           Key=Project,Value=$PROJECT_NAME \
    --region $AWS_REGION

# Reglas para Security Group de base de datos (solo desde app SG)
aws ec2 authorize-security-group-ingress \
    --group-id $DB_SG_ID \
    --protocol tcp \
    --port 3306 \
    --source-group $APP_SG_ID \
    --region $AWS_REGION

# 12. Guardar IDs en archivo para usar en otros scripts
OUTPUT_FILE="aws-infrastructure-ids.txt"
log "Guardando IDs de infraestructura en $OUTPUT_FILE..."

cat > $OUTPUT_FILE << EOF
# AWS Infrastructure IDs for ${PROJECT_NAME}-${ENVIRONMENT}
# Generated on $(date)

VPC_ID=$VPC_ID
IGW_ID=$IGW_ID
PUBLIC_SUBNET_1_ID=$PUBLIC_SUBNET_1_ID
PUBLIC_SUBNET_2_ID=$PUBLIC_SUBNET_2_ID
PRIVATE_SUBNET_1_ID=$PRIVATE_SUBNET_1_ID
PRIVATE_SUBNET_2_ID=$PRIVATE_SUBNET_2_ID
PUBLIC_ROUTE_TABLE_ID=$PUBLIC_ROUTE_TABLE_ID
APP_SG_ID=$APP_SG_ID
DB_SG_ID=$DB_SG_ID
AWS_REGION=$AWS_REGION
ENVIRONMENT=$ENVIRONMENT
EOF

echo ""
echo -e "${GREEN}✅ VPC configurada exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Recursos creados:${NC}"
echo "• VPC: $VPC_ID"
echo "• Internet Gateway: $IGW_ID"
echo "• Subnet Pública 1: $PUBLIC_SUBNET_1_ID"
echo "• Subnet Pública 2: $PUBLIC_SUBNET_2_ID"
echo "• Subnet Privada 1: $PRIVATE_SUBNET_1_ID"
echo "• Subnet Privada 2: $PRIVATE_SUBNET_2_ID"
echo "• Security Group App: $APP_SG_ID"
echo "• Security Group DB: $DB_SG_ID"
echo ""
echo -e "${YELLOW}Próximo paso: Ejecutar ./02-setup-rds.sh${NC}"
echo "===============================================" 