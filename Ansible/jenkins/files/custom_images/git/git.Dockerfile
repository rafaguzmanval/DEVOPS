# Usamos Alpine como base por su ligereza
FROM alpine:latest

# Instalamos git y bash (bash es útil para scripts de Jenkins más complejos)
# openssh es necesario si usas llaves SSH para clonar
RUN apk add --no-cache \
    git \
    bash \
    openssh-client \
    ca-certificates

CMD ["/bin/sh"]