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
    stage("Deploy"){
      agent { node {label 'jenkins-agent'}}
      steps{
        sh "whoami"
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
