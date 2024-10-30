# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file from the host machine to the container
COPY target/platform-0.0.1-SNAPSHOT.jar /app/platform-0.0.1-SNAPSHOT.jar

# Expose the application port
EXPOSE 8080

# Define the command to run the JAR file
ENTRYPOINT ["java", "-jar", "/app/platform-0.0.1-SNAPSHOT.jar"]
