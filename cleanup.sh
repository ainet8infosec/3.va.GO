num=`docker-machine ls --filter name=devnode --format "{{.Name}}" | wc -l`

if [ "$num" -ne "0" ]; 
then
  docker-machine rm -y \
  $(docker-machine ls -q | grep devnode-);
fi
