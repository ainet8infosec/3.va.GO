####1. Docker's Swarm (especially on the hybrid cloud env paradigm) -or Kubernetes container orchestrator- is the means to handle excess workload in a scalable and balanced way and to ease the high-availability and 0-downtime deployments concerns.

####2. Segregating ELK's network traffic from the FLASK webapp one (in a front-end vs. backend net fashion) will smooth the capacity spikes, ie one can't afford logging/presenting-logs done in-band the production customer-facing net, rather employ a secondary OOB net/VLAN attached to each monitored service to host all ELK traffic and services.

####3. Instead of using a local, containerized Docker registry one can of course push/pull images from DockerHub or any other valid DTR. The advantage of the local DTR container lies in when a more private approach for keeping image artefacts is perhaps needed or whent the on-the-fly need is the primary driver.

####4. Dockerizing the CI/CD agent just brings one step closer to the whole notion of infra-as-code.

####5. With Docker secrets off-hook creation/update as the foundation and a dockerized-Jenkins Credential Store as the pavement this is the way to convey credentials throughout code's lifetime across the DevOps LifeCycle. 
