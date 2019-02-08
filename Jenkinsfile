node('master') {
 
    stage 'Checkout'
        echo 'Fetching code from repo.....'
        checkout scm
 
    stage 'Prerequisites'
        echo 'Adding Docker Visualizer and a local Docker Trusted Registry as SWARM services'
        sh "docker service create --name docker-visualizer \
            --publish 8080:8080 \
            --constraint 'node.role == manager' \
            --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
          dockersamples/visualizer:latest"
        sh "docker service create --name docker-registry --publish 50000:5000 registry:2"
 
    stage 'Build Flask Stack Images'
        echo 'Build images from repo Dockerfiles...'
        echo '....& pushing them to the local DTR...'
        sh "docker build -t localhost:50000/flask-docker-swarm_web:latest -f ./services/web/Dockerfile ./services/web" 
        sh "docker push localhost:50000/flask-docker-swarm_web:latest"
        sh "docker build -t localhost:50000/flask-docker-swarm_db:latest -f ./services/db/Dockerfile ./services/db"
        sh "docker push localhost:50000/flask-docker-swarm_db:latest"
        sh "docker build -t localhost:50000/flask-docker-swarm_nginx:latest -f ./services/nginx/Dockerfile ./services/nginx"
        sh "docker push localhost:50000/flask-docker-swarm_nginx:latest"
  
    stage 'Flask Stack Integration'
        echo 'Pull from DTR and Deploy the built Flask images to the SWARM'
        sh "docker stack deploy --compose-file=docker-compose-flask-stack.yml flask_elk"
        sh "sleep 60"
        sh "CONTAINER_ID=${docker ps --filter name=flask_elk_web --format "{{.ID}}"}"
        echo 'Prep-init the DB'
        sh "docker container exec -it ${CONTAINER_ID} python manage.py recreate_db"
        sh "docker container exec -it ${CONTAINER_ID} python manage.py seed_db"
 
    stage 'Test Flask Stack Services'
        echo 'Curl-P-ing...'
        //capture the response
        def response = sh(script: 'curl http://nginx/ping', returnStdout: true)
        echo 'Should be pong ;)'
        //print the response
        echo '=========================Response===================' + response
 
    stage 'Build ELK Stack Images'
        echo 'Build ELK images and push them to local DTR'
        sh "docker build -t localhost:50000/logstash:5.3.2 -f ./services/elk/logstash/Dockerfile ./services/elk/logstash"
        sh "docker push localhost:50000/logstash:5.3.2"
 
    stage 'ELK Stack Integration'
        echo 'Populate the existing flask_elk stack with required ELK services....'
        sh "docker stack deploy --compose-file=docker-compose-elk-stack.yml flask_elk"
        sh "sleep 60"
 
    stage 'GO!!!!'
        echo 'Ready for recreation....Just GO for it!!'
        sh "docker build -t localhost:50000/go4fun:latest -f ./services/go/Dockerfile ./services/go" 
        sh "docker push localhost:50000/go4fun:latest"
        sh "docker service create --name docker-goooo \
            --publish 10100:8000 \
          localhost:50000/go4fun:latest"
        sh "sleep 30"
        def response = sh(script: 'curl http://docker-goooo:10100/q=en.wikipedia.org%2Fwiki%2FTrivago' returnStdout: true)
        //print the response
        echo '=========================Response===================' + response
        figlet 'Trip....Vacation....Just GO!!!!'
 
}
