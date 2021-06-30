pipeline {
    agent any
    stages {
        stage('Building') {
            agent {
                docker {
                    image 'composer:2.1.3'
                    reuseNode true
                }
            }
            steps {
                echo 'Installing project composer dependencies...'
                sh 'cd $WORKSPACE'
                sh 'composer install --no-progress'
            }
        }
        stage('Tesing') {
            stages {
                stage('Linting') {
                    agent {
                        docker {
                            image 'registry.gitlab.com/pipeline-components/php-codesniffer:latest'
                            reuseNode true
                        }
                    }
                    steps {
                        echo 'Running linting...'
                        sh 'php -v'
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh 'phpcs -s -p --colors --extensions=php --standard=PSR2 ./src/'
                        }
                    }
                }
                stage('Unittest') {
                    agent {
                        docker {
                            image 'allebb/phptestrunner-73:latest'
                            args '-u root:sudo'
                            reuseNode true
                        }
                    }
                    steps {
                        echo 'Running PHP tests...'
                        sh 'php $WORKSPACE/vendor/bin/phpunit --coverage-html $WORKSPACE/report/clover --coverage-clover $WORKSPACE/report/clover.xml --log-junit $WORKSPACE/report/junit.xml'
                        sh 'chmod -R a+w $PWD && chmod -R a+w $WORKSPACE'
                        junit 'report/*.xml'
                    }
                }
            }

        }
        stage('Deploy') {
            steps {
                echo 'Bulding Docker...'
                sh 'docker build -t my-php-app .'
                sh 'docker run --rm --name my-running-app my-php-app'
            }
        }
        stage("Docker push") {
            environment {
                DOCKER_USERNAME = credentials("docker-user")
                DOCKER_PASSWORD = credentials("docker-password")
            }
            steps {
                sh "docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASSWORD}"
                sh 'docker tag my-php-app pushnenko/gbhomework:${env.BUILD_NUMBER}'
                sh "docker push pushnenko/gbhomework:${env.BUILD_NUMBER}"
            }
        }
    }
    post {
      always {
        cleanWs()
      }
    }
}