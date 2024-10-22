pipeline {
    agent any

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

        stage('Install') {
            steps {
                sh "mvn install"
            }
        }
    }
}
