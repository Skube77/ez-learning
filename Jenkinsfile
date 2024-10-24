pipeline {
    agent any

    tools {
        jdk 'jdk17'         // JDK 17 installed via Jenkins
        maven 'aaaa' // Maven 3.8.6
    }

    environment {
        // Set JAVA_HOME to the Jenkins JDK installation directory explicitly
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
                // Echo JAVA_HOME for debugging
                sh 'echo JAVA_HOME is: $JAVA_HOME'
                sh 'java -version'

                // Run Maven with explicit JAVA_HOME
                sh "JAVA_HOME=${env.JAVA_HOME} mvn validate -e"
            }
        }

        stage('Build') {
            steps {
                // Run Maven build
                sh "JAVA_HOME=${env.JAVA_HOME} mvn clean package -DskipTests -e"
            }
        }
    }
}
