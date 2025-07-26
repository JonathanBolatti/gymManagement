#!/bin/bash

# 📚 Script para generar documentación JavaDoc del proyecto Gym Management System
# Autor: Equipo de Desarrollo
# Versión: 1.0

echo "🏋️ Gym Management System - Generador de Documentación"
echo "======================================================="

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pom.xml" ]; then
    log_error "No se encontró pom.xml. Ejecuta este script desde la raíz del proyecto."
    exit 1
fi

log_info "Iniciando generación de documentación JavaDoc..."

# Limpiar documentación anterior
if [ -d "target/site/apidocs" ]; then
    log_info "Limpiando documentación anterior..."
    rm -rf target/site/apidocs
fi

# Generar JavaDoc
log_info "Generando documentación..."
mvn javadoc:javadoc -q

# Verificar si se generó correctamente
if [ $? -eq 0 ] && [ -f "target/site/apidocs/index.html" ]; then
    log_success "✅ Documentación generada exitosamente!"
    
    # Mostrar información de los archivos generados
    echo ""
    log_info "📊 Resumen de archivos generados:"
    echo "   📁 Directorio: target/site/apidocs/"
    echo "   📄 Archivo principal: index.html"
    echo "   📊 Total de archivos: $(find target/site/apidocs -type f | wc -l | tr -d ' ')"
    
    # Abrir automáticamente en el navegador (solo en macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "🌐 Abriendo documentación en el navegador..."
        open target/site/apidocs/index.html
    else
        log_info "🌐 Documentación disponible en: file://$(pwd)/target/site/apidocs/index.html"
    fi
    
    echo ""
    log_success "🎉 ¡Documentación lista para usar!"
    echo ""
    echo "📋 Próximos pasos recomendados:"
    echo "   • Revisar la documentación generada"
    echo "   • Agregar JavaDoc a clases sin documentar"
    echo "   • Configurar generación automática en CI/CD"
    
else
    log_error "❌ Error al generar la documentación"
    echo ""
    echo "🔧 Soluciones posibles:"
    echo "   • Verificar que todas las dependencias estén instaladas"
    echo "   • Revisar errores de sintaxis en comentarios JavaDoc"
    echo "   • Ejecutar: mvn javadoc:javadoc para ver errores detallados"
    exit 1
fi 