# SG248452-Moving-Integration-to-the-Cloud-with-Agile-Integration-Architecture-CICD-infra
Build files for pipeline to deploy ACE microservice that retrieves information from a DB2 table.

Demonstration "Continuous Delivery" pipeline for IBM App Connect Enterprise micro-services.

The purpose of the project is give an example "Continuous Delivery" capability for IBM ACE. The pipeline was developed using Jenkins, however, the concepts shown, and the bash scripts used, can be re-purposed for use with other CI/CD technologies.

The repository contains only build information and scripts, not source code. Source code for the ACE application is stored in a different source repository, ensuring that changes to the pipeline repository and the source do not affect one another.

There are two options with this pipeline:
1. Use the full example, where the App Connect Enterprise integration connects to the DB2 database. In this case the variable in the Jenkins file must be set to:

applicationSourceRepoName="SG248452-Moving-Integration-to-the-Cloud-with-Agile-Integration-Architecture-CICD-appsrc-db2"

2. Use the standalone example, which deploys an App Connect Enterprise integration that can work independenntly of any other systems. In this case the variable in the Jenkinsfile must be set to:

applicationSourceRepoName="SG248452-Moving-Integration-to-the-Cloud-with-Agile-Integration-Architecture-CICD-appsrc-standalone"

For reference, the git repositories for both of the application source code examples can be found at the following urls:

https://github.com/IBMRedbooks/SG248452-Moving-Integration-to-the-Cloud-with-Agile-Integration-Architecture-CICD-appsrc-db2/blob/master/README.md

https://github.com/IBMRedbooks/SG248452-Moving-Integration-to-the-Cloud-with-Agile-Integration-Architecture-CICD-appsrc-standalone/blob/master/README.md


# Overview

For this scenario it is assumed that the ACE application code has been unit tested on the developer's laptop prior to being checked into the application source code git repository.


###### Jenkinsfile

Runs a series of bash scripts (detailed below) in pipeline stages.

The Jenkinsfile has the following variables that must be configured depending on the microservice that is to be built:

*applicationName* - name of the application, default of 'ace-db2-test-01'

*applicationSourceRepoName* - name of the git repository containing the ACE application source, default of 'ace-db2-app-source-02'

*helmChartName* - default of 'ibm-ace-server-icip-prod'

*helmChartVersion* - default of '1.1.2-icp4i-jenkins-01'

*aceBaseImageName* - base ACE Docker image to build FROM (also used to run container for bar file build), defaults to 'ace-base-11004'

*aceBaseImageTag* - tag of ACE base image, default of 'latest'


###### pullSource.sh

Downloads ACE application source code from a git repository specified in the "applicationSourceRepoName" variable in the Jenkinsfile.

###### barBuild.sh

Builds a bar file from source code retrieved by pullSource.sh, by temporarily running an ACE container locally on the Jenkins server with the source code mounted into that container.

###### dockerBuild.sh

Builds a new Docker image FROM the base image, adding in the bar file built by barBuild.sh.

###### deployChart.sh

Performs Helm deployment. A new values.yaml file is created for each deployment, referencing the image made for the build. The secret containing the ACE override-able information is currently hard coded in the values.yaml as 'ace-secret-dev'.

###### pingService.sh and apiTest.sh

In the following stage two tests are performed, to ping the service's admin port and to then call the API using curl.

###### After bash scripts

After the above scripts have run there are demonstration stages, which can be adapted to your organisation's needs. A deployment to a test environment and two example test steps (functional test and performance test) are included in the Jenkinsfile.

The pipeline ends with stage to upload the tested image to a production docker repository. From this repo a production deployment process can pick the images and deploy them according to a separate deployment timetable.


# Pre-requisites:

This scenario was developed on a Jenkins server installed on an Ubuntu VM
The Ubuntu VM sat outside of the Kubernetes cluser to which it was deploying the Helm chart

Your Jenkins server must have the following:
Docker installed locally
IBM Cloud Private CLI tools installed and configured to connect to IBM Cloud Private instance
Access to docker repository on IBM Cloud Private to which images can be pushed

You must have uploaded an ACE only base Docker image to your Docker repository associated with your ICP instance. This can be built using the instructions on the ACE-docker ot4i git repository:

https://github.com/ot4i/ace-docker

**information about helm chart to deploy needs to added**

ACE override-able configuration must be deployed in a secret on your Kubernetes workspace prior to running this pipeline. The documentation in url below shows how to this using a script supplied by IBM (see section 'Installing a sample image' and the generateSecrets.sh script):

https://github.com/ot4i/ace-helm/blob/master/ibm-ace/README.md

At time of writing the secret name must be ace-secret-dev, as this is what is hard coded in the value.yaml (to be updated).

# Restrictions:

This pipeline uses the mqsipackagebar command to create the bar file for deployment. The mqsipackagebar command does not compile resources such as jar files and message sets, so these must for compiled and committed to your source code git repository.

For further information see the following documentation:

https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bc31720_.htm

https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bc31730_.htm

This pipeline was developed using:
IBM Cloud Private 3.1.2.
Docker 18.09.8
Jenkins 2.176.2

The project is a demonstration that is designed to show ACE working with Continuous Delivery concepts and does not represent a production ready scenario. Where areas need to be further developed to make them production ready this has been clearly commented.

# To be updated:

- update deployChart.sh so that different configurationSecret can be used each time.
- update pullSource.sh so that username for git repo is not hard coded.
- Improve error checking in scripts
