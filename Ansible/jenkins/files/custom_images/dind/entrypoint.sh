#!/bin/sh

# Iniciar el demonio de Docker en segundo plano usando el binario de Alpine
# --host=unix:///var/run/docker.sock permite conexiones locales
dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 &

# Esperar a que el socket de Docker esté disponible
echo "Esperando a que el demonio de Docker arranque..."
while ! docker info >/dev/null 2>&1; do
  echo "Todavía esperando..."
  sleep 1
done

echo "¡Docker está en marcha!"

# Si se pasan argumentos, ejecutar el agente de Jenkins
# Si no, simplemente abrir una shell (sh)
if [ $# -eq 0 ]; then
    exec sh
else
    exec /usr/local/bin/jenkins-agent "$@"
fi