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
