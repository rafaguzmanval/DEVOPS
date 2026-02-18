// Jenkins Declarative Pipeline for sample-project
// Uses docker.image().inside() syntax

pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Hello World') {
            steps {
                script {
                    echo '👋 Hello World from Docker container!'
                    
                    docker.image('alpine:latest').inside() {
                        sh 'echo "Running inside Alpine container"'
                        sh 'cat /etc/os-release'
                        sh 'uname -a'
                    }
                }
            }
        }
        
        stage('Docker Version') {
            steps {
                script {
                    echo 'Getting Docker version...'
                    
                    docker.image('docker:cli').inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                        sh 'docker --version'
                        sh 'docker info'
                    }
                }
            }
        }
        
        stage('Node.js Example') {
            steps {
                script {
                    echo 'Running Node.js example...'
                    
                    docker.image('node:18-alpine').inside() {
                        sh 'node --version'
                        sh 'npm --version'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finished!'
        }
        success {
            echo '✅ Pipeline succeeded!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
