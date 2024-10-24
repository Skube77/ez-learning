pipeline {
    agent any
   tools {
        maven 'aaaa'  // Specify the Maven tool by its name ('mdf')
        JDK 'ddd'
    }
    environment {
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository"  // Set the local Maven repository path to the Jenkins workspace
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

      stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
        }
    }
}