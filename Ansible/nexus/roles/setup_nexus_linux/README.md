# Rol de Instalación de Nexus Repository Manager

Este rol de Ansible se encarga de instalar y configurar Sonatype Nexus Repository Manager en servidores Linux, incluyendo la configuración de un proxy inverso Nginx con soporte SSL/TLS.

## Funcionalidades

*   **Instalación de Java**: Instala OpenJDK 17 (requerido por las versiones recientes de Nexus).
*   **Instalación de Nexus**: Descarga, instala y configura el servicio systemd para Nexus.
*   **Proxy Inverso Nginx**: Instala y configura Nginx para manejar la terminación SSL y redirigir el tráfico a Nexus.
*   **Soporte Docker Registry**: Configura puertos específicos para permitir `docker login` y push/pull de imágenes de forma segura.
*   **Optimización**: Ajustes de Nginx para permitir la subida de artefactos grandes (hasta 10GB).

## Arquitectura de Puertos

*   **443 (HTTPS)**: Puerto principal de acceso a la interfaz web y repositorios estándar (Maven, NPM, etc.). Proxied a `localhost:8081`.
*   **8444 (HTTPS)**: Puerto dedicado para el Docker Registry seguro. Proxied a `localhost:8082`.
*   **80 (HTTP)**: Redirección automática a HTTPS.

## Variables Principales (`vars/main.yaml`)

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `nexus_version` | Versión específica de Nexus a instalar | `3.86.2-01-linux-x86_64` |
| `ssl_port` | Puerto HTTPS principal (Nginx) | `443` |
| `docker_ssl_port` | Puerto HTTPS para Docker Registry | `8444` |
| `nexus_docker_http_port` | Puerto interno HTTP de Nexus para Docker | `8082` |
| `url` | Nombre de dominio del servidor | `nexus02.boyaca.es` |
| `nginx_ssl_dir` | Directorio para certificados en Nginx | `/etc/nginx/ssl` |

## Certificados SSL

El rol espera que los certificados se pasen desde el controlador (máquina que ejecuta Ansible). **No guardes certificados en el repositorio**.

Se requieren dos archivos en la máquina destino (copiados automáticamente por el rol):
1.  `fullchain.pem`: Certificado público + cadena de confianza.
2.  `boyaca-key.pem`: Clave privada.

## Acceso Inicial y Contraseña de Admin

Tras la primera instalación, Nexus genera una contraseña aleatoria para el usuario `admin`.

**Método Automático:**
El playbook de Ansible esperará a que se genere esta contraseña y:
1. La mostrará al final de la ejecución en un bloque destacado en el log.
2. La guardará automáticamente en el archivo `nexus_admin_password.txt` en el directorio desde donde ejecutaste Ansible.

```
========================================================
INITIAL NEXUS ADMIN PASSWORD:
<tu-contraseña-aleatoria>
========================================================
```

**Método Alternativo (Manual):**
Si por alguna razón no ves la contraseña en el log o perdiste el archivo, puedes obtenerla accediendo al servidor:

```bash
# Si estás usando Vagrant:
vagrant ssh -c "sudo cat /opt/sonatype-work/nexus3/admin.password"

# Si tienes acceso SSH directo:
sudo cat /opt/sonatype-work/nexus3/admin.password
```

**Importante**: El archivo `admin.password` se elimina automáticamente después del primer cambio de contraseña. Guarda la contraseña en un lugar seguro.

Usa esta contraseña junto con el usuario `admin` para iniciar sesión por primera vez. El asistente de configuración te pedirá que la cambies inmediatamente.

## Uso

Este rol suele ser invocado desde un playbook principal o un entorno Vagrant. Asegúrate de definir las rutas a los certificados locales en las variables `ssl_cert_path` y `ssl_key_path`.
