#!/bin/bash

# Script para configurar S3 para Gym Management System
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

# Configuración de S3
BUCKET_NAME="${S3_BUCKET_NAME:-${PROJECT_NAME}-${ENVIRONMENT}-bucket-$(date +%s)}"
LOGS_BUCKET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-logs-$(date +%s)"

echo -e "${BLUE}📦 Configurando S3 para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
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

# Cargar IDs de infraestructura si existe
INFRASTRUCTURE_FILE="aws-infrastructure-ids.txt"
if [ -f "$INFRASTRUCTURE_FILE" ]; then
    log "Cargando configuración de infraestructura..."
    source $INFRASTRUCTURE_FILE
fi

log "Configurando S3 en región: $AWS_REGION"

# 1. Crear bucket principal para archivos de la aplicación
log "Creando bucket principal: $BUCKET_NAME"

# Verificar si el bucket ya existe
if aws s3api head-bucket --bucket "$BUCKET_NAME" --region $AWS_REGION 2>/dev/null; then
    warning "Bucket $BUCKET_NAME ya existe"
else
    # Crear bucket con configuración específica para la región
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $AWS_REGION
    else
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $AWS_REGION \
            --create-bucket-configuration LocationConstraint=$AWS_REGION
    fi
    
    log "Bucket creado: $BUCKET_NAME"
    
    # Agregar tags al bucket
    aws s3api put-bucket-tagging \
        --bucket $BUCKET_NAME \
        --tagging 'TagSet=[
            {Key=Name,Value="'${PROJECT_NAME}'-'${ENVIRONMENT}'-bucket"},
            {Key=Environment,Value="'${ENVIRONMENT}'"},
            {Key=Project,Value="'${PROJECT_NAME}'"},
            {Key=Purpose,Value="Application Files"}
        ]' \
        --region $AWS_REGION
fi

# 2. Configurar versionado del bucket
log "Configurando versionado del bucket..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled \
    --region $AWS_REGION

# 3. Configurar encriptación del bucket
log "Configurando encriptación del bucket..."
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }' \
    --region $AWS_REGION

# 4. Configurar política de acceso público (bloquear acceso público por defecto)
log "Configurando bloqueo de acceso público..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }' \
    --region $AWS_REGION

# 5. Configurar lifecycle policy para optimizar costos
log "Configurando lifecycle policy..."
cat > s3-lifecycle-policy.json << EOF
{
    "Rules": [
        {
            "ID": "OptimizeCosts",
            "Status": "Enabled",
            "Filter": {},
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                }
            ],
            "NoncurrentVersionTransitions": [
                {
                    "NoncurrentDays": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "NoncurrentDays": 60,
                    "StorageClass": "GLACIER"
                }
            ],
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 365
            }
        }
    ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
    --bucket $BUCKET_NAME \
    --lifecycle-configuration file://s3-lifecycle-policy.json \
    --region $AWS_REGION

rm s3-lifecycle-policy.json

# 6. Crear bucket para logs
log "Creando bucket para logs: $LOGS_BUCKET_NAME"

if aws s3api head-bucket --bucket "$LOGS_BUCKET_NAME" --region $AWS_REGION 2>/dev/null; then
    warning "Bucket de logs $LOGS_BUCKET_NAME ya existe"
else
    # Crear bucket de logs
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket $LOGS_BUCKET_NAME \
            --region $AWS_REGION
    else
        aws s3api create-bucket \
            --bucket $LOGS_BUCKET_NAME \
            --region $AWS_REGION \
            --create-bucket-configuration LocationConstraint=$AWS_REGION
    fi
    
    log "Bucket de logs creado: $LOGS_BUCKET_NAME"
    
    # Agregar tags al bucket de logs
    aws s3api put-bucket-tagging \
        --bucket $LOGS_BUCKET_NAME \
        --tagging 'TagSet=[
            {Key=Name,Value="'${PROJECT_NAME}'-'${ENVIRONMENT}'-logs"},
            {Key=Environment,Value="'${ENVIRONMENT}'"},
            {Key=Project,Value="'${PROJECT_NAME}'"},
            {Key=Purpose,Value="Application Logs"}
        ]' \
        --region $AWS_REGION
fi

# 7. Configurar logging del bucket principal
log "Configurando logging del bucket principal..."
aws s3api put-bucket-logging \
    --bucket $BUCKET_NAME \
    --bucket-logging-status '{
        "LoggingEnabled": {
            "TargetBucket": "'$LOGS_BUCKET_NAME'",
            "TargetPrefix": "access-logs/"
        }
    }' \
    --region $AWS_REGION

# 8. Crear estructura de directorios en el bucket
log "Creando estructura de directorios..."

# Crear archivos temporales para establecer la estructura de directorios
echo "# Directorio para imágenes de miembros" > temp_members.txt
echo "# Directorio para documentos" > temp_documents.txt
echo "# Directorio para archivos temporales" > temp_temp.txt
echo "# Directorio para archivos de configuración" > temp_config.txt

aws s3 cp temp_members.txt s3://$BUCKET_NAME/members/README.txt --region $AWS_REGION
aws s3 cp temp_documents.txt s3://$BUCKET_NAME/documents/README.txt --region $AWS_REGION
aws s3 cp temp_temp.txt s3://$BUCKET_NAME/temp/README.txt --region $AWS_REGION
aws s3 cp temp_config.txt s3://$BUCKET_NAME/config/README.txt --region $AWS_REGION

# Limpiar archivos temporales
rm temp_*.txt

# 9. Crear política IAM para acceso al bucket (solo para aplicación)
log "Creando política IAM para acceso al bucket..."

IAM_POLICY_NAME="${PROJECT_NAME}-${ENVIRONMENT}-s3-policy"
cat > s3-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}"
            ]
        }
    ]
}
EOF

# Verificar si la política ya existe
if aws iam get-policy --policy-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$IAM_POLICY_NAME" --region $AWS_REGION 2>/dev/null; then
    warning "Política IAM $IAM_POLICY_NAME ya existe"
else
    aws iam create-policy \
        --policy-name $IAM_POLICY_NAME \
        --policy-document file://s3-policy.json \
        --description "Política para acceso a S3 desde ${PROJECT_NAME}" \
        --region $AWS_REGION
    
    log "Política IAM creada: $IAM_POLICY_NAME"
fi

rm s3-policy.json

# 10. Crear archivo de configuración S3
S3_CONFIG_FILE="s3-config.txt"
log "Guardando configuración S3 en $S3_CONFIG_FILE..."

cat > $S3_CONFIG_FILE << EOF
# S3 Configuration for ${PROJECT_NAME}-${ENVIRONMENT}
# Generated on $(date)

S3_BUCKET_NAME=$BUCKET_NAME
S3_LOGS_BUCKET_NAME=$LOGS_BUCKET_NAME
S3_REGION=$AWS_REGION
IAM_POLICY_NAME=$IAM_POLICY_NAME

# Variables de entorno para la aplicación
export S3_BUCKET_NAME=$BUCKET_NAME
export AWS_REGION=$AWS_REGION
export S3_URL_EXPIRATION=3600
EOF

# 11. Crear script de prueba para S3
TEST_S3_SCRIPT="test-s3-access.sh"
log "Creando script de prueba S3..."

cat > $TEST_S3_SCRIPT << 'EOF'
#!/bin/bash

# Script para probar acceso a S3

# Cargar configuración
source s3-config.txt

echo "🪣 Probando acceso a S3..."
echo "Bucket: $S3_BUCKET_NAME"
echo "Región: $S3_REGION"

# Crear archivo de prueba
echo "Archivo de prueba - $(date)" > test-file.txt

# Subir archivo de prueba
echo "Subiendo archivo de prueba..."
aws s3 cp test-file.txt s3://$S3_BUCKET_NAME/test/test-file.txt --region $S3_REGION

# Listar contenido del bucket
echo "Contenido del bucket:"
aws s3 ls s3://$S3_BUCKET_NAME/ --recursive --region $S3_REGION

# Descargar archivo de prueba
echo "Descargando archivo de prueba..."
aws s3 cp s3://$S3_BUCKET_NAME/test/test-file.txt downloaded-test-file.txt --region $S3_REGION

# Verificar contenido
if [ -f "downloaded-test-file.txt" ]; then
    echo "✅ Test exitoso! Contenido del archivo:"
    cat downloaded-test-file.txt
    rm downloaded-test-file.txt
else
    echo "❌ Error en el test"
fi

# Limpiar archivo de prueba
rm test-file.txt
aws s3 rm s3://$S3_BUCKET_NAME/test/test-file.txt --region $S3_REGION

echo "✅ Test de S3 completado"
EOF

chmod +x $TEST_S3_SCRIPT

# 12. Mostrar información de S3
echo ""
echo -e "${GREEN}✅ S3 configurado exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Buckets creados:${NC}"
echo "• Bucket principal: $BUCKET_NAME"
echo "• Bucket de logs: $LOGS_BUCKET_NAME"
echo "• Región: $AWS_REGION"
echo ""
echo -e "${BLUE}Características configuradas:${NC}"
echo "• Versionado habilitado"
echo "• Encriptación AES256"
echo "• Acceso público bloqueado"
echo "• Lifecycle policy configurada"
echo "• Logging habilitado"
echo ""
echo -e "${BLUE}Estructura de directorios:${NC}"
echo "• /members/ - Imágenes de miembros"
echo "• /documents/ - Documentos del sistema"
echo "• /temp/ - Archivos temporales"
echo "• /config/ - Archivos de configuración"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo "• $S3_CONFIG_FILE - Configuración de S3"
echo "• $TEST_S3_SCRIPT - Script de prueba"
echo ""
echo -e "${YELLOW}Variables de entorno para la aplicación:${NC}"
echo "export S3_BUCKET_NAME=$BUCKET_NAME"
echo "export AWS_REGION=$AWS_REGION"
echo ""
echo -e "${YELLOW}Próximo paso: Ejecutar ./04-setup-ec2.sh${NC}"
echo "==============================================="

# Actualizar archivo de infraestructura con información de S3
if [ -f "$INFRASTRUCTURE_FILE" ]; then
    cat >> $INFRASTRUCTURE_FILE << EOF

# S3 Configuration
S3_BUCKET_NAME=$BUCKET_NAME
S3_LOGS_BUCKET_NAME=$LOGS_BUCKET_NAME
IAM_POLICY_NAME=$IAM_POLICY_NAME
EOF
fi 