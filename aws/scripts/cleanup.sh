#!/bin/bash

# Script para limpiar recursos AWS del Gym Management System
# ⚠️  CUIDADO: Este script eliminará TODOS los recursos creados
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

echo -e "${RED}🗑️  CLEANUP - Eliminando recursos AWS para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
echo -e "${RED}⚠️  ADVERTENCIA: Esta acción eliminará TODOS los recursos AWS⚠️${NC}"
echo "==============================================="

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Confirmación del usuario
echo -e "${YELLOW}Esta acción eliminará:${NC}"
echo "• Instancia EC2"
echo "• Base de datos RDS"
echo "• Buckets S3 y su contenido"
echo "• VPC y recursos de red"
echo "• Roles y políticas IAM"
echo "• Logs y métricas de CloudWatch"
echo ""
read -p "¿Estás seguro de que quieres continuar? (escribe 'DELETE' para confirmar): " confirmation

if [ "$confirmation" != "DELETE" ]; then
    echo "Operación cancelada."
    exit 0
fi

# Verificar que AWS CLI está configurado
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    error "AWS CLI no está configurado correctamente."
    exit 1
fi

# Cargar configuración si existe
INFRASTRUCTURE_FILE="aws-infrastructure-ids.txt"
if [ -f "$INFRASTRUCTURE_FILE" ]; then
    log "Cargando configuración de infraestructura..."
    source $INFRASTRUCTURE_FILE
else
    warning "Archivo de configuración no encontrado. Intentando cleanup por nombre..."
fi

echo ""
log "Iniciando proceso de cleanup..."

# 1. Eliminar alarmas de CloudWatch
log "Eliminando alarmas de CloudWatch..."
ALARMS=$(aws cloudwatch describe-alarms --alarm-names \
    "${PROJECT_NAME}-${ENVIRONMENT}-high-cpu" \
    "${PROJECT_NAME}-${ENVIRONMENT}-instance-status" \
    "${PROJECT_NAME}-${ENVIRONMENT}-db-high-cpu" \
    "${PROJECT_NAME}-${ENVIRONMENT}-db-connections" \
    --query 'MetricAlarms[].AlarmName' --output text --region $AWS_REGION 2>/dev/null || true)

if [ ! -z "$ALARMS" ]; then
    aws cloudwatch delete-alarms --alarm-names $ALARMS --region $AWS_REGION
    log "Alarmas eliminadas"
else
    warning "No se encontraron alarmas para eliminar"
fi

# 2. Eliminar dashboard
log "Eliminando dashboard de CloudWatch..."
DASHBOARD_NAME="${PROJECT_NAME}-${ENVIRONMENT}-dashboard"
aws cloudwatch delete-dashboards --dashboard-names $DASHBOARD_NAME --region $AWS_REGION 2>/dev/null || warning "Dashboard no encontrado"

# 3. Eliminar filtros de métricas y log streams
log "Eliminando filtros de métricas..."
LOG_GROUP_NAME="/aws/ec2/${PROJECT_NAME}-${ENVIRONMENT}"

# Eliminar filtros de métricas
aws logs delete-metric-filter \
    --log-group-name "$LOG_GROUP_NAME" \
    --filter-name "${PROJECT_NAME}-${ENVIRONMENT}-error-filter" \
    --region $AWS_REGION 2>/dev/null || true

aws logs delete-metric-filter \
    --log-group-name "$LOG_GROUP_NAME" \
    --filter-name "${PROJECT_NAME}-${ENVIRONMENT}-request-filter" \
    --region $AWS_REGION 2>/dev/null || true

# Eliminar log group
aws logs delete-log-group --log-group-name "$LOG_GROUP_NAME" --region $AWS_REGION 2>/dev/null || warning "Log group no encontrado"
log "Recursos de CloudWatch eliminados"

# 4. Terminar instancia EC2
if [ ! -z "$INSTANCE_ID" ]; then
    log "Terminando instancia EC2: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $AWS_REGION
    
    log "Esperando que la instancia se termine..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $AWS_REGION
    log "Instancia EC2 terminada"
else
    # Buscar instancias por tags
    log "Buscando instancias EC2 por tags..."
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=$PROJECT_NAME" \
                  "Name=tag:Environment,Values=$ENVIRONMENT" \
                  "Name=instance-state-name,Values=running,stopped,pending" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text --region $AWS_REGION)
    
    if [ ! -z "$INSTANCES" ]; then
        log "Terminando instancias: $INSTANCES"
        aws ec2 terminate-instances --instance-ids $INSTANCES --region $AWS_REGION
        for instance in $INSTANCES; do
            aws ec2 wait instance-terminated --instance-ids $instance --region $AWS_REGION
        done
        log "Instancias EC2 terminadas"
    else
        warning "No se encontraron instancias EC2"
    fi
fi

# 5. Eliminar Key Pair
KEY_PAIR_NAME="${PROJECT_NAME}-${ENVIRONMENT}-keypair"
log "Eliminando Key Pair: $KEY_PAIR_NAME"
aws ec2 delete-key-pair --key-name $KEY_PAIR_NAME --region $AWS_REGION 2>/dev/null || warning "Key Pair no encontrado"

# 6. Eliminar instance profile y rol IAM
IAM_ROLE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-ec2-role"
IAM_INSTANCE_PROFILE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-ec2-profile"

log "Eliminando instance profile y rol IAM..."

# Eliminar rol del instance profile
aws iam remove-role-from-instance-profile \
    --instance-profile-name $IAM_INSTANCE_PROFILE_NAME \
    --role-name $IAM_ROLE_NAME --region $AWS_REGION 2>/dev/null || true

# Eliminar instance profile
aws iam delete-instance-profile \
    --instance-profile-name $IAM_INSTANCE_PROFILE_NAME --region $AWS_REGION 2>/dev/null || warning "Instance profile no encontrado"

# Desasociar políticas del rol
aws iam detach-role-policy \
    --role-name $IAM_ROLE_NAME \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy --region $AWS_REGION 2>/dev/null || true

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IAM_POLICY_NAME="${PROJECT_NAME}-${ENVIRONMENT}-s3-policy"
aws iam detach-role-policy \
    --role-name $IAM_ROLE_NAME \
    --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${IAM_POLICY_NAME}" --region $AWS_REGION 2>/dev/null || true

# Eliminar rol
aws iam delete-role --role-name $IAM_ROLE_NAME --region $AWS_REGION 2>/dev/null || warning "Rol IAM no encontrado"

# 7. Eliminar base de datos RDS
if [ ! -z "$DB_INSTANCE_IDENTIFIER" ]; then
    log "Eliminando instancia RDS: $DB_INSTANCE_IDENTIFIER"
    
    # Deshabilitar deletion protection
    aws rds modify-db-instance \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --no-deletion-protection \
        --apply-immediately \
        --region $AWS_REGION 2>/dev/null || true
    
    # Eliminar instancia (sin snapshot final para cleanup)
    aws rds delete-db-instance \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --skip-final-snapshot \
        --delete-automated-backups \
        --region $AWS_REGION
    
    log "Esperando que la instancia RDS se elimine..."
    aws rds wait db-instance-deleted \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --region $AWS_REGION
    
    log "Instancia RDS eliminada"
else
    warning "ID de instancia RDS no encontrado"
fi

# 8. Eliminar DB subnet group y parameter group
DB_SUBNET_GROUP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-db-subnet-group"
DB_PARAMETER_GROUP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-mysql80"

log "Eliminando DB subnet group y parameter group..."
aws rds delete-db-subnet-group \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME --region $AWS_REGION 2>/dev/null || warning "DB subnet group no encontrado"

aws rds delete-db-parameter-group \
    --db-parameter-group-name $DB_PARAMETER_GROUP_NAME --region $AWS_REGION 2>/dev/null || warning "DB parameter group no encontrado"

# 9. Eliminar buckets S3 y su contenido
log "Eliminando buckets S3..."

# Buscar buckets por tags si no tenemos los nombres
if [ -z "$S3_BUCKET_NAME" ]; then
    S3_BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
    for bucket in $S3_BUCKETS; do
        TAGS=$(aws s3api get-bucket-tagging --bucket $bucket --region $AWS_REGION 2>/dev/null || echo "")
        if echo "$TAGS" | grep -q "$PROJECT_NAME" && echo "$TAGS" | grep -q "$ENVIRONMENT"; then
            log "Eliminando contenido del bucket: $bucket"
            aws s3 rm s3://$bucket --recursive --region $AWS_REGION
            aws s3api delete-bucket --bucket $bucket --region $AWS_REGION
            log "Bucket eliminado: $bucket"
        fi
    done
else
    # Eliminar buckets conocidos
    for bucket in "$S3_BUCKET_NAME" "$S3_LOGS_BUCKET_NAME"; do
        if [ ! -z "$bucket" ]; then
            log "Eliminando contenido del bucket: $bucket"
            aws s3 rm s3://$bucket --recursive --region $AWS_REGION 2>/dev/null || true
            aws s3api delete-bucket --bucket $bucket --region $AWS_REGION 2>/dev/null || warning "Bucket $bucket no encontrado"
        fi
    done
fi

# 10. Eliminar política IAM de S3
log "Eliminando política IAM de S3..."
aws iam delete-policy \
    --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${IAM_POLICY_NAME}" --region $AWS_REGION 2>/dev/null || warning "Política S3 no encontrada"

# 11. Eliminar Security Groups
log "Eliminando Security Groups..."
if [ ! -z "$APP_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $APP_SG_ID --region $AWS_REGION 2>/dev/null || warning "Security Group App no encontrado"
fi

if [ ! -z "$DB_SG_ID" ]; then
    aws ec2 delete-security-group --group-id $DB_SG_ID --region $AWS_REGION 2>/dev/null || warning "Security Group DB no encontrado"
fi

# 12. Eliminar VPC y recursos de red
log "Eliminando recursos de VPC..."

if [ ! -z "$VPC_ID" ]; then
    # Eliminar route table associations y routes
    if [ ! -z "$PUBLIC_ROUTE_TABLE_ID" ]; then
        # Desasociar subnets
        aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --route-table-ids $PUBLIC_ROUTE_TABLE_ID --query 'RouteTables[0].Associations[?Main==`false`].RouteTableAssociationId' --output text --region $AWS_REGION) --region $AWS_REGION 2>/dev/null || true
        
        # Eliminar rutas
        aws ec2 delete-route --route-table-id $PUBLIC_ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --region $AWS_REGION 2>/dev/null || true
        
        # Eliminar route table
        aws ec2 delete-route-table --route-table-id $PUBLIC_ROUTE_TABLE_ID --region $AWS_REGION 2>/dev/null || warning "Route table no encontrado"
    fi
    
    # Eliminar subnets
    for subnet in "$PUBLIC_SUBNET_1_ID" "$PUBLIC_SUBNET_2_ID" "$PRIVATE_SUBNET_1_ID" "$PRIVATE_SUBNET_2_ID"; do
        if [ ! -z "$subnet" ]; then
            aws ec2 delete-subnet --subnet-id $subnet --region $AWS_REGION 2>/dev/null || warning "Subnet $subnet no encontrado"
        fi
    done
    
    # Detach y eliminar Internet Gateway
    if [ ! -z "$IGW_ID" ]; then
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $AWS_REGION 2>/dev/null || true
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $AWS_REGION 2>/dev/null || warning "Internet Gateway no encontrado"
    fi
    
    # Eliminar VPC
    aws ec2 delete-vpc --vpc-id $VPC_ID --region $AWS_REGION 2>/dev/null || warning "VPC no encontrado"
    log "Recursos de VPC eliminados"
else
    warning "ID de VPC no encontrado"
fi

# 13. Limpiar archivos locales
log "Limpiando archivos locales..."
rm -f aws-infrastructure-ids.txt
rm -f database-config.txt
rm -f s3-config.txt
rm -f ec2-config.txt
rm -f monitoring-config.txt
rm -f cloudwatch-agent-config.json
rm -f test-*.sh
rm -f connect-ec2.sh
rm -f deploy-app.sh
rm -f setup-cloudwatch-agent.sh
rm -f ${PROJECT_NAME}-${ENVIRONMENT}-keypair.pem

echo ""
echo -e "${GREEN}✅ Cleanup completado exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Recursos eliminados:${NC}"
echo "• Instancias EC2 terminadas"
echo "• Base de datos RDS eliminada"
echo "• Buckets S3 eliminados"
echo "• VPC y recursos de red eliminados"
echo "• Roles y políticas IAM eliminados"
echo "• Recursos de CloudWatch eliminados"
echo "• Archivos locales limpiados"
echo ""
echo -e "${YELLOW}Nota:${NC} Algunos recursos pueden tardar unos minutos en eliminarse completamente."
echo -e "${YELLOW}Verifica en la consola de AWS que todos los recursos han sido eliminados.${NC}"
echo "===============================================" 