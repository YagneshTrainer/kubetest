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
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh """
                            sed -i 's|mysql-service|${dbHostname}|g' src/main/resources/application.properties
                            grep -q '${dbHostname}' src/main/resources/application.properties || echo 'new_property=${dbHostname}' >> src/main/resources/application.properties
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
                        dockerImage = docker.build "${registry}:innovative_${BUILD_ID}"
                    }
                }
            }
        }

        stage('Upload Image') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
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
