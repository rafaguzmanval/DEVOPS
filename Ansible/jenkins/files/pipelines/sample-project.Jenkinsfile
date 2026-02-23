// Jenkins Declarative Pipeline for sample-project
// Uses docker.image().inside() syntax

pipeline {
    agent {
            label 'dind-agent'
        }
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Hello World') {
            steps {
                script {
                    echo '👋 Hello World from Docker container!'
                    
                    docker.image('alpine:latest').inside() {
                        sh 'echo "Running inside Alpine container"'
                        sh 'ls -la'
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
