pipeline {
    agent any

    tools {
        jdk 'jdkaaa'         // JDK 17 installed via Jenkins
        maven 'aaaa' // Maven 3.8.6
    }

    environment {
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
             sh "mvn validate"
            }
        }
      stage('Clean and Build') {
            steps {
                sh 'mvn clean install -U'
            }
        }
        stage('Build') {
            steps {
                // Run Maven build
                sh "mvn clean package -DskipTests -e"
            }
        }
    }
}
