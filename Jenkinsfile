pipeline {

  agent { node {label 'Agent-deploy'}}

  environment {
    DOCKER_IMAGE = "trongnghiattr/flask-docker-test"

    SONAR_PROJECT_KEY = "sonarqube-test"
    SONAR_SOURCES = './'
    SONAR_HOST_URL = "172.104.186.34:9000"
    SONAR_AUTH_TOKEN = "0c943233fe7741a82d27de1d70c3aa4269b62914"
  }

  stages {
    stage("SonarScanner"){
      agent{ node {label 'Sonarqube-Agent'}}
      steps {
         sh '''
          docker run \
            --rm \
            --net host \
            -e SONAR_HOST_URL="http://172.104.186.34:9000" \
            -v ${PWD}:/root/src  \
            sonarsource/sonar-scanner-cli \
            -Dsonar.verbose=true \
            -Dsonar.host.url=http://172.104.186.34:9000 \
            -Dsonar.projectName=sonarqube-test \
            -Dsonar.projectKey=sonarqube-test \
            -Dsonar.projectBaseDir=/sonarqube-agent/workspace/sonarqube-test \
            -Dsonar.login=0c943233fe7741a82d27de1d70c3aa4269b62914 \
            -Dsonar.sources=. "
         '''
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
  //   stage('Code Quality Check via SonarQube') {
  //     steps {
  //       script {
  //       def scannerHome = tool 'sonarqube';
  //           withSonarQubeEnv("sonarqube-container") {
  //           sh "${tool("sonarqube")}/bin/sonar-scanner \
  //           -Dsonar.projectKey=test-node-js \
  //           -Dsonar.sources=. \
  //           -Dsonar.css.node=. \
  //           -Dsonar.host.url=http://your-ip-here:9000 \
  //           -Dsonar.login=your-generated-token-from-sonarqube-container"
  //               }
  //          }
  //      }
  //  }
    
    stage("Build") {
      // agent { node {label 'Agent-deploy'}}
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
      // agent { node {label 'Agent-deploy'}}
      steps{
        //sh "helm --kubeconfig kubeconfig.yaml install -f helm-chart/values.yaml testhelmdeploy helm-chart/"
        //helm install -f helm-chart/values.yaml testhelmdeploy helm-chart/
        sh "helm  upgrade --install --wait testhelmdeploy helm-chart/"
      }
    }
  }


  post {
    success {
      echo "SUCCESSFULL test 15.10a"
    }
    failure {
      echo "FAILED"
    }
  }
}
