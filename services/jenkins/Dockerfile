FROM jenkinsci/jenkins:lts
      
USER root

# Install Jenkins as auto as possible (no setup-wizard) 

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

COPY community-plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

RUN apt-get update -qq \   
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common   
    
# Install latest DOCKER-CE using the convenience script
        
RUN curl -fsSL https://get.docker.com -o get-docker.sh

RUN chmod +x get-docker.sh

RUN sh get-docker.sh
 
RUN usermod -aG docker jenkins
