# Not the best, consider alpine 
FROM jenkinsci/jenkins:lts

# Not the best, consider sudoer
USER root

# Installs Jenkins as auto as possible (no setup-wizard) 

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

COPY community-plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

RUN apt-get update -qq \   
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common   
    
# Installs latest DOCKER-CE using the convenience script
        
RUN curl -fsSL https://get.docker.com -o get-docker.sh

RUN chmod +x get-docker.sh

RUN sh get-docker.sh
 
RUN usermod -aG docker jenkins

# Installs docker-compose
# RUN curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" \
#      -o /usr/local/bin/docker-compose
      
# RUN chmod +x /usr/local/bin/docker-compose
