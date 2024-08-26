pipeline {
    agent any

    environment {
        registry = "innovativeacademy/appcontainer:V1"
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
                    // Use sed to replace or add properties in application.properties
                    sh "sed -i 's|mysql-service|${dbHostname}|g' src/main/resources/application.properties"

                    // Check if the property exists and add it if it doesn't
                    sh "grep -q '${dbHostname}' src/main/resources/application.properties || echo 'new_property=${dbHostname}' >> src/main/resources/application.properties"
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
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
                    dockerImage = docker.build "${registry}:Innovative${BUILD_ID}"
                }
            }
        }

        stage('Upload Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredentials) {
                        dockerImage.push("Innovative${BUILD_ID}")
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Kubernetes Deploy') {
            agent { label 'KOPS' }
            steps {
                sh "helm upgrade --install --force vprofile-stack helm/tomcatcharts --set appimage=${registry}:Innovative${BUILD_ID} --namespace prod"
            }
        }
    }
}
