pipeline {
    agent any

    environment {
        registry = "innovativeacademy/appcontainer"
        registryCredentials = 'Dockerhub'
        dbHostname = "mysql-service"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Modify Properties File') {
            steps {
                script {
                    try {
                        sh """
                            sed -i 's|mysql-service|${dbHostname}|g' src/main/resources/application.properties
                            grep -q '${dbHostname}' src/main/resources/application.properties || echo 'new_property=${dbHostname}' >> src/main/resources/application.properties
                        """
                    } catch (Exception e) {
                        echo "Error modifying properties file: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Build') {
            steps {
                try {
                    sh 'mvn clean install -DskipTests'
                } catch (Exception e) {
                    echo "Error building the project: ${e.getMessage()}"
                    throw e
                }
            }
            post {
                success {
                    echo "Now Archiving..."
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('Build App Image') {
            steps {
                script {
                    try {
                        dockerImage = docker.build "${registry}:innovative_${BUILD_ID}"
                    } catch (Exception e) {
                        echo "Error building Docker image: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Upload Image') {
            steps {
                script {
                    try {
                        docker.withRegistry('', registryCredentials) {
                            dockerImage.push("innovative_${BUILD_ID}")
                            dockerImage.push('latest')
                        }
                    } catch (Exception e) {
                        echo "Error pushing Docker image: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Kubernetes Deploy') {
            agent { label 'KOPS' }
            steps {
                try {
                    sh """
                        helm upgrade --install --force vprofile-stack helm/tomcatcharts \
                        --set appimage=${registry}:innovative_${BUILD_ID} \
                        --namespace prod
                    """
                } catch (Exception e) {
                    echo "Error deploying to Kubernetes: ${e.getMessage()}"
                    throw e
                }
            }
        }
    }
}
