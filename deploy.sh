#!/bin/bash

echo "Spinning up five 2GB RAM VMs/droplets..."

for i in 1 2 3 4 5; do
  docker-machine create -d virtualbox \
    --virtualbox-memory 2048 \
    devnode-$i;
done

MANAGER=devnode-1
MANAGER_IP=$(docker-machine ip $MANAGER)

echo "Initializing Swarm mode, first node is the manager..."

docker-machine ssh $MANAGER -- docker swarm init --advertise-addr $MANAGER_IP

echo "Adding rest nodes as workers to the Swarm..."

TOKEN=`docker-machine ssh $MANAGER docker swarm join-token worker | grep token | awk '{ print $5 }'`

for i in 2 3 4 5; do
  docker-machine ssh devnode-$i \
    -- docker swarm join --token ${TOKEN} $MANAGER_IP:2377;
done

echo "Preparing Swarm manager to handle helper services..."

docker-machine ssh $MANAGER \
  -- sudo mkdir -p /host/data /host/data2

echo "Preparing Swarm nodes to handle ELK stack..."

for i in 1 2 3 4 5; do
  docker-machine ssh devnode-$i \
    -- sudo sysctl -w vm.max_map_count=262144
done

echo "Creating secrets..."

eval $(docker-machine env $MANAGER)
echo "3.va.GO" | docker secret create secret_code -
echo "admin" | docker secret create jenkins_user -
echo "changeME" | docker secret create jenkins_pass -

echo "Create a docker visualizer helper service on the manager node!!!!"

docker service create --name docker-visualizer \
    --publish 8080:8080 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    dockersamples/visualizer:latest

echo "Create a local DTR"

docker service create --name docker-registry --publish 50000:5000 registry:2

echo "Build Flask images and push them to local DTR"

docker build -t localhost:50000/flask-docker-swarm_web:latest -f ./services/web/Dockerfile ./services/web
docker push localhost:50000/flask-docker-swarm_web:latest

docker build -t localhost:50000/flask-docker-swarm_db:latest -f ./services/db/Dockerfile ./services/db
docker push localhost:50000/flask-docker-swarm_db:latest

docker build -t localhost:50000/flask-docker-swarm_nginx:latest -f ./services/nginx/Dockerfile ./services/nginx
docker push localhost:50000/flask-docker-swarm_nginx:latest

echo "Deploying the Flask microservices..."

docker stack deploy --compose-file=docker-compose-flask-stack.yml flask_elk

echo "Create the DB table and apply the seed..."

sleep 60
NODE=$(docker service ps -f "desired-state=running" --format "{{.Node}}" flask_elk_web)
eval $(docker-machine env $NODE)
CONTAINER_ID=$(docker ps --filter name=flask_elk_web --format "{{.ID}}")
docker container exec -it $CONTAINER_ID python manage.py recreate_db
docker container exec -it $CONTAINER_ID python manage.py seed_db

echo "Get the IP address..."

sleep 10
eval $(docker-machine env $MANAGER)
echo "NGINX is running on..."
docker-machine ip $(docker service ps -f "desired-state=running" --format "{{.Node}}" flask_elk_nginx)

echo "Build ELK images and push them to local DTR"

docker build -t localhost:50000/logstash:5.3.2 -f ./services/elk/logstash/Dockerfile ./services/elk/logstash
docker push localhost:50000/logstash:5.3.2

echo "Populate the flask_elk stack with ELK services...."

docker stack deploy --compose-file=docker-compose-elk-stack.yml flask_elk
sleep 60

echo "Bring up rest CI/CD and MGMT services (Portainer, JenkinsCI etc.)...."

eval $(docker-machine env $MANAGER)

docker service create \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/host/data,dst=/data \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    portainer/portainer \
    -H unix:///var/run/docker.sock

docker build -t localhost:50000/jenkins-docker:latest -f ./services/jenkins/Dockerfile ./services/jenkins
docker push localhost:50000/jenkins-docker:latest

docker service create \
    --name jenkinsCI \
    --publish 8888:8080 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/host/data2,dst=/data2 \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --secret source=jenkins-user,target=jenkins-user \ 
    --secret source=jenkins-pass,target=jenkins-pass \
    --network flask_elk_default \
    localhost:50000/jenkins-docker:latest
    
echo "Build a testCI job for all the previous :D ...."

eval $(docker-machine env $MANAGER)
CONTAINER_ID=$(docker ps --filter name=jenkinsCI --format "{{.ID}}")
JENKINS_USER=$(docker container exec -it $CONTAINER_ID 'cat /run/secrets/jenkins-user')
JENKINS_PASS=$(docker container exec -it $CONTAINER_ID 'cat /run/secrets/jenkins-pass')
curl -s -XPOST "http://$MANAGER_IP:8888/createItem?name=testCI" \
    -u "$JENKINS_USER:$JENKINS_PASS" \
    --data-binary @testCI.xml \
    -H "Content-Type:text/xml"

