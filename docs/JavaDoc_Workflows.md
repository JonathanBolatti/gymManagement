# 🚀 Workflows de Automatización JavaDoc

## 📋 **Resumen de Opciones**

Tienes **4 niveles de automatización** según tus necesidades:

| Nivel | Método | Cuándo Usar | Comando |
|-------|--------|-------------|---------|
| **1. Manual** | Script bajo demanda | Después de documentar | `./scripts/generate-docs.sh` |
| **2. Watch** | Auto-regeneración | Durante desarrollo activo | `./scripts/watch-docs.sh` |
| **3. Git Hooks** | En commits automáticos | Trabajo en equipo | `./scripts/setup-git-hooks.sh` |
| **4. Aliases** | Comandos súper rápidos | Uso diario | `docs`, `jdoc`, etc. |

---

## 🎯 **Workflows por Escenario**

### **📝 Escenario 1: Desarrollo Individual**

```bash
# Flujo típico de desarrollo
1. Crear/modificar servicio con JavaDoc
   vim src/main/java/com/gym_management/system/services/PaymentService.java

2. Regenerar documentación
   ./scripts/generate-docs.sh
   # O con alias: docs

3. Ver resultado en navegador (se abre automáticamente)
```

### **👀 Escenario 2: Desarrollo Activo (Múltiples Cambios)**

```bash
# Modo vigilancia - regenera automáticamente
./scripts/watch-docs.sh

# Ahora cada vez que guardes un .java:
# 1. Se detecta el cambio
# 2. Se regenera JavaDoc automáticamente
# 3. Puedes refrescar el navegador para ver cambios
```

### **👥 Escenario 3: Trabajo en Equipo**

```bash
# Configurar hooks una vez por desarrollador
./scripts/setup-git-hooks.sh

# Flujo automático desde entonces:
git add .
git commit -m "Add PaymentService with JavaDoc"
# ↳ Pre-commit: Regenera JavaDoc automáticamente
# ↳ Post-commit: Muestra estadísticas de cobertura
```

### **⚡ Escenario 4: Comandos Rápidos Diarios**

```bash
# Configurar aliases una vez
./scripts/aliases.sh
source ~/.zshrc

# Comandos súper rápidos:
docs           # Generar documentación
docs-stats     # Ver estadísticas
docs-watch     # Modo vigilancia
docs-serve     # Servidor web local
docs-clean     # Limpiar archivos
```

---

## 🛠️ **Herramientas Disponibles**

### **📂 Scripts Principales**

| Script | Propósito | Uso |
|--------|-----------|-----|
| `generate-docs.sh` | Generación básica | `./scripts/generate-docs.sh` |
| `watch-docs.sh` | Vigilancia automática | `./scripts/watch-docs.sh` |
| `setup-git-hooks.sh` | Configurar hooks | `./scripts/setup-git-hooks.sh` |
| `docs-utils.sh` | Utilidades múltiples | `./scripts/docs-utils.sh [comando]` |
| `aliases.sh` | Configurar shortcuts | `./scripts/aliases.sh` |

### **⚡ Comandos de Utilidades**

```bash
# Usando docs-utils.sh
./scripts/docs-utils.sh generate    # Generar documentación
./scripts/docs-utils.sh watch       # Modo vigilancia
./scripts/docs-utils.sh stats       # Estadísticas actuales
./scripts/docs-utils.sh check       # Verificar calidad
./scripts/docs-utils.sh clean       # Limpiar archivos
./scripts/docs-utils.sh serve       # Servidor web local
./scripts/docs-utils.sh package     # Crear JAR
./scripts/docs-utils.sh help        # Ver ayuda
```

### **🎯 Aliases Rápidos (después de configurar)**

```bash
docs           # = ./scripts/docs-utils.sh generate
docs-stats     # = ./scripts/docs-utils.sh stats
docs-watch     # = ./scripts/docs-utils.sh watch
docs-serve     # = ./scripts/docs-utils.sh serve
javadoc        # = ./scripts/generate-docs.sh
jdoc           # = ./scripts/generate-docs.sh
doc-quick      # = mvn javadoc:javadoc -q && abrir navegador
```

---

## 📊 **Monitoreo y Métricas**

### **Ver Estadísticas Actuales**

```bash
./scripts/docs-utils.sh stats

# Output ejemplo:
📊 Estadísticas de Documentación
================================
📁 Total de archivos Java: 13
📝 Archivos con JavaDoc: 3
🏛️ Clases/Interfaces públicas: 13
⚙️ Métodos públicos: 41
📈 Cobertura estimada: 23%
[WARNING] Cobertura muy baja - necesita atención urgente
```

### **Verificar Calidad**

```bash
./scripts/docs-utils.sh check

# Verifica:
# ✅ Sintaxis JavaDoc correcta
# 📋 Clases principales sin documentar
# 🔍 Errores de compilación
```

---

## 🔄 **Workflows Recomendados**

### **🏆 Para Principiantes**

```bash
# Configuración inicial (una vez)
./scripts/aliases.sh
source ~/.zshrc

# Uso diario
docs           # Generar documentación
docs-stats     # Ver progreso
```

### **🚀 Para Desarrolladores Experimentados**

```bash
# Configuración completa (una vez)
./scripts/setup-git-hooks.sh
./scripts/aliases.sh

# Desarrollo con vigilancia automática
docs-watch     # En una terminal
# Desarrollar en otra terminal
# JavaDoc se actualiza automáticamente
```

### **👥 Para Equipos**

```bash
# Configuración estándar de equipo
./scripts/setup-git-hooks.sh    # Cada desarrollador
./scripts/aliases.sh            # Cada desarrollador

# Pipeline CI/CD
mvn javadoc:javadoc             # En builds
./scripts/docs-utils.sh package # Para artifacts
```

---

## 📈 **Mejorando la Cobertura**

### **Estado Actual del Proyecto**

```
📈 Cobertura actual: 23% (3/13 archivos)
🎯 Meta recomendada: 80%+
```

### **Plan de Acción**

```bash
# 1. Ver qué falta documentar
docs-stats

# 2. Priorizar por importancia
# Controllers → Services → Models → Exceptions

# 3. Documentar gradualmente
# Agregar JavaDoc a 2-3 archivos por día

# 4. Monitorear progreso
docs-stats   # Verificar mejora semanal
```

### **Archivos Prioritarios para Documentar**

```
🔥 Alta prioridad:
   • MemberController.java
   • MemberRepository.java
   • MemberResponse.java

⚡ Media prioridad:
   • CreateMemberRequest.java
   • UpdateMemberRequest.java
   • Member.java

📝 Baja prioridad:
   • SystemApplication.java
   • SecurityConfig.java
   • Excepciones personalizadas
```

---

## 🆘 **Troubleshooting**

### **Script No Ejecuta**

```bash
# Verificar permisos
ls -la scripts/
# Si no son ejecutables:
chmod +x scripts/*.sh
```

### **Aliases No Funcionan**

```bash
# Verificar que se agregaron
cat ~/.zshrc | grep docs

# Recargar configuración
source ~/.zshrc

# O reiniciar terminal
```

### **Watch Mode No Detecta Cambios**

```bash
# Instalar fswatch (macOS)
brew install fswatch

# O usar modo polling (funciona sin fswatch)
./scripts/watch-docs.sh
```

---

## 💡 **Tips Avanzados**

### **Servidor Local para Revisión**

```bash
# Servidor web para revisar docs
docs-serve
# Abre http://localhost:8000
# Útil para demos o revisiones
```

### **Compartir Documentación**

```bash
# Crear JAR con documentación
docs package
# Envía target/*-javadoc.jar a colegas
```

### **Integración IDE**

```bash
# IntelliJ IDEA: Tools → Generate JavaDoc
# Configurar External Tools con nuestros scripts
# Atajos de teclado personalizados
```

---

## 🎉 **Resultado Final**

Con este sistema tienes:

- ✅ **4 niveles de automatización** según necesidades
- ✅ **Scripts listos para usar** sin configuración compleja
- ✅ **Monitoreo automático** de cobertura
- ✅ **Integración con Git** para equipos
- ✅ **Comandos súper rápidos** para uso diario
- ✅ **Escalable** a medida que crece el proyecto

**¡Tu documentación ahora se mantiene sola!** 📚✨ 