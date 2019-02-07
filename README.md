# A Trip, A Vacation... Just Go!

### Source of Inspiration 1 --> https://testdriven.io/blog/running-flask-on-docker-swarm/
### Source of Inspiration 2 --> https://botleg.com/stories/log-management-of-docker-swarm-with-elk-stack/
### Source of Inspiration 3 --> https://medium.com/@manav503/how-to-build-docker-images-inside-a-jenkins-container-d59944102f30
### Source of Inspiration 4 --> https://code-maze.com/ci-jenkins-docker/
### Source of Inspiration 5 -->https://support.cloudbees.com/hc/en-us/articles/220857567-How-to-create-a-job-using-the-REST-API-and-cURL-

##### Prerequisite 1 --> https://docs.docker.com/machine/
##### Prerequisite 2 --> https://www.virtualbox.org/

Assuming a 16GB-min-RAM DEV *niX node with latest docker-ce installed, alongside docker-machine and virtualbox for Docker Swarm enablement and simulation.

### Approach A

Clone this repo and run a first deployment with `$ sh deploy.sh`

Expected Dockerized Outcome --> NGINX+FLASK+POSTGRES+ELK+VISUALIZER+PORTAINER+JENKINSCI 

Visualizer accessible via HTTP at IP `docker-machine devnode-1 ip` PORT 8080.

Portainer accessible via HTTP at IP `docker-machine devnode-1 ip` PORT 9000.

JenkinsCI accessible via HTTP at IP `docker-machine devnode-1 ip` PORT 8888.

NGINX FLASK frontend accessible via HTTP at IP `docker-machine devnode-1 ip` PORT 80

    >available context-path /users for retrieving users table from POSTGRES via JSON

    >available context-path /ping for a plain pong JSON reply
 
KIBANA dashboard accessible via HTTP at IP `docker-machine devnode-1 ip` PORT 15601

For Kibana's Dashboard initial parametrization (quote from Inspiration ref#2) >>>>

    >The first time kibana is opened, it will ask to specify a default index pattern. Logstash will create index starting with logstash-, so the default index pattern is logstash-*. Also the Time-field name is @timestamp. This is the field that stores the time when the log entry is made. Click on the Create button to set it up. Now go to the Discover tab to see all the log entries. To the left, you can see all the fields indentified from the logs. If you click on any field, you can see the top values and its percentages. The docker.image field will give the docker image used, the docker.name field gives the container name, etc.

Cleanup everything after playing around via `$ sh cleanup.sh`

### Approach B

Do A but don't cleanup

#### PS: Easter-egg GO!!!!
