pipeline 
{   
       agent any 
          tools
          {
              maven 'MAVEN3'
          }        
          options
       {
  
          skipDefaultCheckout()

          disableConcurrentBuilds()
       }
       stages
       {
          stage ('checkout')
              {
                   steps
                   {
                      echo "build in master branch - 1"
                            checkout scm
                   }
              }
              stage ('Build')
              {
                   steps
                   {
                      echo "build in master branch - 2"
                      sh "mvn clean install -Dhttps.protocols=TLSv1.2"
                   }

              }
              stage ('Unit Testing')
              {
                   steps
                   {
                      sh "mvn test"
                   }

              }
              stage ('Sonar Analysis')
              {
                   steps
                   {
                      withSonarQubeEnv("Test_Sonar")
                      {
                      sh "mvn sonar:sonar -Dhttps.protocols=TLSv1.2"
                      }
                   }

              }
	      stage ('Upload to Artifactory')
              {
                  steps
                  {
                      rtMavenDeployer(
                        id: 'deployer',
                        serverId: '123456789@artifactory',
                        releaseRepo : 'CI-Automation-JAVA',
                        snapshotRepo: 'CI-Automation-JAVA'
                        )

                      rtMavenRun(
                        pom: 'pom.xml',
                        goals: 'clean install',
                        deployerId: 'deployer'
                        )
       
                      rtPublishBuildInfo(
                        serverId: '123456789@artifactory'
                       )
                  }

              }
              stage('Docker image') 
              {
                  steps
                  {
                       sh '/usr/local/bin/docker build -t dtr.nagarro.com:443/image_vineetagarwal_master:${BUILD_NUMBER} .'
                  }
              }
              stage('Push to DTR') {
                  steps{
                          sh '/usr/local/bin/docker push dtr.nagarro.com:443/image_vineetagarwal_master:${BUILD_NUMBER}'
                  }
              }
              stage('Stop running containers') 
              {
		  steps{
                     sh '''
                     ContainerId=$(/usr/local/bin/docker ps | grep 6000 | cut -d " " -f 1)
                     if [ $ContainerId ]
                     then
                     docker stop ContainerId
                     docker rm -f $ContainerId
                     fi
                     '''
                      sh '/usr/local/bin/docker stop container_vineetagarwal_master || exit 0 && /usr/local/bin/docker rm container_vineetagarwal_master || exit 0'
                  }
              }
              stage('Docker deployment') 
              {
                 steps{
                     sh '/usr/local/bin/docker run -d --name container_vineetagarwal_master -p 6000:8080 -t dtr.nagarro.com:443/image_vineetagarwal_master:${BUILD_NUMBER}'
                 }
              }
            
             
       }
}
