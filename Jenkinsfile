pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID     = '743808052586'
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPO_NAME      = 'trend-app'
        IMAGE_TAG          = "latest"
        ECR_REGISTRY       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        IMAGE_URI          = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
        CLUSTER_NAME       = 'Trend-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ponvelm/Trend.git'
            }
        }

        stage('Build App') {
            steps {
                sh '''
                  npm install
                  npm run build
                '''
            }
        }

        stage('Ensure ECR Repo Exists') {
            steps {
               withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]){
                sh '''
                  aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_DEFAULT_REGION} \
                  || aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_DEFAULT_REGION}
                '''
              }

            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${IMAGE_URI} .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                  aws ecr get-login-password --region ${AWS_DEFAULT_REGION} \
                  | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                  docker push ${IMAGE_URI}
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                  aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}

                  # Option 1: Update deployment image directly
                  kubectl set image deployment/trend-app trend-app=${IMAGE_URI} -n default || true

                  # Option 2 (Recommended): Use your manifests
                  # kubectl apply -f deployment.yaml
                  # kubectl apply -f service.yaml
                """
            }
        }
    }
}
