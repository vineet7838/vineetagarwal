pipeline {
    agent any

    parameters {
        string(name: 'dockerRegistry', defaultValue: 'dtr.nagarro.com:443');
        string(name: 'username', defaultValue: 'vineetagarwal');
        string(name: 'dockerPort', defaultValue: '6000');
        string(name: 'helmPort', defaultValue: '30157');
    }

    tools {
        maven 'Maven3'
        jdk 'Java'
    }
    options {
        timestamps()

        timeout(time: 1, unit: 'HOURS')

        skipDefaultCheckout()

        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))

        disableConcurrentBuilds()
    }
    stages {
        stage('Checkout') {
            steps {
                echo "STEP - Checkout master branch"
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo "STEP - Build master branch"
                bat "mvn clean install"
            }
        }
        stage('Unit Testing') {
            steps {
                echo "STEP - Execute unit tests on master branch"
                bat "mvn test"
            }
        }
        stage ('Sonar Analysis') {
            steps {
                echo "STEP - Sonar Analysis on master branch"
                withSonarQubeEnv("Test_Sonar")
                {
                    bat "mvn sonar:sonar"
                }
            }
        }
        stage ('Upload to Artifactory') {
            steps {
                echo "STEP - Artifactory upload on master branch"
                rtMavenDeployer (
                    id: 'deployer',
                    serverId: '123456789@artifactory',
                    releaseRepo: 'CI-Automation-JAVA',
                    snapshotRepo: 'CI-Automation-JAVA'
                )
                rtMavenRun (
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: 'deployer'
                )
                rtPublishBuildInfo (
                    serverId: '123456789@artifactory'
                )
            }
       }
        stage('Docker Image') {
            steps {
                echo "STEP - Docker image for master branch with build number: ${BUILD_NUMBER}"
                bat "docker build -t ${params.dockerRegistry}/i_${params.username}_master:${BUILD_NUMBER} --no-cache -f Dockerfile ."
            }
        }
		stage ('Push to DTR') {
            steps {
				echo "STEP - Docker push for master branch"
                bat "docker push ${params.dockerRegistry}/i_${params.username}_master:${BUILD_NUMBER}"
            }
        }
        stage('Docker deployment') { 
            steps {
                echo 'STEP - Deploy to docker '
                bat "docker run --name c_${params.username}_master -d -p ${params.dockerPort}:8080 ${params.dockerRegistry}/i_${params.username}_master:${BUILD_NUMBER}"
            }
        }
    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}