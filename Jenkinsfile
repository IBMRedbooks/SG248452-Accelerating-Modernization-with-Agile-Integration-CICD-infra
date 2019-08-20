node {
    // Setup Variables for Pipeline Build
    // Specify the micro-service name
    applicationName="ace-db2-test-01"
    // Specify the name and path of the repository where the application source is located
    //applicationSourceRepoName="ace-db2-app-source-02"
    applicationSourceRepoName="ace-nodb2-source-02"
    applicationSourceRepoPath="tquigly"
    // Specify the username that will authenticat to github
    gitUserName="tquigly"
    // Specify the Helm chart name
    helmChartName="ibm-ace-server-icip-prod"
    helmChartVersion="1.1.2-icp4i-jenkins-01"

    // Specify the name and tag of the ACE base docker image to build from
    //dockerRepo="mycluster.icp:8500/icp4i"
    aceBaseImageName="ace-base-11004"
    aceBaseImageTag="latest"

    try {
        stage ('Clone') {
        	checkout scm
        }
        stage ('Build and Verify Bar File') {
          // echo out the variables
          sh "echo 'applicationName is $applicationName'"
          sh "echo 'applicationSourceRepoName is $applicationSourceRepoName'"
          sh "echo 'helmChartName is $helmChartName'"
          sh "echo 'helmChartVersion is $helmChartVersion'"
          sh "echo 'aceBaseImageName is $aceBaseImageName'"
          sh "echo 'aceBaseImageTag is $aceBaseImageTag'"

          // Pull down ACE application source code from repository
          sh "chmod 700 pullSource.sh"
          sh "./pullSource.sh $applicationSourceRepoName $applicationSourceRepoPath $gitUserName"

          // Make sure that session is logged in to docker repository
          sh "/var/lib/jenkins/dockerlogin.sh"

          // Run a local copy of the ACE base docker container on Jenkins server
          // Mounts the directory containing the source into the container
          // Runs mqsipackagebar to build and mqsireadbar to verify the bar file
          sh "chmod 700 barBuild.sh"
          sh "./barBuild.sh $applicationSourceRepoName $aceBaseImageName $aceBaseImageTag"
	       }
        stage ('Build Microservice Docker Image') {
          // Run script to create docker image containing ACE micro-service
          // Upload the image to the docker repository
          sh "chmod 700 dockerBuild.sh"
          sh "./dockerBuild.sh $applicationName $aceBaseImageName $aceBaseImageTag $applicationSourceRepoName"
        }
        stage ('Deploy Microservice to Dev Environment') {
          // Run script to deploy the helm chart
        	sh "echo 'Deploying helm chart for ACE to Dev Environment'"
          sh "chmod 700 deployChart.sh"
          sh "./deployChart.sh icp4i $helmChartName $helmChartVersion"
        }
        stage ('Verification Test') {
	        // curl the new ace Service
          sh "echo 'Verify new Microservice by pinging the ACE admin port'"
          sh "chmod 700 pingService.sh"
          sh "./pingService.sh"
        }
      	stage ('API-Test') {
            sh "echo 'Run API test - ping the api'"
            sh "chmod 700 apiTest.sh"
            sh "./apiTest.sh"
      	}
        stage ('Deploy Microservice to Test Environment') {
            sh "echo 'Deploying helm chart for ACE to Test Environment'"
            // Script commented out, but if ran would deploy to a new Kubernetes namespace
            // This could be modified to deploy to a different Kubernetes cluster
            // sh "./deploy-chart.sh icp4i-test-ns"
            sh "sleep 10"
      	}
        stage ('Functional Test') {
            sh "echo 'Running functional test for $applicationName'"
            sh "sleep 10"
      	}
        stage ('Performance Test') {
            sh "echo 'Running performance test for $applicationName'"
            sh "sleep 10"
      	}
        stage ('Commit to Production Docker Repo') {
            sh "echo 'Uploading docker image for for $applicationName to production docker repository'"
            sh "sleep 10"
      	}
    } catch (err) {
        currentBuild.result = 'FAILED'
        throw err
    }
}
