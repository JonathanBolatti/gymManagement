#!/bin/bash

# Script para conectar por SSH a la instancia EC2

if [ ! -f "gym-management-dev-keypair.pem" ]; then
    echo "❌ Archivo de clave gym-management-dev-keypair.pem no encontrado"
    exit 1
fi

echo "🔗 Conectando a la instancia EC2..."
echo "IP: 35.153.177.255"
echo "Usuario: ec2-user"

ssh -i gym-management-dev-keypair.pem ec2-user@35.153.177.255
