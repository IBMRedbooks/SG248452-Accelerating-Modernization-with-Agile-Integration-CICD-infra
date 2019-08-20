#
/var/lib/jenkins/cloudctl-login.sh
port=$(kubectl describe service ace-jenkins-release-ibm-ace-server-icip-prod  -n icp4i | grep webui | grep NodePort | tr -s " " | cut -d' ' -f3 | cut -d/ -f1)

nodeIP=$(kubectl get configmap -n kube-public ibmcloud-cluster-info   -o jsonpath="{.data.proxy_address}")

echo "Sleep for container to start up."
sleep 60

echo "Curling $nodeIP:$port"

curl http://${nodeIP}:${port} | grep "IBM App Connect"

if [ $? != 0 ]; then
   echo "Could not identify running ace container"
   echo "Verification failed"
   exit 78
fi

echo "Container verified - Success"
