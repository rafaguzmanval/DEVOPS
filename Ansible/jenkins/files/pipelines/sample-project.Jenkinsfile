pipeline {
    agent {
        label 'dind-agent'
    }

    environment {
        REPO_URL = 'https://github.com/rafaguzmanval/DEVOPS.git'
    }

    stages {
        stage('1. Git Clone (desde Imagen)') {
            steps {
                deleteDir()
                script {
                    // Usamos la imagen específica de git
                    // '-u 0:0' asegura que tengamos permisos para escribir en el workspace del agente
                    docker.image('alpine/git:v2.49.1').inside('-u 0:0') {
                        echo "🚀 Clonando repositorio con imagen alpine/git..."
                        sh "git clone ${REPO_URL} ."
                    }
                }
            }
        }

        stage('2. Alpine: Modificar') {
            steps {
                script {
                    docker.image('alpine:latest').inside('-u 0:0') {
                        echo "🔧 Alpine editando el archivo..."
                        sh 'echo "\n-- Modificado por Alpine --" >> README.md'
                    }
                }
            }
        }

        stage('3. Ubuntu: Leer') {
            steps {
                script {
                    docker.image('ubuntu:latest').inside('-u 0:0') {
                        echo "📖 Ubuntu leyendo el resultado final..."
                        sh 'cat README.md'
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🏁 Proceso multi-imagen terminado."
        }
    }
}