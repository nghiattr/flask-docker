pipeline {

  agent none 

  environment {
    DOCKER_IMAGE = "flask-docker"
    
    registryCredentials = "nexus-server"
    registry = "reponexus.nghiathang.tk"
  }

  stages {
    stage("SonarScanner"){
      agent { node {label 'jenkins-agent'}}
      steps{
        sh "whoami"
        sh"pwd"
        sh '''
        docker run \
            --rm \
            --net host \
            -e SONAR_HOST_URL="http://35.247.164.137:9000" \
            -v ${PWD}:/usr/src  \
            sonarsource/sonar-scanner-cli \
            -Dsonar.verbose=true \
            -Dsonar.host.url=http://35.247.164.137:9000 \
            -Dsonar.projectName=sonarqube-test \
            -Dsonar.projectKey=sonarqube-test \
            -Dsonar.login=2aaca7485ae9a1b0eeec77e6a3a71c87cee7cfe8 \
            -Dsonar.sources=.
         '''
      }
    }

    stage('SLAnalyze Source Code') {
      agent { node {label 'jenkins-agent'}}
      steps{
        dir("./server/") {
        sh 'sudo sl analyze --app Flask-docker --python .'
        }
        sh 'whoami'
      }
    }

    stage("Unit Test") {
      agent {
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
    stage("Build & Deliver to Nexus"){
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps{
        script {
             docker.withRegistry( 'https://'+registry, registryCredentials ) {
             sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG  } . "
             sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
             sh "docker image ls | grep ${DOCKER_IMAGE}"
             sh "docker tag ${DOCKER_IMAGE} ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG}"
             sh "docker push ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG}"
             sh "docker tag ${DOCKER_IMAGE} ${registry}/${DOCKER_IMAGE}:latest"
             sh "docker push ${registry}/${DOCKER_IMAGE}:latest"
             sh "docker image ls | grep ${DOCKER_IMAGE}"
          }
        }

        //clean to save disk
        sh "docker image rm -f ${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm -f ${DOCKER_IMAGE}:latest"
        sh "docker image rm -f ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm -f ${registry}/${DOCKER_IMAGE}:latest"
        sh "docker image ls"
      }
    }

    stage('SLAnalyze Image') {
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps{

        sh "sudo docker pull ${DOCKER_IMAGE}:latest"
        sh "sudo docker save ${DOCKER_IMAGE}:latest -o flask_docker_latest.tar"
        sh '''
          sudo docker run --rm -v `pwd`/app:/app \
              -v `pwd`/flask_docker_latest.tar:/img/flask_docker_latest.tar \
              -e CHKP_CLOUDGUARD_ID="840bc519-e274-4695-a770-bf9416df0fa8" \
              -e CHKP_CLOUDGUARD_SECRET="x7ujznzpmztk5u4ipk8utra9" \
              checkpoint/shiftleft \
              shiftleft  image-scan -r -2000 -t 900 -e e7b7d7d2-a355-4af3-b88e-7558bdf355f3 -i /img/flask_docker_latest.tar -iw
        '''

        //clean to save disk
        sh "sudo docker image rm -f ${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "sudo docker image rm -f ${DOCKER_IMAGE}:latest"
        
      }
    }
    stage("Deploy"){
      agent {node {label 'jenkins-agent'}}
      steps{
        sh "whoami"
        sh "helm  upgrade --install -f helm-chart/values.yaml flaskdockerrr helm-chart/"
        sh "helm list"
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
