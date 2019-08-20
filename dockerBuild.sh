#! /bin/bash
# dockerbuild.sh
# This script:
# 1. Takes in command line arguments and sets Variables
# 2. Obtains a copy of the bar file built by the current pipeline build
# 3. Copies the bar file to the ace-docker-master/sample/bars_aceonly directory (from which it is picked up by the Dockerfile)
# 4. Builds image of ACE microservice
# 5. Tags the image with datestamp and latest
# 6. Pushes image to docker repository associated with cloud instance
# 7. Writes the name and tag of the image to a temporary file, so it can be used by the next stage of the pipeline


imageName=$1
baseImageName=$2
aceBaseImageTag=$3
sourceRepo=$4

echo "imageName is: $imageName"
echo "baseImageName is: $baseImageName"
echo "aceBaseImageTag is: $aceBaseImageTag"
echo "sourceRepo is: $sourceRepo"

imageTag=$(date | tr -d ' ' | tr '[:upper:]' '[:lower:]' | tr -d : )
dockerfilePath=ace-docker-master/sample
dockerFile=Dockerfile.aceonly
sourceDir=$sourceRepo-${BUILD_ID}/$sourceRepo
icpClusterPortNS=mycluster.icp:8500/icp4i
imageNameAndTagFile=imageNameAndTag-$BUILD_ID.txt

# Copy bar file to working directory from mount directory used by the ACE container
# Alternative is to pull the bar file from repository that it was pushed to in bar build stage
echo "copy bar file from bar file repo to working directory"
# Do some script commands to pick up the latest bar file
latestBar=$(ls $sourceDir/ | grep bar | tr -s " " | cut -d' ' -f9)
# Do the copy
cp  ${sourceDir}/${latestBar} ace-docker-master/sample/bars_aceonly
echo "Check the bar file copy:"
ls -lrt ace-docker-master/sample/bars_aceonly | grep bar
if [ $? != 0 ]; then
   echo "No bar files in location ace-docker-master/sample/bars_aceonly"
   exit 78
fi


echo "About to build image called $imageName from docker file: ${dockerfilePath}/${dockerFile}"
# Build the image with a tag based on a lowercase datestamp
sudo docker build . -f ${dockerfilePath}/${dockerFile} -t ${icpClusterPortNS}/${imageName}:${imageTag}
if [ $? != 0 ]; then
   echo "Docker build failed"
   exit 78
fi

# Also tag the current image as latest
sudo docker image tag ${icpClusterPortNS}/${imageName}:${imageTag} ${icpClusterPortNS}/${imageName}:latest


# Let's take a look at our local docker repo:

echo "Listing the docker images inside the local docker repo on $hostname"
sudo docker images | grep ${imageName} | grep latest
if [ $? != 0 ]; then
   echo "Could not find image ${imageName} and tag latest when listing out docker images"
   exit 78
fi

sudo docker images | grep ${imageName} | grep latest
if [ $? != 0 ]; then
   echo "Could not find image ${imageName} and tag ${imageTag} when listing out docker images"
   exit 78
fi

# Push new image to icp docker repository
echo "Pushing images $imageName:$imageTag and $imageName:latest to the icp docker repo"
sudo docker push ${icpClusterPortNS}/${imageName}:${imageTag}
if [ $? != 0 ]; then
   echo "docker push ${icpClusterPortNS}/${imageName}:${imageTag} failed"
   exit 78
fi

sudo docker push ${icpClusterPortNS}/${imageName}:latest
if [ $? != 0 ]; then
   echo "docker push ${icpClusterPortNS}/${imageName}:latest failed"
   exit 78
fi

echo "Completed push of images $imageName:$imageTag and $imageName:latest to the icp docker repo"

echo "Write image name and tag to a temporary file"
# Creat the file, set the permissions and do some checks that can be seen from the console log (if running in Jenkins)
touch $imageNameAndTagFile
chmod 644 $imageNameAndTagFile
echo "$imageName:$imageTag" > $imageNameAndTagFile
ls -lrt $imageNameAndTagFile
cat $imageNameAndTagFile

# Remove the bar file from the local directory ace-docker-master/sample/bars_aceonly so that it doesn't interfere with next building
# Note that this is not safe solution for concurrent builds
rm ace-docker-master/sample/bars_aceonly/$latestBar

ls ace-docker-master/sample/bars_aceonly/
