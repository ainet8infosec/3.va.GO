FROM jenkinsci/jenkins:lts
      
USER root
          
RUN apt-get update -qq \   
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common    
        
RUN curl -fsSL https://get.docker.com -o get-docker.sh

RUN chmod +x get-docker.sh

RUN sh get-docker.sh
 
RUN usermod -aG docker jenkins
