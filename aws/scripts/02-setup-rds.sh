#!/bin/bash

# Script para configurar RDS MySQL para Gym Management System
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

# Configuración de RDS
DB_INSTANCE_IDENTIFIER="${PROJECT_NAME}-${ENVIRONMENT}-db"
DB_NAME="gym_management"
DB_USERNAME="${DB_USERNAME:-gymuser}"
DB_PASSWORD="${DB_PASSWORD:-gympass123!}"
DB_INSTANCE_CLASS="db.t3.micro"  # Free Tier eligible
ALLOCATED_STORAGE=20  # GB, Free Tier eligible
ENGINE_VERSION="8.0.35"

echo -e "${BLUE}🗄️  Configurando RDS MySQL para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
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
if [ -z "$VPC_ID" ] || [ -z "$PRIVATE_SUBNET_1_ID" ] || [ -z "$PRIVATE_SUBNET_2_ID" ] || [ -z "$DB_SG_ID" ]; then
    error "Variables de infraestructura no encontradas. Ejecuta primero ./01-setup-vpc.sh"
fi

log "Usando VPC: $VPC_ID"
log "Usando Security Group: $DB_SG_ID"

# 1. Crear DB Subnet Group
log "Creando DB Subnet Group..."
DB_SUBNET_GROUP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-db-subnet-group"

# Verificar si ya existe
if aws rds describe-db-subnet-groups \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --region $AWS_REGION > /dev/null 2>&1; then
    warning "DB Subnet Group $DB_SUBNET_GROUP_NAME ya existe"
else
    aws rds create-db-subnet-group \
        --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
        --db-subnet-group-description "Subnet group para ${PROJECT_NAME} ${ENVIRONMENT}" \
        --subnet-ids $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_2_ID \
        --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-db-subnet-group" \
               Key=Environment,Value=$ENVIRONMENT \
               Key=Project,Value=$PROJECT_NAME \
        --region $AWS_REGION
    
    log "DB Subnet Group creado: $DB_SUBNET_GROUP_NAME"
fi

# 2. Crear Parameter Group (opcional, para configuraciones personalizadas)
log "Creando DB Parameter Group..."
DB_PARAMETER_GROUP_NAME="${PROJECT_NAME}-${ENVIRONMENT}-mysql80"

if aws rds describe-db-parameter-groups \
    --db-parameter-group-name $DB_PARAMETER_GROUP_NAME \
    --region $AWS_REGION > /dev/null 2>&1; then
    warning "DB Parameter Group $DB_PARAMETER_GROUP_NAME ya existe"
else
    aws rds create-db-parameter-group \
        --db-parameter-group-name $DB_PARAMETER_GROUP_NAME \
        --db-parameter-group-family mysql8.0 \
        --description "Parameter group para ${PROJECT_NAME} ${ENVIRONMENT}" \
        --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-mysql80" \
               Key=Environment,Value=$ENVIRONMENT \
               Key=Project,Value=$PROJECT_NAME \
        --region $AWS_REGION
    
    log "DB Parameter Group creado: $DB_PARAMETER_GROUP_NAME"
    
    # Configurar parámetros optimizados para Free Tier
    log "Configurando parámetros de base de datos..."
    aws rds modify-db-parameter-group \
        --db-parameter-group-name $DB_PARAMETER_GROUP_NAME \
        --parameters ParameterName=innodb_buffer_pool_size,ParameterValue=134217728,ApplyMethod=pending-reboot \
        --region $AWS_REGION
fi

# 3. Verificar si la instancia RDS ya existe
log "Verificando si la instancia RDS ya existe..."
if aws rds describe-db-instances \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --region $AWS_REGION > /dev/null 2>&1; then
    warning "La instancia RDS $DB_INSTANCE_IDENTIFIER ya existe"
    
    # Obtener endpoint de la instancia existente
    RDS_ENDPOINT=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --query 'DBInstances[0].Endpoint.Address' \
        --output text \
        --region $AWS_REGION)
    
    log "Endpoint existente: $RDS_ENDPOINT"
else
    # 4. Crear instancia RDS
    log "Creando instancia RDS MySQL..."
    log "⚠️  Esto puede tomar entre 10-15 minutos..."
    
    aws rds create-db-instance \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --db-instance-class $DB_INSTANCE_CLASS \
        --engine mysql \
        --engine-version $ENGINE_VERSION \
        --master-username $DB_USERNAME \
        --master-user-password $DB_PASSWORD \
        --allocated-storage $ALLOCATED_STORAGE \
        --storage-type gp2 \
        --storage-encrypted \
        --db-name $DB_NAME \
        --vpc-security-group-ids $DB_SG_ID \
        --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
        --db-parameter-group-name $DB_PARAMETER_GROUP_NAME \
        --backup-retention-period 7 \
        --preferred-backup-window "03:00-04:00" \
        --preferred-maintenance-window "sun:04:00-sun:05:00" \
        --auto-minor-version-upgrade \
        --publicly-accessible \
        --no-multi-az \
        --deletion-protection \
        --tags Key=Name,Value="${PROJECT_NAME}-${ENVIRONMENT}-db" \
               Key=Environment,Value=$ENVIRONMENT \
               Key=Project,Value=$PROJECT_NAME \
        --region $AWS_REGION
    
    log "Instancia RDS creada: $DB_INSTANCE_IDENTIFIER"
    log "Esperando que la instancia esté disponible..."
    
    # Esperar a que la instancia esté disponible
    aws rds wait db-instance-available \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --region $AWS_REGION
    
    log "✅ Instancia RDS disponible!"
    
    # Obtener endpoint de la nueva instancia
    RDS_ENDPOINT=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
        --query 'DBInstances[0].Endpoint.Address' \
        --output text \
        --region $AWS_REGION)
    
    log "Endpoint: $RDS_ENDPOINT"
fi

# 5. Crear archivo de configuración de base de datos
DB_CONFIG_FILE="database-config.txt"
log "Guardando configuración de base de datos en $DB_CONFIG_FILE..."

cat > $DB_CONFIG_FILE << EOF
# Database Configuration for ${PROJECT_NAME}-${ENVIRONMENT}
# Generated on $(date)

DB_INSTANCE_IDENTIFIER=$DB_INSTANCE_IDENTIFIER
RDS_ENDPOINT=$RDS_ENDPOINT
RDS_DB_NAME=$DB_NAME
RDS_USERNAME=$DB_USERNAME
RDS_PASSWORD=$DB_PASSWORD
DB_SG_ID=$DB_SG_ID
DB_SUBNET_GROUP_NAME=$DB_SUBNET_GROUP_NAME
DB_PARAMETER_GROUP_NAME=$DB_PARAMETER_GROUP_NAME

# Variables de entorno para la aplicación
export RDS_ENDPOINT=$RDS_ENDPOINT
export RDS_DB_NAME=$DB_NAME
export RDS_USERNAME=$DB_USERNAME
export RDS_PASSWORD=$DB_PASSWORD
EOF

# 6. Crear script de conexión de prueba
TEST_SCRIPT="test-db-connection.sh"
log "Creando script de prueba de conexión..."

cat > $TEST_SCRIPT << 'EOF'
#!/bin/bash

# Script para probar conexión a la base de datos
# Requiere mysql-client instalado

# Cargar configuración
source database-config.txt

echo "🔗 Probando conexión a la base de datos..."
echo "Endpoint: $RDS_ENDPOINT"
echo "Database: $RDS_DB_NAME"
echo "Username: $RDS_USERNAME"

# Comando de conexión (requiere mysql client)
echo ""
echo "Para conectar manualmente, usa:"
echo "mysql -h $RDS_ENDPOINT -u $RDS_USERNAME -p$RDS_PASSWORD $RDS_DB_NAME"
echo ""
echo "O para probar conexión:"
echo "mysql -h $RDS_ENDPOINT -u $RDS_USERNAME -p$RDS_PASSWORD -e 'SELECT VERSION();'"
EOF

chmod +x $TEST_SCRIPT

# 7. Mostrar información de conexión
echo ""
echo -e "${GREEN}✅ Base de datos RDS configurada exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Información de conexión:${NC}"
echo "• Endpoint: $RDS_ENDPOINT"
echo "• Database: $DB_NAME"
echo "• Username: $DB_USERNAME"
echo "• Password: $DB_PASSWORD"
echo "• Security Group: $DB_SG_ID"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo "• $DB_CONFIG_FILE - Configuración de base de datos"
echo "• $TEST_SCRIPT - Script de prueba de conexión"
echo ""
echo -e "${YELLOW}Variables de entorno para la aplicación:${NC}"
echo "export RDS_ENDPOINT=$RDS_ENDPOINT"
echo "export RDS_DB_NAME=$DB_NAME"
echo "export RDS_USERNAME=$DB_USERNAME"
echo "export RDS_PASSWORD=$DB_PASSWORD"
echo ""
echo -e "${YELLOW}Próximo paso: Ejecutar ./03-setup-s3.sh${NC}"
echo "==============================================="

# Actualizar archivo de infraestructura con información de RDS
cat >> $INFRASTRUCTURE_FILE << EOF

# Database Configuration
DB_INSTANCE_IDENTIFIER=$DB_INSTANCE_IDENTIFIER
RDS_ENDPOINT=$RDS_ENDPOINT
RDS_DB_NAME=$DB_NAME
RDS_USERNAME=$DB_USERNAME
DB_SG_ID=$DB_SG_ID
EOF 