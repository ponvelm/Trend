pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '743808052586'
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'trend-app'
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ponvelm/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                echo "Building Docker image..."
                docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                echo "Logging into Amazon ECR..."
                aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                echo "Pushing Docker image to ECR..."
                docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                echo "Updating EKS deployment..."
                aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name Trend-cluster
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                kubectl rollout restart deployment trend-app-deployment
                """
            }
        }
    }
}
