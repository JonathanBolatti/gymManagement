#!/bin/bash

# 🛠️ Utilidades rápidas para JavaDoc
# Comandos útiles para diferentes escenarios

COMMAND=$1

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo "🛠️ Utilidades de JavaDoc para Gym Management System"
    echo "=================================================="
    echo ""
    echo "📋 Comandos disponibles:"
    echo ""
    echo "  🚀 generate     - Regenerar documentación completa"
    echo "  👀 watch        - Modo vigilancia automática"
    echo "  📊 stats        - Mostrar estadísticas de cobertura"
    echo "  🔍 check        - Verificar calidad de JavaDoc"
    echo "  🧹 clean        - Limpiar archivos generados"
    echo "  🔗 setup-hooks  - Configurar Git hooks automáticos"
    echo "  🌐 serve        - Servidor web local para docs"
    echo "  📦 package      - Crear JAR con documentación"
    echo ""
    echo "💡 Ejemplos de uso:"
    echo "  ./scripts/docs-utils.sh generate"
    echo "  ./scripts/docs-utils.sh watch"
    echo "  ./scripts/docs-utils.sh stats"
}

generate_docs() {
    log_info "Generando documentación..."
    ./scripts/generate-docs.sh
}

watch_mode() {
    log_info "Iniciando modo vigilancia..."
    ./scripts/watch-docs.sh
}

show_stats() {
    log_info "Calculando estadísticas de JavaDoc..."
    
    # Contar archivos Java
    TOTAL_JAVA=$(find src/main/java -name "*.java" | wc -l | tr -d ' ')
    
    # Contar archivos con JavaDoc
    DOCUMENTED=$(grep -r "^\s*/\*\*" src/main/java --include="*.java" | cut -d: -f1 | sort -u | wc -l | tr -d ' ')
    
    # Contar clases públicas
    PUBLIC_CLASSES=$(grep -r "^public class\|^public interface\|^public enum" src/main/java --include="*.java" | wc -l | tr -d ' ')
    
    # Contar métodos públicos
    PUBLIC_METHODS=$(grep -r "^\s*public.*(" src/main/java --include="*.java" | grep -v "class\|interface" | wc -l | tr -d ' ')
    
    echo ""
    echo "📊 Estadísticas de Documentación"
    echo "================================"
    echo "📁 Total de archivos Java: $TOTAL_JAVA"
    echo "📝 Archivos con JavaDoc: $DOCUMENTED"
    echo "🏛️  Clases/Interfaces públicas: $PUBLIC_CLASSES"
    echo "⚙️  Métodos públicos: $PUBLIC_METHODS"
    
    if [ $TOTAL_JAVA -gt 0 ]; then
        COVERAGE=$((DOCUMENTED * 100 / TOTAL_JAVA))
        echo "📈 Cobertura estimada: $COVERAGE%"
        
        if [ $COVERAGE -lt 30 ]; then
            log_warning "Cobertura muy baja - necesita atención urgente"
        elif [ $COVERAGE -lt 60 ]; then
            log_warning "Cobertura baja - agregar más documentación"
        elif [ $COVERAGE -lt 80 ]; then
            log_info "Cobertura buena - seguir mejorando"
        else
            log_success "Excelente cobertura de documentación!"
        fi
    fi
    
    echo ""
    echo "🔍 Archivos sin documentar:"
    find src/main/java -name "*.java" -exec grep -L "^\s*/\*\*" {} \; | head -10
}

check_quality() {
    log_info "Verificando calidad de JavaDoc..."
    
    echo "🔍 Verificando sintaxis..."
    mvn javadoc:javadoc -q > /tmp/javadoc-check.log 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "✅ Sintaxis JavaDoc correcta"
    else
        log_error "❌ Errores de sintaxis encontrados:"
        cat /tmp/javadoc-check.log | grep -E "error|warning" | head -5
    fi
    
    echo ""
    echo "📋 Clases principales sin documentar:"
    find src/main/java -name "*.java" -path "*/controller/*" -o -path "*/service/*" -o -path "*/model/*" | \
    xargs grep -L "^\s*/\*\*" | head -5
    
    rm -f /tmp/javadoc-check.log
}

clean_docs() {
    log_info "Limpiando documentación generada..."
    rm -rf target/site/apidocs/
    rm -rf target/reports/apidocs/
    log_success "✅ Archivos de documentación eliminados"
}

setup_git_hooks() {
    log_info "Configurando Git hooks..."
    ./scripts/setup-git-hooks.sh
}

serve_docs() {
    if [ ! -d "target/site/apidocs" ]; then
        log_warning "No existe documentación. Generando..."
        ./scripts/generate-docs.sh
    fi
    
    log_info "Iniciando servidor web local en puerto 8000..."
    log_info "Documentación disponible en: http://localhost:8000"
    log_info "Presiona Ctrl+C para detener"
    
    cd target/site/apidocs && python3 -m http.server 8000
}

package_docs() {
    log_info "Creando JAR con documentación..."
    mvn javadoc:jar
    
    if [ $? -eq 0 ]; then
        JAR_FILE=$(find target -name "*javadoc.jar" | head -1)
        if [ -n "$JAR_FILE" ]; then
            log_success "✅ JAR creado: $JAR_FILE"
        fi
    else
        log_error "❌ Error al crear JAR de documentación"
    fi
}

# Ejecutar comando basado en parámetro
case $COMMAND in
    "generate"|"gen"|"g")
        generate_docs
        ;;
    "watch"|"w")
        watch_mode
        ;;
    "stats"|"statistics"|"s")
        show_stats
        ;;
    "check"|"verify"|"c")
        check_quality
        ;;
    "clean"|"clear")
        clean_docs
        ;;
    "setup-hooks"|"hooks")
        setup_git_hooks
        ;;
    "serve"|"server")
        serve_docs
        ;;
    "package"|"jar"|"p")
        package_docs
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        log_error "Comando desconocido: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac 