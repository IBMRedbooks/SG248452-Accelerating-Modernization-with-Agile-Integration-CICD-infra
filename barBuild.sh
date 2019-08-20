#! /bin/bash
# barBuild.sh
# This script:
# 1. Takes in command line arguments and sets Variables
# 2. Sets permissions of current build run's source code directory so that it can be written to from a container
# 3. Runs a container instance of the ACE base image supplied in the command line arguments, container runs locally on Jenkins server
# 4. The current build run's source code directory is mounted into the container
# 5. Docker exec command is used to run the mqsipackagebar command and build a bar file
# 6. Bar file is moved onto the mounted directory so that it is available to the Jenkins server
# 7. Container instance used for the build is stopped and removed
# 7. Optionally this script could be modified to upload the bar file to a repository


sourceRepo=$1
baseImageName=$2
baseImageTag=$3
sourceDir=$sourceRepo-${BUILD_ID}/$sourceRepo
thisDir=$(pwd)
appName=database_query
barTag=$(date | tr -d ' ' | tr '[:upper:]' '[:lower:]' | tr -d : ).${BUILD_ID}
bar_file=${appName}.${barTag}.${BUILD_ID}.bar
icpClusterPortNS=mycluster.icp:8500/icp4i


# Echo out variables to be used in script
echo "sourceRepo is: $sourceRepo"
echo "baseImageName is: $baseImageName"
echo "baseImageTag is: $baseImageTag"
echo "sourceDir is: $sourceDir"
echo "thisDir is: $thisDir"
echo "barTag is: $barTag"
echo "bar_file is: $bar_file"
echo "appName is: $appName"

# Need to set permisions so that the container can can write to the mount
# Execute permission required to write to mount using mv command from container
# For this example 757 permisions have been set so that aceuser can write to the mount
# For live systems an alternative solution for managing permisions on the mount is advised
 chmod -R 757  $sourceRepo-${BUILD_ID}/
 ls -lrt $sourceRepo-${BUILD_ID}/
 ls -lrt $sourceDir/

echo "Spin up ACE container and mount in source folder"

echo "sudo docker run --name aceserverbarbuild --detach --env LICENSE=accept --env ACE_SERVER_NAME=ACESERVER --mount type=bind,src=${thisDir}/${sourceDir}/,dst=/home/aceuser/app-source ${icpClusterPortNS}/${baseImageName}:${baseImageTag}"
sudo docker run --name aceserverbarbuild --detach --env LICENSE=accept --env ACE_SERVER_NAME=ACESERVER --mount type=bind,src=${thisDir}/${sourceDir}/,dst=/home/aceuser/app-source ${icpClusterPortNS}/${baseImageName}:${baseImageTag}

if [ $? != 0 ]; then
   echo "docker run failed"
   exit 78
fi

# get the containerID
barBuildContainerID=$(sudo docker ps | grep aceserverbarbuild | head -1 | cut -d' ' -f1)
echo "barBuildContainerID is: $barBuildContainerID"


# Exec into the container, build the bar file, move it to the directory mounted in the container
sudo docker exec ${barBuildContainerID} bash -c ". /opt/ibm/ace-11/server/bin/mqsiprofile ; mqsipackagebar -a ${bar_file} -w /home/aceuser/app-source/ -k ${appName} ; mv ${bar_file} /home/aceuser/app-source/ ; chmod 666 /home/aceuser/app-source/${bar_file}"



# check that the bar file is on the mount
ls -lrt ${thisDir}/${sourceDir}/${bar_file}
if [ $? != 0 ]; then
   echo "failed to create bar file"
   exit 78
fi

# If the bar file is there do an mqsireadbar to Verify
#sudo docker exec -it ${barBuildContainerID} bash -c 'mqsireadbar -b ${sourceDir}/${bar_file}'

# If above is successful then stop and delete the container
sudo docker stop ${barBuildContainerID}
if [ $? != 0 ]; then
   echo "failed to stop container ${barBuildContainerID}"
   exit 78
fi

sudo docker rm ${barBuildContainerID}
if [ $? != 0 ]; then
   echo "failed to delete container ${barBuildContainerID}"
   exit 78
fi
# Once bar file is built it could be push to a repository like Artifactory
echo "Bar file ${bar_file} would be pushed to repository"

echo "barBuild.sh completed building bar file ${bar_file}"
