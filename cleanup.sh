num=`docker-machine ls --filter name=devnode --format "{{.Name}}" | wc -l`

if [ "$(docker-machine ls | grep -w 'devnode-10')" ]; 
then
  for ((i=$num+3; i <= 2*($num+1); i++)) ; do
    docker-machine rm -y \
    devnode-$i;
  done
fi

if [ "$(docker-machine ls | grep -w 'devnode-1')" ]; 
  for ((i=1; i <= $num; i++)) ; do
    docker-machine rm -y \
    devnode-$i;
  done
fi
