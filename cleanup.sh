#!/bin/bash

num=`docker-machine ls --filter name=devnode --format "{{.Name}}" | wc -l`

until [ ! "$(docker-machine ls | grep 'devnode-')" ]; 
do
    docker-machine rm -y \
    devnode-$i;
done

