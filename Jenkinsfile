pipeline {
    agent any

    tools {
        jdk 'jdkaaa'         // JDK 17 installed via Jenkins
        maven 'aaaa'         // Maven 3.8.6
    }

    environment {
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository -Dsonar.userHome=$WORKSPACE/.sonar"
        SONAR_HOST_URL = 'http://sonarqube-pfe.apps-crc.testing'
        SONAR_LOGIN = credentials('sonar-token')  // SonarQube token stored in Jenkins
        MAVEN_SETTINGS = 'settings.xml'  // Path to the Maven settings.xml with Nexus credentials
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'
        NEXUSIP = '10.217.1.34'
        NEXUSPORT = '8081'
        RELEASE_REPO = 'learning'
        CENTRAL_REPO = 'ezrelease'
        NEXUS_GRP_REPO = 'leargroupe'
        NEXUS_LOGIN = 'nexus-credentials'  // Nexus credentials
    }

    stages {

        // Validate Maven project
        stage('Validate') {
            steps {
                sh "mvn validate"
            }
        }

        // Clean and Build
        stage('Clean and Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        // Build without running tests
        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests -e"
            }
        }

        // Code analysis with SonarQube
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubePFE') {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar \
                        -Dsonar.projectKey=SonarQubePFE \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_LOGIN
                    '''
                }
            }
        }

        // Upload artifact to Nexus
        stage('UploadArtifact') {
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

        // Build Docker image and push to Docker Hub
        stage('Prepare New Docker image') {
            steps {
                sh '''
                    echo "Logging into Docker registry..."
                    docker login -u "acilmajed" -p "Skube@177"
                    
                    echo "Building Docker image..."
                    docker buildx build --cache-from=type=registry,ref=acilmajed/ez-learning-app:latest --push -t acilmajed/ez-learning-app:latest .
                '''
            }
        }

        // Security scan with Trivy
stage('Scan Docker Image with Trivy') {
    steps {
        sh '''
            echo "Running Trivy scan on Docker image..."
            trivy image acilmajed/ez-learning-app:latest
        '''
    }
}
    }

    // Post section to check SonarQube Quality Gate after pipeline execution
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
