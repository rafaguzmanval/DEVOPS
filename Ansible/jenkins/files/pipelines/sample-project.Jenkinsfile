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
                    // EL TRUCO: Añadimos --entrypoint='' para que no se cierre
                    docker.image('alpine/git:v2.49.1').inside("--entrypoint=''") {
                        echo "🚀 Clonando repositorio..."
                        git branch: "main", url: "${REPO_URL}"
                    }
                }
            }
        }

        stage('2. Alpine: Modificar') {
            steps {
                script {
                    // En Alpine estándar no suele hacer falta, pero por consistencia:
                    docker.image('alpine:latest').inside("--entrypoint=''") {
                        echo "🔧 Alpine editando..."
                        sh 'echo "\n-- Modificado por Alpine --" >> README.md'
                    }
                }
            }
        }

        stage('3. Ubuntu: Leer') {
            steps {
                script {
                    // Ubuntu no tiene git, pero aquí solo leemos
                    docker.image('ubuntu:latest').inside("--entrypoint=''") {
                        echo "📖 Ubuntu leyendo..."
                        sh 'cat README.md'
                    }
                }
            }
        }
    }
}