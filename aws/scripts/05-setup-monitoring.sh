#!/bin/bash

# Script para configurar CloudWatch para Gym Management System
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
CLOUDWATCH_NAMESPACE="${PROJECT_NAME}-${ENVIRONMENT}"
LOG_GROUP_NAME="/aws/ec2/${PROJECT_NAME}-${ENVIRONMENT}"

echo -e "${BLUE}📊 Configurando CloudWatch para ${PROJECT_NAME}-${ENVIRONMENT}${NC}"
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

log "Configurando CloudWatch en región: $AWS_REGION"

# 1. Crear Log Group para la aplicación
log "Creando Log Group: $LOG_GROUP_NAME"

if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" --region $AWS_REGION | grep -q "$LOG_GROUP_NAME"; then
    warning "Log Group $LOG_GROUP_NAME ya existe"
else
    aws logs create-log-group \
        --log-group-name "$LOG_GROUP_NAME" \
        --region $AWS_REGION
    
    log "Log Group creado: $LOG_GROUP_NAME"
    
    # Configurar retención de logs (30 días para Free Tier)
    aws logs put-retention-policy \
        --log-group-name "$LOG_GROUP_NAME" \
        --retention-in-days 30 \
        --region $AWS_REGION
fi

# 2. Crear Log Streams
log "Creando Log Streams..."

LOG_STREAMS=("application" "error" "access" "system")

for stream in "${LOG_STREAMS[@]}"; do
    STREAM_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${stream}"
    
    if aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --log-stream-name-prefix "$STREAM_NAME" --region $AWS_REGION | grep -q "$STREAM_NAME"; then
        warning "Log Stream $STREAM_NAME ya existe"
    else
        aws logs create-log-stream \
            --log-group-name "$LOG_GROUP_NAME" \
            --log-stream-name "$STREAM_NAME" \
            --region $AWS_REGION
        
        log "Log Stream creado: $STREAM_NAME"
    fi
done

# 3. Crear métricas personalizadas
log "Configurando métricas personalizadas..."

# Crear métrica para errores de aplicación
aws cloudwatch put-metric-data \
    --namespace "$CLOUDWATCH_NAMESPACE" \
    --metric-data MetricName=ApplicationErrors,Value=0,Unit=Count \
    --region $AWS_REGION

# Crear métrica para requests por minuto
aws cloudwatch put-metric-data \
    --namespace "$CLOUDWATCH_NAMESPACE" \
    --metric-data MetricName=RequestsPerMinute,Value=0,Unit=Count \
    --region $AWS_REGION

# Crear métrica para tiempo de respuesta
aws cloudwatch put-metric-data \
    --namespace "$CLOUDWATCH_NAMESPACE" \
    --metric-data MetricName=ResponseTime,Value=0,Unit=Milliseconds \
    --region $AWS_REGION

# 4. Crear alarmas para la instancia EC2
log "Creando alarmas de CloudWatch..."

if [ ! -z "$INSTANCE_ID" ]; then
    # Alarma de CPU alta
    CPU_ALARM_NAME="${PROJECT_NAME}-${ENVIRONMENT}-high-cpu"
    aws cloudwatch put-metric-alarm \
        --alarm-name "$CPU_ALARM_NAME" \
        --alarm-description "Alarma cuando CPU > 80%" \
        --metric-name CPUUtilization \
        --namespace AWS/EC2 \
        --statistic Average \
        --period 300 \
        --threshold 80 \
        --comparison-operator GreaterThanThreshold \
        --evaluation-periods 2 \
        --dimensions Name=InstanceId,Value=$INSTANCE_ID \
        --region $AWS_REGION
    
    log "Alarma de CPU creada: $CPU_ALARM_NAME"
    
    # Alarma de disponibilidad de instancia
    STATUS_ALARM_NAME="${PROJECT_NAME}-${ENVIRONMENT}-instance-status"
    aws cloudwatch put-metric-alarm \
        --alarm-name "$STATUS_ALARM_NAME" \
        --alarm-description "Alarma cuando la instancia falla status check" \
        --metric-name StatusCheckFailed \
        --namespace AWS/EC2 \
        --statistic Maximum \
        --period 60 \
        --threshold 0 \
        --comparison-operator GreaterThanThreshold \
        --evaluation-periods 2 \
        --dimensions Name=InstanceId,Value=$INSTANCE_ID \
        --region $AWS_REGION
    
    log "Alarma de status creada: $STATUS_ALARM_NAME"
fi

# 5. Crear alarmas para RDS si existe
if [ ! -z "$DB_INSTANCE_IDENTIFIER" ]; then
    log "Creando alarmas para RDS..."
    
    # Alarma de CPU de base de datos
    DB_CPU_ALARM_NAME="${PROJECT_NAME}-${ENVIRONMENT}-db-high-cpu"
    aws cloudwatch put-metric-alarm \
        --alarm-name "$DB_CPU_ALARM_NAME" \
        --alarm-description "Alarma cuando DB CPU > 80%" \
        --metric-name CPUUtilization \
        --namespace AWS/RDS \
        --statistic Average \
        --period 300 \
        --threshold 80 \
        --comparison-operator GreaterThanThreshold \
        --evaluation-periods 2 \
        --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_IDENTIFIER \
        --region $AWS_REGION
    
    log "Alarma de DB CPU creada: $DB_CPU_ALARM_NAME"
    
    # Alarma de conexiones de base de datos
    DB_CONN_ALARM_NAME="${PROJECT_NAME}-${ENVIRONMENT}-db-connections"
    aws cloudwatch put-metric-alarm \
        --alarm-name "$DB_CONN_ALARM_NAME" \
        --alarm-description "Alarma cuando DB connections > 15" \
        --metric-name DatabaseConnections \
        --namespace AWS/RDS \
        --statistic Average \
        --period 300 \
        --threshold 15 \
        --comparison-operator GreaterThanThreshold \
        --evaluation-periods 2 \
        --dimensions Name=DBInstanceIdentifier,Value=$DB_INSTANCE_IDENTIFIER \
        --region $AWS_REGION
    
    log "Alarma de DB connections creada: $DB_CONN_ALARM_NAME"
fi

# 6. Crear dashboard de CloudWatch
log "Creando dashboard de CloudWatch..."

DASHBOARD_NAME="${PROJECT_NAME}-${ENVIRONMENT}-dashboard"

# Crear configuración del dashboard
cat > dashboard-config.json << EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "$INSTANCE_ID" ],
                    [ ".", "NetworkIn", ".", "." ],
                    [ ".", "NetworkOut", ".", "." ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "$AWS_REGION",
                "title": "EC2 Instance Metrics"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "$DB_INSTANCE_IDENTIFIER" ],
                    [ ".", "DatabaseConnections", ".", "." ],
                    [ ".", "ReadLatency", ".", "." ],
                    [ ".", "WriteLatency", ".", "." ]
                ],
                "period": 300,
                "stat": "Average",
                "region": "$AWS_REGION",
                "title": "RDS Metrics"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 24,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "$CLOUDWATCH_NAMESPACE", "ApplicationErrors" ],
                    [ ".", "RequestsPerMinute" ],
                    [ ".", "ResponseTime" ]
                ],
                "period": 300,
                "stat": "Sum",
                "region": "$AWS_REGION",
                "title": "Application Metrics"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 12,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE '$LOG_GROUP_NAME'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 50",
                "region": "$AWS_REGION",
                "title": "Recent Application Logs"
            }
        }
    ]
}
EOF

aws cloudwatch put-dashboard \
    --dashboard-name "$DASHBOARD_NAME" \
    --dashboard-body file://dashboard-config.json \
    --region $AWS_REGION

rm dashboard-config.json

log "Dashboard creado: $DASHBOARD_NAME"

# 7. Configurar filtros de métricas para logs
log "Configurando filtros de métricas..."

# Filtro para errores
ERROR_FILTER_NAME="${PROJECT_NAME}-${ENVIRONMENT}-error-filter"
aws logs put-metric-filter \
    --log-group-name "$LOG_GROUP_NAME" \
    --filter-name "$ERROR_FILTER_NAME" \
    --filter-pattern "ERROR" \
    --metric-transformations \
        metricName=ApplicationErrors,metricNamespace=$CLOUDWATCH_NAMESPACE,metricValue=1 \
    --region $AWS_REGION

log "Filtro de errores creado: $ERROR_FILTER_NAME"

# Filtro para requests HTTP
REQUEST_FILTER_NAME="${PROJECT_NAME}-${ENVIRONMENT}-request-filter"
aws logs put-metric-filter \
    --log-group-name "$LOG_GROUP_NAME" \
    --filter-name "$REQUEST_FILTER_NAME" \
    --filter-pattern "[timestamp, request_id, ip, method, path, status_code, response_time]" \
    --metric-transformations \
        metricName=RequestsPerMinute,metricNamespace=$CLOUDWATCH_NAMESPACE,metricValue=1 \
    --region $AWS_REGION

log "Filtro de requests creado: $REQUEST_FILTER_NAME"

# 8. Crear configuración de CloudWatch Agent para la instancia EC2
log "Creando configuración de CloudWatch Agent..."

cat > cloudwatch-agent-config.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/home/gymapp/logs/application.log",
                        "log_group_name": "$LOG_GROUP_NAME",
                        "log_stream_name": "${PROJECT_NAME}-${ENVIRONMENT}-application",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "$LOG_GROUP_NAME",
                        "log_stream_name": "${PROJECT_NAME}-${ENVIRONMENT}-system",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "$CLOUDWATCH_NAMESPACE",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time",
                    "read_bytes",
                    "write_bytes",
                    "reads",
                    "writes"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# 9. Script para configurar CloudWatch Agent en EC2
SETUP_CW_SCRIPT="setup-cloudwatch-agent.sh"
cat > $SETUP_CW_SCRIPT << 'EOF'
#!/bin/bash

# Script para configurar CloudWatch Agent en la instancia EC2

# Cargar configuración
source ec2-config.txt

KEY_FILE="${KEY_PAIR_NAME}.pem"
CW_CONFIG_FILE="cloudwatch-agent-config.json"

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Archivo de clave no encontrado: $KEY_FILE"
    exit 1
fi

if [ ! -f "$CW_CONFIG_FILE" ]; then
    echo "❌ Archivo de configuración de CloudWatch no encontrado: $CW_CONFIG_FILE"
    exit 1
fi

echo "📊 Configurando CloudWatch Agent en EC2..."

# Subir configuración a la instancia
scp -i $KEY_FILE $CW_CONFIG_FILE ec2-user@$PUBLIC_IP:/tmp/

# Configurar CloudWatch Agent
ssh -i $KEY_FILE ec2-user@$PUBLIC_IP << 'REMOTE'
# Mover configuración al directorio correcto
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
sudo mv /tmp/cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/

# Iniciar CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent-config.json \
    -s

# Verificar status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -m ec2 \
    -a query-config

echo "✅ CloudWatch Agent configurado"
REMOTE

echo "✅ CloudWatch Agent configurado exitosamente"
EOF

chmod +x $SETUP_CW_SCRIPT

# 10. Crear archivo de configuración de monitoreo
MONITORING_CONFIG_FILE="monitoring-config.txt"
log "Guardando configuración de monitoreo en $MONITORING_CONFIG_FILE..."

cat > $MONITORING_CONFIG_FILE << EOF
# CloudWatch Configuration for ${PROJECT_NAME}-${ENVIRONMENT}
# Generated on $(date)

CLOUDWATCH_NAMESPACE=$CLOUDWATCH_NAMESPACE
LOG_GROUP_NAME=$LOG_GROUP_NAME
DASHBOARD_NAME=$DASHBOARD_NAME

# Alarmas creadas
CPU_ALARM_NAME=$CPU_ALARM_NAME
STATUS_ALARM_NAME=$STATUS_ALARM_NAME
DB_CPU_ALARM_NAME=$DB_CPU_ALARM_NAME
DB_CONN_ALARM_NAME=$DB_CONN_ALARM_NAME

# URLs útiles
DASHBOARD_URL=https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#dashboards:name=${DASHBOARD_NAME}
LOGS_URL=https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#logsV2:log-groups/log-group/\$252Faws\$252Fec2\$252F${PROJECT_NAME}-${ENVIRONMENT}

# Variables de entorno para la aplicación
export CLOUDWATCH_NAMESPACE=$CLOUDWATCH_NAMESPACE
export CLOUDWATCH_METRICS_ENABLED=true
EOF

# 11. Crear script de prueba de métricas
TEST_METRICS_SCRIPT="test-metrics.sh"
cat > $TEST_METRICS_SCRIPT << 'EOF'
#!/bin/bash

# Script para probar envío de métricas a CloudWatch

# Cargar configuración
source monitoring-config.txt

echo "📊 Enviando métricas de prueba a CloudWatch..."

# Enviar métrica de prueba
aws cloudwatch put-metric-data \
    --namespace "$CLOUDWATCH_NAMESPACE" \
    --metric-data MetricName=TestMetric,Value=42,Unit=Count \
    --region $AWS_REGION

echo "✅ Métrica de prueba enviada"

# Listar métricas disponibles
echo "📋 Métricas disponibles en el namespace $CLOUDWATCH_NAMESPACE:"
aws cloudwatch list-metrics \
    --namespace "$CLOUDWATCH_NAMESPACE" \
    --region $AWS_REGION

echo "🌐 Dashboard URL: $DASHBOARD_URL"
echo "📋 Logs URL: $LOGS_URL"
EOF

chmod +x $TEST_METRICS_SCRIPT

# 12. Mostrar información de CloudWatch
echo ""
echo -e "${GREEN}✅ CloudWatch configurado exitosamente!${NC}"
echo "==============================================="
echo -e "${BLUE}Recursos creados:${NC}"
echo "• Log Group: $LOG_GROUP_NAME"
echo "• Dashboard: $DASHBOARD_NAME"
echo "• Namespace: $CLOUDWATCH_NAMESPACE"
echo "• Alarmas de EC2 y RDS configuradas"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo "• $MONITORING_CONFIG_FILE - Configuración de monitoreo"
echo "• $SETUP_CW_SCRIPT - Script para configurar CloudWatch Agent"
echo "• $TEST_METRICS_SCRIPT - Script de prueba de métricas"
echo "• cloudwatch-agent-config.json - Configuración del agente"
echo ""
echo -e "${BLUE}URLs importantes:${NC}"
echo "• Dashboard: https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#dashboards:name=${DASHBOARD_NAME}"
echo "• Logs: https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#logsV2:log-groups"
echo "• Métricas: https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#metricsV2:"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Ejecutar ./$SETUP_CW_SCRIPT para configurar el agente en EC2"
echo "2. Probar métricas con ./$TEST_METRICS_SCRIPT"
echo "3. Verificar dashboard y alarmas en la consola de AWS"
echo ""
echo -e "${GREEN}🎉 ¡Infraestructura AWS completamente configurada!${NC}"
echo "==============================================="

# Actualizar archivo de infraestructura con información de CloudWatch
cat >> $INFRASTRUCTURE_FILE << EOF

# CloudWatch Configuration
CLOUDWATCH_NAMESPACE=$CLOUDWATCH_NAMESPACE
LOG_GROUP_NAME=$LOG_GROUP_NAME
DASHBOARD_NAME=$DASHBOARD_NAME
EOF 