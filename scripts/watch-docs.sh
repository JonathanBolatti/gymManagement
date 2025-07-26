#!/bin/bash

# 👀 Script de vigilancia automática para JavaDoc
# Regenera documentación automáticamente cuando detecta cambios en archivos .java

echo "👀 Gym Management System - Vigilancia Automática de Documentación"
echo "================================================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[WATCH]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[REGENERATED]${NC} $1"
}

# Verificar que fswatch esté instalado (para macOS)
if ! command -v fswatch &> /dev/null; then
    echo -e "${YELLOW}[WARNING]${NC} fswatch no está instalado."
    echo "Para instalar en macOS: brew install fswatch"
    echo "Para instalar en Linux: sudo apt-get install inotify-tools"
    echo ""
    echo "Usando modo polling como alternativa..."
    
    # Modo polling alternativo
    LAST_CHANGE=$(find src/main/java -name "*.java" -exec stat -f "%m" {} \; | sort -n | tail -1)
    
    log_info "Iniciando vigilancia en modo polling..."
    log_info "Presiona Ctrl+C para detener"
    
    while true; do
        CURRENT_CHANGE=$(find src/main/java -name "*.java" -exec stat -f "%m" {} \; | sort -n | tail -1)
        
        if [ "$CURRENT_CHANGE" != "$LAST_CHANGE" ]; then
            log_info "Cambios detectados en archivos Java..."
            ./scripts/generate-docs.sh > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                log_success "Documentación actualizada automáticamente"
            fi
            LAST_CHANGE=$CURRENT_CHANGE
        fi
        
        sleep 3
    done
else
    # Modo fswatch (más eficiente)
    log_info "Iniciando vigilancia con fswatch..."
    log_info "Vigilando: src/main/java/**/*.java"
    log_info "Presiona Ctrl+C para detener"
    
    fswatch -o src/main/java --include='\.java$' | while read f; do
        log_info "Cambios detectados en archivos Java..."
        ./scripts/generate-docs.sh > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log_success "Documentación actualizada automáticamente ($(date '+%H:%M:%S'))"
        fi
    done
fi 