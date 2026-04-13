FROM jenkins/inbound-agent:latest-alpine3.22-jdk17
LABEL protected="true"
# Instalar Docker
USER root
RUN apk add --no-cache \
  docker \
  docker-compose \
  shadow
# Configuracion del grupo Docker
RUN grep -q docker /etc/group || addgroup -S docker && \
  addgroup jenkins docker && \
  mkdir -p /var/lib/docker && \
  chown jenkins:docker /var/lib/docker

VOLUME /var/lib/docker