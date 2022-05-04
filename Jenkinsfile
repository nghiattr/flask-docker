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
        dir("./server/") {
        sh 'sudo sl analyze --app Flask-docker --python .'
        }
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
        sh "docker logout"
        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . "
        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
        sh "docker image ls | grep ${DOCKER_IMAGE}"
        withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
            sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            sh "docker push ${DOCKER_IMAGE}:latest"
        }

        // //clean to save disk
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

        
        sh 'docker save flask-docker:latest > flask-docker_latest.tar'

        sh '''
        docker run -ti --rm \
        -v $`pwd`/flask-docker_latest.tar:/img/flask-docker_latest.tar \
        -e CHKP_CLOUDGUARD_ID=339ec7d2-46d9-481e-9c82-7ab130475e11 \
        -e CHKP_CLOUDGUARD_SECRET=eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NTE2MzY5MjksImlzcyI6IlNoaWZ0TGVmdCIsIm9yZ0lEIjoiMzM5ZWM3ZDItNDZkOS00ODFlLTljODItN2FiMTMwNDc1ZTExIiwidXNlcklEIjoiNmM2NGNmNjQtMDUwMi00ODhhLWE3ZjEtNWU5YzAxMWEzNmU4Iiwic2NvcGVzIjpbInNlYXRzOndyaXRlIiwiZXh0ZW5kZWQiLCJhcGk6djIiLCJ1cGxvYWRzOndyaXRlIiwibG9nOndyaXRlIiwicGlwZWxpbmVzdGF0dXM6cmVhZCIsIm1ldHJpY3M6d3JpdGUiLCJwb2xpY2llczpjdXN0b21lciJdfQ.okMgzUp2FMCMA3mpCEXsl80vKVBay_7WT-6VG5yy5FKavCcfE7Xfow6rcjnMBHUjonml9TXesqb1xPPBw_7BxYX9uVKhlFf9CrzAiNTiQ0AnwYcaPAe01f8-Bx9-H2CTdtmPpOivqbRgGHlTtQeDiissU2EmTGa48hMweRB2pcr0k4i_j_XOAl5BJg2TYpX-4LANR-dQFSdc54516vpx7k3HQudU6hYkU0l0vvKNviqSVetKrBoQQLOrDyYcgwjpx73CO5aQ9rEAYN_DwibjVkCpTK7g3LDl7Ar6Cij3cK7AOc_fcBFnPZCq2hplt3uOLvjNOnvc0U1rmhe4VjuQjg \
        checkpoint/shiftleft \
        shiftleft  image-scan -t 900 \
            -i /img/flask-docker_latest.tar
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
