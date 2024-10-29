# Étape 2 : Exécuter l'application dans un conteneur léger
FROM openjdk:17-jdk-slim
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/platform-0.0.1-SNAPSHOT.jar"]
