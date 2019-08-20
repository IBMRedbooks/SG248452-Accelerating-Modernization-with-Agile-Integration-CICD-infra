# Test runs four functional test cases
# 1. Retrieve all product information
# 2. Retrieve part number 21
# 3. Retrieve aligator product
# 4. Get all products with quantity of 1

apiUri=database_query/v1/products
part_number="part_number=120"
product_name="product_name=pencil"
quantity="quantity=1000"

/var/lib/jenkins/cloudctl-login.sh
port=$(kubectl describe service ace-jenkins-release-ibm-ace-server-icip-prod  -n icp4i | grep ace-http | grep -v https | grep NodePort | tr -s " " | cut -d' ' -f3 | cut -d/ -f1)

nodeIP=$(kubectl get configmap -n kube-public ibmcloud-cluster-info   -o jsonpath="{.data.cluster_address}")

echo "Sleep for container to start up."
sleep 20

echo "Test 01: Curling http://${nodeIP}:${port}/${apiUri}"

curl http://${nodeIP}:${port}/${apiUri} | grep last_updated

if [ $? != 0 ]; then
   echo "Test 01 failed"
   exit 78
fi

echo "Test 02: Curling http://${nodeIP}:${port}/${apiUri}?${part_number}"

curl http://${nodeIP}:${port}/${apiUri}?${part_number} | grep 120

if [ $? != 0 ]; then
   echo "Test 02 failed"
   exit 78
fi

echo "Test 03: Curling http://${nodeIP}:${port}/${apiUri}?${product_name}"

curl http://${nodeIP}:${port}/${apiUri}?${product_name} | grep pencil

if [ $? != 0 ]; then
   echo "Test 03 failed"
   exit 78
fi

echo "Test 04: Curling http://${nodeIP}:${port}/${apiUri}?${quantity}"

curl http://${nodeIP}:${port}/${apiUri}?${quantity} | grep quantity | grep "1000"

if [ $? != 0 ]; then
   echo "Test 04 failed"
   exit 78
fi

echo "API test completed - Success"
