// Initialize a LinkedHashMap / object to share containers between stages
def pipelineContext = [:]

pipeline {
    agent {
        label 'build_node'
    }
    environment { 
        DOCKER_IMAGE_TAG = "help-image:${env.BUILD_ID}"
        BRANCH_VERSION = '4.8.dev' 
        JENKINS = credentials('jenkin_vietnam_administrator')
        STAGING = credentials('help-staging-backoffice')
        MIG = credentials('help-migration-backoffice')
    }
    stages{
        stage("Checkout"){
            steps {
                echo "--------------------- Checking out Code ---------------------"
                script {
                    checkout scm: [$class: "GitSCM", branches: [[name: '*/main']], 
                                    userRemoteConfigs: [
                                            [credentialsId: 'bitbicket_billy', url: "https://bitbucket.org/noriaas/automated-help-deployment"]
                                        ]
                                    ]
                }
            }
        }
        stage("Build Robot Image"){
            steps {
                echo "--------------------- Building Docker Image ---------------------"
                script {
                        dockerImage = docker.build("${env.DOCKER_IMAGE_TAG}",  '-f ./Dockerfile .')
                        pipelineContext.dockerImage = dockerImage
                }
            }
        }
        stage("Run Robot Container"){
            steps{
                echo "--------------------- Running Docker Image ---------------------"
                script {
                    dockerImage.inside() {
                        sh 'robot --variable MIGRATION_PASS:$MIG_PSW --variable STAGING_PASS:$STAGING_PSW --variable JENKINS_PASS:$JENKINS_PSW tasks.robot'
                    }
                }
            }
        }
    }
    post {
        always {
            echo "--------------------- Stop Docker Container ---------------------"
            script {
                if (pipelineContext && pipelineContext.dockerContainer) {
                    pipelineContext.dockerContainer.stop()
                }
            }
        }
    }
}