#!/bin/bash

# 🔗 Script para configurar Git Hooks automáticos para JavaDoc
# Regenera documentación antes de commits

echo "🔗 Configuración de Git Hooks para JavaDoc"
echo "==========================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar que estamos en un repositorio git
if [ ! -d ".git" ]; then
    log_warning "No estás en un repositorio Git. Inicializando..."
    git init
fi

# Crear directorio de hooks si no existe
mkdir -p .git/hooks

# Crear pre-commit hook
log_info "Creando pre-commit hook..."

cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook para regenerar JavaDoc automáticamente

echo "🔍 Pre-commit: Verificando documentación JavaDoc..."

# Verificar si hay cambios en archivos .java
JAVA_CHANGES=$(git diff --cached --name-only | grep '\.java$')

if [ -n "$JAVA_CHANGES" ]; then
    echo "📝 Archivos Java modificados detectados:"
    echo "$JAVA_CHANGES"
    
    echo "🔄 Regenerando documentación JavaDoc..."
    
    # Regenerar documentación
    if [ -f "scripts/generate-docs.sh" ]; then
        ./scripts/generate-docs.sh > /dev/null 2>&1
        DOCS_EXIT_CODE=$?
    else
        mvn javadoc:javadoc -q > /dev/null 2>&1
        DOCS_EXIT_CODE=$?
    fi
    
    if [ $DOCS_EXIT_CODE -eq 0 ]; then
        echo "✅ Documentación actualizada exitosamente"
        
        # Agregar archivos de documentación al commit si existen
        if [ -d "target/site/apidocs" ]; then
            # Solo agregar si el usuario quiere versionar la documentación
            # (comentar la siguiente línea si no quieres versionar docs)
            # git add target/site/apidocs/
            echo "📁 Documentación generada en target/site/apidocs/"
        fi
    else
        echo "❌ Error al generar documentación JavaDoc"
        echo "💡 Tip: Revisa los comentarios JavaDoc en los archivos modificados"
        echo "🔧 Para saltear esta validación: git commit --no-verify"
        exit 1
    fi
else
    echo "ℹ️  No hay cambios en archivos Java"
fi

echo "✅ Pre-commit check completado"
EOF

# Hacer el hook ejecutable
chmod +x .git/hooks/pre-commit

# Crear post-commit hook para generar stats
log_info "Creando post-commit hook..."

cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash

# Post-commit hook para estadísticas de documentación

echo "📊 Post-commit: Generando estadísticas de documentación..."

# Contar archivos Java
JAVA_FILES=$(find src/main/java -name "*.java" | wc -l | tr -d ' ')

# Contar archivos con JavaDoc (búsqueda simple)
DOCUMENTED_FILES=$(grep -r "^\s*/\*\*" src/main/java --include="*.java" | cut -d: -f1 | sort -u | wc -l | tr -d ' ')

# Calcular porcentaje
if [ $JAVA_FILES -gt 0 ]; then
    COVERAGE=$((DOCUMENTED_FILES * 100 / JAVA_FILES))
    echo "📈 Cobertura de JavaDoc: $DOCUMENTED_FILES/$JAVA_FILES archivos ($COVERAGE%)"
    
    if [ $COVERAGE -lt 50 ]; then
        echo "⚠️  Baja cobertura de documentación - considera agregar más JavaDoc"
    elif [ $COVERAGE -lt 80 ]; then
        echo "👍 Buena cobertura de documentación - ¡sigue así!"
    else
        echo "🎉 Excelente cobertura de documentación!"
    fi
fi
EOF

chmod +x .git/hooks/post-commit

log_success "✅ Git hooks configurados exitosamente!"

echo ""
echo "🔧 Hooks creados:"
echo "   • pre-commit: Regenera JavaDoc antes de commits"
echo "   • post-commit: Muestra estadísticas de cobertura"
echo ""
echo "💡 Para deshabilitar temporalmente:"
echo "   git commit --no-verify"
echo ""
echo "🗑️ Para eliminar hooks:"
echo "   rm .git/hooks/pre-commit .git/hooks/post-commit" 