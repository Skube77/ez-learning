# Étape 1 : Construire l'application avec Maven
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests



# Étape 2 : Exécuter l'application dans un conteneur léger
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
COPY --from=build /app/jmx_prometheus_javaagent-1.0.1.jar /app/jmx_prometheus_javaagent.jar
COPY --from=build /app/jmx_exporter_config.yml /app/jmx_exporter_config.yml
EXPOSE 8080
EXPOSE 9090
ENTRYPOINT ["java", "-javaagent:/app/jmx_prometheus_javaagent.jar=9090:/app/jmx_exporter_config.yml", "-jar", "/app/app.jar"]
