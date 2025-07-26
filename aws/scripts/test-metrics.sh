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
