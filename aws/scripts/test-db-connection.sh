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
