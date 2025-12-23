FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy JAR file
COPY target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]

