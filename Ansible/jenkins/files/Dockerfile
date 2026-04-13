FROM jenkins/jenkins:lts

USER root

# Instalamos paquetes si fuera necesario (ej: maven, git...)
# RUN apt-get update && apt-get install -y maven

# Copiamos a la carpeta de REFERENCIA, no directamente al home
COPY jcasc/ /usr/share/jenkins/ref/casc_configs/
COPY scripts/ /usr/share/jenkins/ref/casc_configs/
COPY jobs/ /usr/share/jenkins/ref/jobs-config/
COPY pipelines/ /usr/share/jenkins/ref/pipelines/
# Esta es la ruta clave para el init.groovy
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# La variable de entorno debe apuntar a donde vivirá el archivo finalmente
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs