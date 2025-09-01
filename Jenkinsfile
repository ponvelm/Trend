pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '743808052586'
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'trend-app'
        IMAGE_TAG = 'latest'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
        DEPLOYMENT_NAME = 'trend-app-deployment' // kubernetes deployment name
        CONTAINER_NAME = 'trend-app' // container name inside deployment
    }

    stages {

        stage('Checkout Code') {
            steps {
                // Checkout code from the default repository configured in Jenkins
                checkout scm
            }
        }

        stage('Ensure ECR Repo Exists') {
            steps {
                script {
                    sh """
                    aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_DEFAULT_REGION} \
                        || aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_DEFAULT_REGION}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_URI} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Apply deployment YAML
                    sh "kubectl apply -f deployment.yaml"

                    // Update image in the deployment
                    sh "kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${IMAGE_URI}"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
