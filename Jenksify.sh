echo "Build a testCI job for all the previous :D ...."
      
sleep 10
   
eval $(docker-machine env $MANAGER)
CONTAINER_ID=$(docker ps --filter name=jenkinsCI --format "{{.ID}}")
JENKINS_USER=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-user)   
JENKINS_USER=$(echo -n $JENKINS_USER | tr -d '\r')   
JENKINS_PASS=$(docker container exec -it $CONTAINER_ID cat /run/secrets/jenkins-pass)    
JENKINS_PASS=$(echo -n $JENKINS_PASS | tr -d '\r')   
#JENKINS_CRUMB=$(curl -s "http://${MANAGER_IP}:8888/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u "$JENKINS_USER:$JENKINS_PASS")
     
curl -s -XPOST "http://${MANAGER_IP}:8888/createItem?name=testCI" \    
    -u ${JENKINS_USER}:${JENKINS_PASS} \   
    --data-binary @testCI.xml \ 
    -H "Content-Type:text/xml"
