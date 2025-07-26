# Dockerfile para Railway - Gym Management System

# Stage 1: Build
FROM maven:3.9-amazoncorretto-17 AS build

# Crear directorio de trabajo
WORKDIR /app

# Copiar solo pom.xml primero para mejor cache de dependencias
COPY pom.xml .

# Descargar dependencias (cache layer)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Construir la aplicación (saltando tests para optimizar build time)
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime  
FROM amazoncorretto:17-alpine

# Instalar curl para health checks
RUN apk add --no-cache curl

# Crear usuario no-root para seguridad
RUN addgroup -S spring && adduser -S spring -G spring

# Crear directorio de la aplicación
WORKDIR /app

# Cambiar propiedad del directorio al usuario spring
RUN chown spring:spring /app

# Cambiar al usuario no-root
USER spring

# Copiar el JAR desde el stage de build
COPY --from=build --chown=spring:spring /app/target/*.jar app.jar

# Variables de entorno para Railway
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando para ejecutar la aplicación
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 