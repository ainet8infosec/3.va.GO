#!/bin/bash

echo "APPROACH B"
echo "Spinning up five 2GB RAM VMs/droplets..."

for i in 8 9 10 11 12; do
  docker-machine create -d virtualbox \
    --virtualbox-memory 2048 \
    devnode-$i;
done

MANAGER=devnode-10
MANAGER_IP=$(docker-machine ip $MANAGER)

echo "Initializing Swarm mode, first node is the manager..."

docker-machine ssh $MANAGER -- docker swarm init --advertise-addr $MANAGER_IP

echo "Adding rest nodes as workers to the Swarm..."

TOKEN=`docker-machine ssh $MANAGER docker swarm join-token worker | grep token | awk '{ print $5 }'`

for i in 8 9 11 12; do
  docker-machine ssh devnode-$i \
    -- docker swarm join --token ${TOKEN} $MANAGER_IP:2377;
done

echo "Preparing Swarm manager to handle helper services..."

docker-machine ssh $MANAGER \
  -- sudo mkdir -p /host/data /host/data2

echo "Preparing Swarm nodes to handle ELK stack..."

for i in 8 9 10 11 12; do
  docker-machine ssh devnode-$i \
    -- sudo sysctl -w vm.max_map_count=262144
done

echo "Creating secrets..."

eval $(docker-machine env $MANAGER)
echo "3.va.GO" | docker secret create secret_code -
echo "admin" | docker secret create jenkins_user -
echo "changeME" | docker secret create jenkins_pass -
#Use pwgen 16 to get random 16char string
#echo "Phu1OoGh0quah9th" | docker secret create jenkins_token -

echo "Bring up CI/CD server..."

eval $(docker-machine env $MANAGER)

docker build jenkins-docker:latest -f ./services/jenkins/Dockerfile ./services/jenkins

docker service create \
    --name jenkinsCI \
    --publish 8888:8080 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/host/data2,dst=/data2 \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --secret source=jenkins_user,target=jenkins-user \
    --secret source=jenkins_pass,target=jenkins-pass \
  jenkins-docker:latest

echo "Build a testCI job for all previous approach steps  :D ...."
      
sleep 8
   
eval $(docker-machine env $MANAGER)
CONTAINER_ID=$(docker ps --filter name=jenkinsCI --format "{{.ID}}")
JENKINS_USER=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-user)   
JENKINS_USER=$(echo -n $JENKINS_USER | tr -d '\r')   
JENKINS_PASS=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-pass)    
JENKINS_PASS=$(echo -n $JENKINS_PASS | tr -d '\r')   
JENKINS_PASS=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-pass)     
#JENKINS_TOKEN=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-token)    
#JENKINS_TOKEN=$(echo -n $JENKINS_TOKEN | tr -d '\r')   
#JENKINS_CRUMB=$(curl -s "http://${MANAGER_IP}:8888/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u ${JENKINS_USER}:${JENKINS_PASS})
     
curl -s -XPOST "http://${MANAGER_IP}:8888/createItem?name=testCI" \    
    -u ${JENKINS_USER}:${JENKINS_PASS} \   
    --data-binary @testCI.xml \ 
    -H "Content-Type:text/xml"
    
sleep 8

echo "RUN the testCI job remotely....and NJOY :D !!!!"

curl -s -u ${JENKINS_USER}:${JENKINS_PASS} http://${MANAGER_IP}:8888/job/testCI/build"

echo "That's all folks for APPROACH B!!!!.-"
