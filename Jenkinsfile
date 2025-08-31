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
               
                docker build -t 743808052586.dkr.ecr.ap-south-1.amazonaws.com/trend-app:latest .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                echo "Logging into Amazon ECR..."
                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 743808052586.dkr.ecr.ap-south-1.amazonaws.com
                """
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh """

                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 743808052586.dkr.ecr.ap-south-1.amazonaws.com
                docker push 743808052586.dkr.ecr.ap-south-1.amazonaws.com/trend-app:latest
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
               
                aws eks update-kubeconfig --region ap-south-1 --name Trend-cluster
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                """
            }
        }
    }
}
