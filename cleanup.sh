#!/bin/bash

num=`docker-machine ls --filter name=devnode --format "{{.Name}}" | wc -l`

until [ $num -eq 0 ]; 
do
    docker-machine rm -y \
    devnode-$i;
done

