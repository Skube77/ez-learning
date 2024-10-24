pipeline {
    agent any
   tools {
        maven 'aaaa'  // Specify the Maven tool by its name ('mdf')
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

        stage('Install') {
            steps {
                sh "mvn install"
            }
        }
    }
}
