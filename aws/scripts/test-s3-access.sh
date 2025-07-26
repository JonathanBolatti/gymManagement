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
