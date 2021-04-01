pipeline{
    agent any
    environment{
            AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
            AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
            AWS_REGION = credentials('AWS_REGION')
        }
    stages {
        stage('build') {
           steps{
                sh '''
                   cd docker
                   docker build -t flask-ecr . 
                   docker tag flask-ecr:latest public.ecr.aws/w6s1v6p3/flask-ecr:latest
                   '''
           }   
        }
        stage('push'){
           steps{
               sh '''
                  aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/w6s1v6p3  
                  docker push public.ecr.aws/w6s1v6p3/flask-ecr:latest
                  '''
           }
        }
        stage('deploy')
        {
           steps{
                sh '''
                   terraform init
                   terraform fmt
                   terraform validate
                   terraform apply -auto-approve    
                   '''    
           }
        }
    }
}
