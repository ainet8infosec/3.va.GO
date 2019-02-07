node('docker') {
 
    stage 'Checkout'
        checkout scm
    stage 'Prerequisites'
            sh "docker service create --name docker-visualizer \
               --publish 8080:8080 \
               --constraint 'node.role == manager' \
               --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
            dockersamples/visualizer:latest"
            sh "docker service create --name docker-registry --publish 50000:5000 registry:2"
    stage 'Build & UnitTest'
        sh "docker build -t localhost:50000/flask-docker-swarm_web:latest -f ./services/web/Dockerfile ./services/web" 
        sh "docker push localhost:50000/flask-docker-swarm_web:latest"
        sh "docker build -t localhost:50000/flask-docker-swarm_db:latest -f ./services/db/Dockerfile ./services/db"
        sh "docker push localhost:50000/flask-docker-swarm_db:latest"
        sh "docker build -t localhost:50000/flask-docker-swarm_nginx:latest -f ./services/nginx/Dockerfile ./services/nginx"
        sh "docker push localhost:50000/flask-docker-swarm_nginx:latest"
  
    stage 'Stack Integration'
        sh "docker stack deploy -compose-file=docker-compose-flask-stack.yml flask_elk"
 
}
