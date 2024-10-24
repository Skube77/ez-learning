pipeline {
    agent any

    tools {
        jdk 'jdk17'         // Use JDK 17
        maven 'aaaa' // Use Maven 3.8.6
    }

    environment {
        // Set JAVA_HOME using the Jenkins tool installation and explicitly add it to the PATH
        JAVA_HOME = tool name: 'jdk17', type: 'hudson.model.JDK'
        PATH = "${JAVA_HOME}/bin:${PATH}"  // Add JAVA_HOME to the PATH
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository"
    }

    stages {
        stage('Permissions') {
            steps {
                sh 'chmod 775 Dockerfile Jenkinsfile LICENSE README.md doc mvnw mvnw.cmd pom.xml src target'
            }
        }

        stage('Validate') {
            steps {
                // Echo the JAVA_HOME and verify Java installation
                sh 'echo $JAVA_HOME'
                sh 'java -version'
                sh "mvn validate -e"
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests -e"  // Build the project
            }
        }
    }
}
