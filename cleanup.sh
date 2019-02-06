#!/bin/bash

num=`docker-machine ls --filter name=devnode --format "{{.Name}}" | wc -l`

for ((i=1; i <= $num; i++)) ; do
  docker-machine rm -y \
    devnode-$i;
done
