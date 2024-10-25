pipeline {
    agent any

    tools {
        jdk 'jdkaaa'         // JDK 17 installed via Jenkins
        maven 'aaaa'         // Maven 3.8.6
    }

    environment {
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository -Dsonar.userHome=$WORKSPACE/.sonar"
        SONAR_HOST_URL = 'http://sonarqube-pfe.apps-crc.testing'
        SONAR_LOGIN = credentials('sonar-token')  // SonarQube token
        NEXUS_URL = 'https://nexus-pfe.apps-crc.testing/repository/maven-releases/'  // Nexus repository URL
        NEXUS_CREDENTIALS_ID = 'nexus-admin-creds'  // The credentials ID you added in Jenkins for Nexus
        GROUP_ID = 'com.ezlearning'
        ARTIFACT_ID = 'platform'
        VERSION = '0.0.1-SNAPSHOT'
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
                sh 'mvn clean install'
            }
        }

        stage('List Target Directory') {
            steps {
                // List the contents of the target directory to see if the .war file was generated
                sh 'ls -l target/'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubePFE') {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar \
                        -Dsonar.projectKey=my_project_key \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_LOGIN
                    '''
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests -e"
            }
        }

        stage('Nexus Upload') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'https',
                    nexusUrl: "$NEXUS_URL",
                    groupId: "$GROUP_ID",
                    version: "$VERSION",
                    repository: 'maven-releases',
                    credentialsId: "$NEXUS_CREDENTIALS_ID",
                    artifacts: [
                        [artifactId: "$ARTIFACT_ID",
                        classifier: '',
                        file: "target/${ARTIFACT_ID}-${VERSION}.war",
                        type: 'war']
                    ]
                )
            }
        }
    }

    post {
        always {
            script {
                try {
                    timeout(time: 10, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                } catch (e) {
                    echo "Quality gate check failed: ${e.message}"
                }
            }
        }
    }
}
