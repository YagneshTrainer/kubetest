pipeline {
    agent any

    environment {
        registry = "innovativeacademy/appcontainer"
        registryCredentials = 'Dockerhub'
        dbHostname = "mysql-service"  // Internal ClusterIP service name
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
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh """
                            echo "Updating application.properties with mysql-service..."
                            sed -i 's|innovative.cuklu9atnt3c.ap-south-1.rds.amazonaws.com|${dbHostname}|g' src/main/resources/application.properties
                            echo "Updated application.properties:"
                            cat src/main/resources/application.properties
                        """
                    }
                }
            }
        }

        stage('Build') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'mvn clean install -DskipTests'
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
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        echo "Building Docker image..."
                        dockerImage = docker.build "${registry}:innovative_${BUILD_ID}"
                    }
                }
            }
        }

        stage('Upload Image') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        echo "Pushing Docker image..."
                        docker.withRegistry('', registryCredentials) {
                            dockerImage.push("innovative_${BUILD_ID}")
                            dockerImage.push('latest')
                        }
                    }
                }
            }
        }

        stage('Kubernetes Deploy') {
            agent { label 'KOPS' }
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    echo "Deploying to Kubernetes..."
                    sh """
                        helm upgrade --install --force vprofile-stack helm/tomcatcharts \
                        --set appimage=${registry}:innovative_${BUILD_ID} \
                        --namespace prod
                    """
                }
            }
        }
    }
}
