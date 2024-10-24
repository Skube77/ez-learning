pipeline {
    agent any

    tools {
        maven 'aaaa' // Use the same Maven version as in the Dockerfile
        jdk 'jdk17'          // Use JDK 17 as specified in the Dockerfile
    }

    environment {
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository"  // Set the local Maven repository path
    }

    stages {
        stage('Permissions') {
            steps {
                sh 'chmod 775 *'
            }
        }

        stage('Validate') {
            steps {
                sh "mvn validate"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
    }
}
