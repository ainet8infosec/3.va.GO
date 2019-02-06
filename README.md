# A Trip, A Vacation... Just Go!

### Source of Inspiration 1 --> https://testdriven.io/blog/running-flask-on-docker-swarm/
### Source of Inspiration 2 --> https://botleg.com/stories/log-management-of-docker-swarm-with-elk-stack/
### Source of Inspiration 3 --> https://medium.com/@manav503/how-to-build-docker-images-inside-a-jenkins-container-d59944102f30

##### Prerequisite 1 --> https://docs.docker.com/machine/
##### Prerequisite 2 --> https://www.virtualbox.org/

Assuming a 16GB-min-RAM DEV *niX node with latest docker-ce installed, alongside docker-machine and virtualbox for Docker Swarm enablement and simulation.

Clone this repo and run a first deployment with `$ sh deploy.sh`

Expected Dockerized Outcome --> NGINX+FLASK+POSTGRES+ELK+VISUALIZER+PORTAINER+JENKINSCI 

Access Visualizer via HTTP at IP `docker-machine devnode-1 ip` PORT 8080.
Access Portainer via HTTP at IP `docker-machine devnode-1 ip` PORT 9000.
Access JenkinsCI via HTTP at IP `docker-machine devnode-1 ip` PORT 8888.
Access NGINX FLASK frontend via HTTP at IP `docker-machine devnode-1 ip` PORT 80
    >explore context-path /users for retrieving users table from POSTGRES via JSON
    >explore context-path /ping for a plain pong JSON reply

Cleanup everything after playing around via `$ sh cleanup.sh`
