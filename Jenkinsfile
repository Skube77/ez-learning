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
        MAVEN_SETTINGS = 'settings.xml'  // Path to custom Maven settings.xml with Nexus credentials
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'
        RELEASE_REPO = 'learning'
        CENTRAL_REPO = 'ezrelease'
        NEXUSIP = '10.217.1.34'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'leargroupe'
        NEXUS_LOGIN = 'nexus-credentials'
        DOCKER_REGISTRY = 'index.docker.io/v1/'  // Docker Hub Registry URL
        DOCKER_IMAGE_NAME = 'acilmajed/my-app-image'  // Docker Hub image name
    }

    stages {
        stage('Permissions') {
            steps {
                sh 'chmod 775 Dockerfile Jenkinsfile LICENSE README.md doc mvnw mvnw.cmd pom.xml src'
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

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using the defined Docker registry and image name
                    def dockerImage = docker.build("$DOCKER_IMAGE_NAME:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login to Docker Hub using the stored Jenkins credentials (dockerhub-credentials)
                    docker.withRegistry("https://$DOCKER_REGISTRY", 'dockerhub-credentials') {
                        dockerImage.push("${env.BUILD_ID}")
                    }
                }
            }
        }

        stage("UploadArtifact") {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'learning',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [artifactId: 'learning',
                         classifier: '',
                         file: 'target/platform-0.0.1-SNAPSHOT.jar',
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
