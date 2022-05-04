pipeline {

  agent none 

  environment {
    DOCKER_IMAGE = "flask-docker"
    
    registryCredentials = "nexus-server"
    registry = "34.150.85.230:5000"
  }

  stages {
    stage("SonarScanner"){
      agent { node {label 'jenkins-agent'}}
      steps{
        sh "whoami"
      }
    }

    stage("Test") {
      agent {
         docker {
            image 'python:3.8-slim-buster'
            args '-u 0:0 -v /tmp:/root/.cache'
          }
      }
      steps {
        // sh "docker run -d -v /tmp:/root/.cache -w /var/jenkins_home/workspace/Flask-Docker --name pythontest123 python:3.8-slim-buster"
        // // sh "docker exec -it pythontest123 bash"
        sh "pip install poetry"
        sh "poetry install"
        sh "poetry run pytest"
        // sh "docker stop pythontest123"
        // sh "docker rm pythontest123"
      }
    }
    stage("Build"){
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps{
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
  }


  post {
    success {
      echo "SUCCESSFULLLLLLLLLLLLLLLL"
    }
    failure {
      echo "FAILED"
    }
  }
}
