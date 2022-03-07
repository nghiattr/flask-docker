pipeline {

  agent none 
  stages {
    stage("Build") {
      agent { node {label 'jenkins-agent'}}
      environment {
        DOCKER_TAG="${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        script {
             docker.withRegistry( 'http://'+registry, registryCredentials ) {
             sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . "
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
      echo "SUCCESSFULLLLLLLLLLLLLL"
    }
    failure {
      echo "FAILED"
    }
  }
}
