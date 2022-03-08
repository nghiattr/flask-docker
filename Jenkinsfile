pipeline {
  

  agent none 
  environment {
    DOCKER_IMAGE = "trongnghiattr/flask-docker"
  }
  stages {
    stage("Build") {
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . "
        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
        sh "docker image ls | grep ${DOCKER_IMAGE}"
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
            sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            sh "docker push ${DOCKER_IMAGE}:latest"
        }

        //clean to save disk
        sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm ${DOCKER_IMAGE}:latest"
      }
    }
    stage("Deploy"){
      agent { node {label 'jenkins-agent'}}
      steps{
        sh "gcloud container clusters get-credentials k8s-cluster --zone asia-southeast2-a --project cicd-nghia-test"
        // sh "kubectl delete -f Flask-docker-deployment.yaml"
        // sh "kubectl delete -f Flask-docker-service.yaml"
        sh "kubectl apply -f Flask-docker-deployment.yaml"
        sh "kubectl apply -f Flask-docker-service.yaml"
      }
    }
  }


  post {
    success {
      echo "SUCCESSFULLLLLLLLLLLLLL"
    }
    failure {
      echo "FAILED"
    }
  }
}
