# Utiliser OpenJDK 17 comme image de base
FROM openjdk:17-jdk-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier JAR de l'application depuis l'hôte vers le conteneur
COPY target/platform-0.0.1-SNAPSHOT.jar /app/platform-0.0.1-SNAPSHOT.jar

# Copier le fichier JMX Exporter JAR et le fichier de configuration dans le conteneur
COPY jmx_prometheus_javaagent-1.0.1.jar /app/jmx_prometheus_javaagent.jar
COPY jmx_exporter_config.yml /app/jmx_exporter_config.yml

# Exposer le port de l'application et le port du JMX Exporter
EXPOSE 8080
EXPOSE 9090

# Définir la commande pour exécuter le fichier JAR avec le JMX Exporter comme agent Java
ENTRYPOINT ["java", "-javaagent:/app/jmx_prometheus_javaagent.jar=9090:/app/jmx_exporter_config.yml", "-jar", "/app/platform-0.0.1-SNAPSHOT.jar"]
