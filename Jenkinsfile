pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID     = '743808052586'
        ECR_REPO_NAME      = 'trend-app'
        IMAGE_TAG          = 'latest'
        ECR_REGISTRY       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        IMAGE_URI          = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
        DEPLOYMENT_NAME    = 'trend-app-deployment' // Kubernetes deployment name
        CONTAINER_NAME     = 'trend-app'             // Container name inside deployment
        REPO_DIR           = '.'                     // Current workspace
        EKS_CLUSTER_NAME   = 'Trend-cluster-new'     // Your EKS cluster name
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Ensure ECR Repo Exists') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', 
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                    aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_DEFAULT_REGION \
                        || aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_DEFAULT_REGION
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${REPO_DIR}") {
                    sh "docker build -t ${IMAGE_URI} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', 
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push ${IMAGE_URI}"
            }
        }

        stage('Configure kubeconfig') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', 
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                    aws eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
                    kubectl get nodes
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                dir("${REPO_DIR}") {
                    sh "kubectl apply -f deployment.yaml"
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
