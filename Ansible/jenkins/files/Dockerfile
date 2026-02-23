FROM jenkins/jenkins:lts

# Usuario root para instalar paquetes
USER root

# Crear directorios y copiar configuraciones
RUN mkdir -p /var/jenkins_home/casc_configs
COPY jcasc/ /var/jenkins_home/casc_configs/
COPY jobs/ /var/jenkins_home/jobs/
COPY pipelines/ /var/jenkins_home/pipelines/
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

RUN chown -R jenkins:jenkins /var/jenkins_home

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs