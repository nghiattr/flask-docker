pipeline {

  agent none 

  environment {
    DOCKER_IMAGE = "flask-docker"
    
    registryCredentials = "nexus-server"
    registry = "34.150.85.230:5000"
  }

  stages {
    stage("SonarScanner"){
      // agent{ node {label 'Sonarqube-Agent'}}
      // steps {
      //    sh '''
      //     docker run \
      //       --rm \
      //       --net host \
      //       -e SONAR_HOST_URL="http://172.104.186.34:9000" \
      //       -v ${PWD}:/sonarqube-agent/workspace/sonarqube-test \
      //       sonarsource/sonar-scanner-cli \
      //       -Dsonar.host.url=http://172.104.186.34:9000 \
      //       -Dsonar.projectName=sonarqube-test \
      //       -Dsonar.projectKey=sonarqube-test \
      //       -Dsonar.projectBaseDir=/sonarqube-agent/workspace/sonarqube-test \
      //       -Dsonar.login=0c943233fe7741a82d27de1d70c3aa4269b62914 \
      //       -Dsonar.sources=. "
      //    '''
      // }
      agent { node {label 'jenkins-agent'}}
      // agent { node {label 'Agent-deploy'}}
      // agent {
      //    docker {
      //       image 'sonarsource/sonar-scanner-cli'
      //       args '--rm -u 0:0 -v /tmp:/root/src --net host -e SONAR_HOST_URL="http://172.104.186.34:9000"'
      //     }
      // }
      steps{
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
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        // sh "docker build -t ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG} . "
        // sh "docker tag ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
        // sh "docker image ls | grep ${DOCKER_IMAGE}"

        //Push to Nexus repo



        //Push to dockerhub
        // withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        //     sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
        //     sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
        //     sh "docker push ${DOCKER_IMAGE}:latest"
        // }

        //sh "docker logout"
        script {
             docker.withRegistry( 'http://'+registry, registryCredentials ) {
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
        sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm ${DOCKER_IMAGE}:latest"
        sh "docker image rm ${registry}/${DOCKER_IMAGE}:${DOCKER_TAG}"
        sh "docker image rm ${registry}/${DOCKER_IMAGE}:latest"
        sh "docker image ls"
      }
    }

    // stage("Uploading to Nexus"){
    //   agent {node {label 'Agent-deploy'}}
    //   environment {
    //     DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
    //   }
    //   steps{
    //     script {
    //          docker.withRegistry( 'http://'+registry, registryCredentials ) {
    //          //DOCKER_IMAGE.push(${DOCKER_TAG})
    //          DOCKER_IMAGE.push('latest')
    //       }
    //     }
    //     sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
    //     sh "docker image rm ${DOCKER_IMAGE}:latest"
    //   }

    // }

    stage("Deploy"){
      agent { node {label 'jenkins-agent'}}
      steps{
        sh "gcloud container clusters get-credentials k8s-cluster --zone asia-southeast1-a --project jenkins-cicd-project-335209"
        //sh "helm --kubeconfig kubeconfig.yaml install -f helm-chart/values.yaml testhelmdeploy helm-chart/"
        //sh "helm install -f helm-chart/values.yaml testdocker helm-chart/"
        //sh "helm  upgrade --install  flask2 helm-chart/"
        //sh "helm uninstall flask2"
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
