#!/bin/bash


echo "Spinning up four VMs/droplets..."

for i in 1 2 3 4; do
  docker-machine create \
    devnode-$i;
done


echo "Initializing Swarm mode..."

docker-machine ssh devnode-1 -- docker swarm init --advertise-addr $(docker-machine ip devnode-1)


echo "Adding the nodes to the Swarm..."

TOKEN=`docker-machine ssh devnode-1 docker swarm join-token worker | grep token | awk '{ print $5 }'`

for i in 2 3 4; do
  docker-machine ssh devnode-$i \
    -- docker swarm join --token ${TOKEN} $(docker-machine ip devnode-1):2377;
done


echo "Creating secret..."

eval $(docker-machine env node-1)
echo "3vaGO" | docker secret create secret_code -


echo "Deploying the Flask microservice..."

docker stack deploy --compose-file=docker-compose-swarm.yml flask


echo "Create the DB table and apply the seed..."

sleep 60
NODE=$(docker service ps -f "desired-state=running" --format "{{.Node}}" flask_web)
eval $(docker-machine env $NODE)
CONTAINER_ID=$(docker ps --filter name=flask_web --format "{{.ID}}")
docker container exec -it $CONTAINER_ID python manage.py recreate_db
docker container exec -it $CONTAINER_ID python manage.py seed_db


echo "Get the IP address..."

sleep 10
eval $(docker-machine env devnode-1)
docker-machine ip $(docker service ps -f "desired-state=running" --format "{{.Node}}" flask_nginx)
