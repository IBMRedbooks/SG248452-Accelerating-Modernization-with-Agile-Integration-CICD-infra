#! /bin/bash
# deployChart.sh
# This script:
# 1. Takes in command line arguments and sets Variables
# 2. Checks whether the image name and tag has been written to a file for this instance of the build
# 3. Sets the image name and tag in Variables
# 4. Makes a copy of the values.yaml to use for this deployment, using the BUILD_ID as identifier
# 5. Uses sed commands to update the values file created for this build with image name and tag
# 6. Logs into ICP cloudctl (required for development purposes)
# 7. Runs helm upgrade command to install the helm chart

echo "Helm update or install (if required) to namespace ${NAMESPACE}"

NAMESPACE=$1
CHARTNAME=$2
CHARTVERSION=$3
VALUESFILE=values-$BUILD_ID.yaml
theDockerRepo=mycluster.icp:8500

# Echo out the variables
echo "NAMESPACE is: $NAMESPACE"
echo "CHARTNAME is: $CHARTNAME"
echo "VALUESFILE is: $VALUESFILE"
echo "theDockerRepo is: $theDockerRepo"


ls -la imageNameAndTag-$BUILD_ID.txt
#### Get the image name and tag in a variable
imageName=$(cat imageNameAndTag-$BUILD_ID.txt | cut -d: -f1)
imageTag=$(cat imageNameAndTag-$BUILD_ID.txt | cut -d: -f2)

### Make a values.yaml file specific to this buildWorkspace
cp values.yaml $VALUESFILE
ls -la $VALUESFILE
chmod 666 $VALUESFILE
ls -lrt


#### Run sed command to update image name and tag in values.yaml
sed -i "s/ace-image-replace/$theDockerRepo\/icp4i\/$imageName/" $VALUESFILE
sed -i "s/ace-tag-replace/$imageTag/" $VALUESFILE



cat $VALUESFILE | grep $imageName
if [ $? != 0 ]; then
   echo "Failed to add $imageName to $VALUESFILE"
   exit 78
fi

cat $VALUESFILE | grep $imageTag
if [ $? != 0 ]; then
   echo "Failed to add $imageTag to $VALUESFILE"
   exit 78
fi

# In the test environment where this demonstration was developed the cloudctl session periodically logs out
# To work around this issue a script was ran to login to a cloudctl session.
# In a live implementation an alternative solution to this problem is advised
echo "Log into cloudctl"
/var/lib/jenkins/cloudctl-login.sh


# We run the upgrade command with the -i flag to make it install the chart if it does not already exist
echo "helm upgrade -f ${VALUESFILE} -i ace-jenkins-release local-charts/${CHARTNAME} --version ${CHARTVERSION} --namespace=${NAMESPACE} --set license=accept --tls"
helm upgrade -f ${VALUESFILE} -i ace-jenkins-release local-charts/${CHARTNAME} --version ${CHARTVERSION} --namespace=${NAMESPACE} --set license=accept --tls
if [ $? != 0 ]; then
   echo "helm upgrade command failed"
   exit 78
fi

echo "Helm script completed"
