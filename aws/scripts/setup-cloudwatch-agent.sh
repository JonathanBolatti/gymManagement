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
