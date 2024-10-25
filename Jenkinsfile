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
        NEXUS_URL = 'https://nexus-pfe.apps-crc.testing'  // Correct Nexus base URL without double "https://"
        NEXUS_REPO_PATH = '/repository/maven-releases/'   // Define the repository path separately
        NEXUS_CREDENTIALS_ID = 'nexus-credentials'  // Make sure the credentials ID matches the correct one
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
                // List the contents of the target directory to verify the .jar file
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
                echo "Using credentials ID: $NEXUS_CREDENTIALS_ID"
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'https',
                    nexusUrl: "$NEXUS_URL",  // Correct base URL without double "https://"
                    repository: "$NEXUS_REPO_PATH",  // Repository path separated
                    groupId: "$GROUP_ID",
                    version: "$VERSION",
                    credentialsId: "$NEXUS_CREDENTIALS_ID",
                    artifacts: [
                        [artifactId: "$ARTIFACT_ID",
                        classifier: '',
                        file: "target/${ARTIFACT_ID}-${VERSION}.jar",  // Upload the .jar file
                        type: 'jar']
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
