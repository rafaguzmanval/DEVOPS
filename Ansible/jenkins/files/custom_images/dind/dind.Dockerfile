# Usamos la imagen base que solicitaste
FROM jenkins/inbound-agent:latest-alpine3.22-jdk17

USER root

# 1. Instalar Docker y dependencias necesarias para DinD
RUN apk add --no-cache \
    docker \
    docker-cli-compose \
    iptables \
    ca-certificates \
    openssl

# 2. Configurar el script de inicio
# Necesitamos asegurar que el demonio de docker corra antes que el agente
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Definir el volumen para los datos de Docker
VOLUME /var/lib/docker

# Usamos el script personalizado como entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]