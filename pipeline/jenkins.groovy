pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'i386', 'arm', 'arm64'], description: 'Pick ARCH')
    }

    environment {
        REPO = "https://github.com/vvadymv/kbot.git"
        BRANCH = "main"
    }

    stages {

        stage('Echo') {
            steps {
                echo "Build for platform ${params.OS}"
                echo "Build for arch: ${params.ARCH}"
                echo "User group membership"
                sh "id"
            }
        }

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('test') {
            steps {
                echo 'Testing started'
                sh "make test"
            }
        }

        stage('build') {
            steps {
                echo 'Binary build started'
                sh "make build"
            }
        }

        stage('image') {
            steps {
                echo 'Docker image build started'
                sh "make image_ghcr"
            }
        }

        stage('login to GHCR') {
            steps {
                echo 'Login to container repo'
                script {
                    withCredentials([
                        string(credentialsId: 'GITHUB_TOKEN_PSW', variable: 'GITHUB_TOKEN_PSW'),
                        string(credentialsId: 'GITHUB_TOKEN_USR', variable: 'GITHUB_TOKEN_USR')
                    ]) {
                        sh "echo $GITHUB_TOKEN_PSW | docker login ghcr.io -u $GITHUB_TOKEN_USR --password-stdin"
                    }
                }
            }
        }

        stage('push') {
            steps {
                echo 'Push to container repo'
                sh "make push_ghcr"
            }
        }

    }
}
