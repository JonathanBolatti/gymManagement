#!/bin/bash

# Script para gestionar la base de datos MySQL de desarrollo

set -e

COMPOSE_FILE="docker-compose.yml"

# Función para mostrar ayuda
show_help() {
    echo "🏋️‍♂️ Gym Management - Base de Datos de Desarrollo"
    echo ""
    echo "Uso: ./dev-db.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start    - Iniciar MySQL + PhpMyAdmin"
    echo "  stop     - Parar servicios (mantiene datos)"
    echo "  restart  - Reiniciar servicios"
    echo "  reset    - Eliminar todos los datos y reiniciar"
    echo "  logs     - Ver logs de MySQL"
    echo "  status   - Ver estado de los servicios"
    echo "  connect  - Conectar a MySQL via CLI"
    echo "  backup   - Crear backup de la base de datos"
    echo "  help     - Mostrar esta ayuda"
    echo ""
    echo "URLs disponibles cuando está corriendo:"
    echo "  📊 PhpMyAdmin: http://localhost:8081"
    echo "  🗄️  MySQL:     localhost:3306"
    echo ""
}

# Función para verificar si Docker está corriendo
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Error: Docker no está corriendo. Por favor inicia Docker Desktop."
        exit 1
    fi
}

# Función para iniciar servicios
start_services() {
    echo "🚀 Iniciando MySQL + PhpMyAdmin..."
    docker-compose up -d
    echo ""
    echo "⏳ Esperando que MySQL esté listo..."
    sleep 10
    
    # Verificar que MySQL esté saludable
    if docker-compose ps mysql-dev | grep -q "healthy"; then
        echo "✅ MySQL está listo!"
        echo "📊 PhpMyAdmin: http://localhost:8081"
        echo "🗄️  Base de datos: localhost:3306/gym_management"
        echo ""
        echo "Credenciales:"
        echo "  Usuario: gymuser"
        echo "  Password: gympass"
        echo "  Root password: rootpass"
    else
        echo "⚠️  MySQL aún se está iniciando. Verifica con: ./dev-db.sh logs"
    fi
}

# Función para parar servicios
stop_services() {
    echo "🛑 Parando servicios..."
    docker-compose stop
    echo "✅ Servicios parados (datos conservados)"
}

# Función para reiniciar servicios
restart_services() {
    echo "🔄 Reiniciando servicios..."
    docker-compose restart
    echo "✅ Servicios reiniciados"
}

# Función para resetear datos
reset_data() {
    echo "⚠️  Esta acción eliminará TODOS los datos de la base de datos."
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Eliminando datos y contenedores..."
        docker-compose down -v
        echo "🚀 Iniciando servicios limpios..."
        start_services
    else
        echo "❌ Operación cancelada"
    fi
}

# Función para ver logs
show_logs() {
    echo "📋 Logs de MySQL (Ctrl+C para salir):"
    docker-compose logs -f mysql-dev
}

# Función para ver estado
show_status() {
    echo "📊 Estado de los servicios:"
    docker-compose ps
}

# Función para conectar a MySQL
connect_mysql() {
    echo "🔌 Conectando a MySQL..."
    echo "Password: rootpass"
    docker-compose exec mysql-dev mysql -u root -p gym_management
}

# Función para backup
create_backup() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    echo "💾 Creando backup: $BACKUP_FILE"
    docker-compose exec mysql-dev mysqldump -u root -prootpass gym_management > "$BACKUP_FILE"
    echo "✅ Backup creado: $BACKUP_FILE"
}

# Main script
case "$1" in
    start)
        check_docker
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        check_docker
        restart_services
        ;;
    reset)
        check_docker
        reset_data
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    connect)
        connect_mysql
        ;;
    backup)
        create_backup
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo "❌ Comando desconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 