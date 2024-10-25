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
        NEXUS_URL = 'nexus-pfe.apps-crc.testing'  // Base Nexus URL, ensure it has https
        NEXUS_CREDENTIALS_ID = 'nexus-credentials'  // Ensure credentials are correct
        GROUP_ID = 'com.ezlearning'
        ARTIFACT_ID = 'platform'
        VERSION = '0.0.1-SNAPSHOT'
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

        stage('Debug Nexus Connection') {
            steps {
                echo "Testing connection to Nexus URL: $NEXUS_URL"
                sh 'curl -v $NEXUS_URL/repository/maven-snapshots/'
            }
        }

        stage('Nexus Upload') {
            steps {
                script {
                    echo "Starting Nexus artifact upload..."
                    echo "Using credentials ID: $NEXUS_CREDENTIALS_ID"
                    try {
                        nexusArtifactUploader(
                            nexusVersion: 'nexus3',
                            protocol: 'https',
                            nexusUrl: "$NEXUS_URL",  // Use base URL only
                            groupId: "$GROUP_ID",
                            version: "$VERSION",
                            repository: 'maven-snapshots',  // Push snapshots to the correct repository
                            credentialsId: "$NEXUS_CREDENTIALS_ID",
                            artifacts: [
                                [artifactId: "$ARTIFACT_ID",
                                classifier: '',
                                file: "target/${ARTIFACT_ID}-${VERSION}.jar",  // Upload the .jar file
                                type: 'jar']
                            ]
                        )
                        echo "Artifact uploaded successfully to Nexus"
                    } catch (Exception e) {
                        echo "Nexus upload failed with error: ${e}"
                        error "Nexus artifact upload failed"
                    }
                }
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
