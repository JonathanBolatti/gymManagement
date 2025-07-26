#!/bin/bash

# 🎯 Aliases para comandos de documentación JavaDoc
# Agregar a ~/.bashrc, ~/.zshrc, o similar

echo "🎯 Configurando aliases para JavaDoc..."

# Detectar shell
if [[ $SHELL == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ $SHELL == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

echo "📝 Shell detectado: $SHELL"
echo "📄 Archivo de configuración: $SHELL_RC"

# Crear aliases
cat >> "$SHELL_RC" << 'EOF'

# 📚 JavaDoc Aliases - Gym Management System
alias docs='./scripts/docs-utils.sh generate'
alias docs-watch='./scripts/docs-utils.sh watch'
alias docs-stats='./scripts/docs-utils.sh stats'
alias docs-check='./scripts/docs-utils.sh check'
alias docs-clean='./scripts/docs-utils.sh clean'
alias docs-serve='./scripts/docs-utils.sh serve'
alias docs-help='./scripts/docs-utils.sh help'

# Shortcuts adicionales
alias javadoc='./scripts/generate-docs.sh'
alias jdoc='./scripts/generate-docs.sh'
alias doc-quick='mvn javadoc:javadoc -q && open target/site/apidocs/index.html'

EOF

echo "✅ Aliases agregados a $SHELL_RC"
echo ""
echo "🚀 Para usar inmediatamente:"
echo "   source $SHELL_RC"
echo ""
echo "💡 Aliases disponibles después de reiniciar terminal:"
echo "   docs         - Generar documentación"
echo "   docs-watch   - Modo vigilancia"
echo "   docs-stats   - Ver estadísticas"
echo "   docs-check   - Verificar calidad"
echo "   docs-serve   - Servidor web local"
echo "   javadoc      - Generación rápida"
echo "   jdoc         - Alias corto"
echo "   doc-quick    - Maven + abrir navegador" 