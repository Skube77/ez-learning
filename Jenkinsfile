pipeline {
    agent any

    tools {
        jdk 'jdk17'         // Use JDK 17
        maven 'aaaa' // Use Maven 3.8.6
    }

    environment {
        // Ensure JAVA_HOME is set to the Jenkins JDK installation
        JAVA_HOME = tool name: 'jdk17', type: 'hudson.model.JDK'
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository"
        PATH = "${JAVA_HOME}/bin:${PATH}"  // Add JAVA_HOME to the PATH
    }

    stages {
        stage('Permissions') {
            steps {
                sh 'chmod 775 Dockerfile Jenkinsfile LICENSE README.md doc mvnw mvnw.cmd pom.xml src target'
            }
        }

        stage('Validate') {
            steps {
                sh "mvn validate -e"  // Run Maven validate
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests -e"  // Build the project
            }
        }
    }
}
