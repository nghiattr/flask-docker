pipeline {

  agent none 

  environment {
    DOCKER_IMAGE = "trongnghiattr/flask-docker"
    
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

    stage('SLAnalyze') {
      agent { node {label 'jenkins-agent'}}
      steps{
        // dir("./server/") {
        // sh 'sudo sl analyze --app Flask-docker --python .'
        // }
        sh 'whoami'
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
        sh "whoami"
        sh "docker logout"
        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . "
        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
        sh "docker image ls | grep ${DOCKER_IMAGE}"
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
            sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            sh "docker push ${DOCKER_IMAGE}:latest"
        }

        //clean to save disk
        // sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
        // sh "docker image rm ${DOCKER_IMAGE}:latest"
      }
    }

    stage('SLAnalyze-image') {
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps{

        
        sh 'docker save trongnghiattr/flask-docker:latest -o flask_docker_latest.tar'
        sh ''
        sh '''
          docker run --rm \
            -v `pwd`/flask_docker_latest.tar:/img/flask_docker_latest.tar \
            -e CHKP_CLOUDGUARD_ID="9b9b9acf-7fb4-4015-acac-1a30120edb7d" \
            -e CHKP_CLOUDGUARD_SECRET="5gd9p3dw5ix5e353bbzmkfmp" \
            checkpoint/shiftleft \
            shiftleft  image-scan -t 900 \
                -i /img/flask_docker_latest.tar
        '''

        //clean to save disk
        sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm ${DOCKER_IMAGE}:latest"
        
      }
    }
    stage("Deploy"){
      agent {node {label 'jenkins-agent'}}
      steps{
        sh "whoami"
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
