pipeline {

  agent none

  environment {
    DOCKER_IMAGE = "trongnghiattr/flask-docker-test"
  }

  stages {
    stage("Test") {
      agent { node {label 'Agent-deploy'}
          docker { 
            image 'python:3.8-slim-buster'
            args '-u 0:0 -v /tmp:/root/.cache'
          }
      }
      steps {
        sh "pip install poetry"
        sh "poetry install"
        sh "poetry run pytest"
      }
    }

    stage("Build") {
      agent { node {label 'Agent-deploy'}}
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
      agent { node {label 'Agent-deploy'}}
      steps{
        sh "pwd"
        sh "pwd"
        sh "ls"
        sh "export KUBECONFIG=Kuberconfig.yaml"
        sh "helm install -f helm-chart/values.yaml helm-deploy-flask helm-chart/"
        sh "helm list"
        sh "kubectl get svc"
      }
    }
  }


  post {
    success {
      echo "SUCCESSFUL asd"
    }
    failure {
      echo "FAILED"
    }
  }
}
