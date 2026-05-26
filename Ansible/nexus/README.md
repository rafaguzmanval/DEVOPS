# Proyecto de Automatización de Nexus con Ansible

Este proyecto contiene los playbooks y roles de Ansible necesarios para desplegar, configurar y gestionar una instancia completa de Sonatype Nexus Repository Manager con soporte SSL/TLS mediante Nginx.

## Estructura del Proyecto

```
.
├── init_nexus.yaml          # Playbook principal parametrizado
├── deploy_nexus.sh          # Script: Paso 1 - Instalación Base
├── manage_users.sh          # Script: Paso 2 - Gestión Usuarios
├── roles/
│   ├── setup_nexus_linux/   # [Instalación Base (Java, Nexus, Nginx)](roles/setup_nexus_linux/README.md)
│   ├── activate_realm/      # Rol genérico: Activar Realms de seguridad
│   ├── create_blobstore/    # Rol genérico: Crear Blob Stores
│   ├── create_repository/   # [Rol genérico: Crear repositorios](roles/create_repository/README.md)
│   ├── configure_docker_registry/ # [Configuración Docker Registry](roles/configure_docker_registry/README.md)
│   └── add_users/           # [Gestión de Usuarios](roles/add_users/README.md)
└── README.md                # Este archivo
```

## Arquitectura de Roles

El proyecto sigue una arquitectura modular con roles genéricos reutilizables:

- **Roles Atómicos**: `activate_realm`, `create_blobstore`, `create_repository` - Operaciones individuales
- **Roles de Composición**: `configure_docker_registry` - Orquesta múltiples roles atómicos
- **Roles de Infraestructura**: `setup_nexus_linux` - Instalación base del sistema
- **Roles de Gestión**: `add_users` - Administración de usuarios

## Flujo de Despliegue (Paso a Paso)

### Paso 1: Instalación Base

Despliega Nexus, instala Java y configura Nginx como proxy inverso SSL.

```bash
# Define dónde están tus certificados (fullchain.pem y boyaca-key.pem)
export NEXUS_CERT_DIR="/ruta/a/tus/certificados"
./deploy_nexus.sh
```

**Al finalizar:**
1.  La contraseña inicial de `admin` se mostrará en el log de Ansible.
2.  También se guardará automáticamente en el archivo `nexus_admin_password.txt` (en el directorio actual).
3.  Entra en la web (`https://nexus02.boyaca.es`) y cambia la contraseña.
4.  Deshabilita el acceso anónimo cuando se te pregunte.

### Paso 2: Configuración de Docker Registry (Opcional)

Si necesitas usar Nexus como Docker Registry:

```bash
./configure_docker.sh
```

Este script ejecuta el rol `configure_docker_registry` que:
- Activa el Realm `DockerToken`
- Crea un Blob Store dedicado para Docker
- Crea el repositorio `docker-hosted` en el puerto 8082 (proxied por Nginx en 8444)

*Te pedirá la contraseña de admin que estableciste en el paso anterior.*

### Paso 3: Gestión de Usuarios

Crea roles y usuarios adicionales según el archivo `roles/add_users/files/users.json`.

```bash
./manage_users.sh
```

## Acceso al Servicio

*   **Web UI**: `https://nexus02.boyaca.es`
*   **Docker Registry**: `nexus02.boyaca.es:8444`

### Uso del Docker Registry

1.  **Login**:
    ```bash
    docker login nexus02.boyaca.es:8444
    ```

2.  **Push**:
    ```bash
    docker tag nginx:latest nexus02.boyaca.es:8444/mi-nginx:v1
    docker push nexus02.boyaca.es:8444/mi-nginx:v1
    ```

3.  **Pull**:
    ```bash
    docker pull nexus02.boyaca.es:8444/mi-nginx:v1
    ```

## Creación de Repositorios Adicionales

Puedes crear repositorios de otros formatos (Maven, NPM, PyPI, etc.) usando el rol genérico `create_repository`. Consulta su [README](roles/create_repository/README.md) para ejemplos.

## Solución de Problemas Comunes

*   **Error de Certificado en Docker**: Si usas una IP en lugar del dominio, Docker fallará. Usa el nombre de dominio configurado en el certificado o añade la IP a `insecure-registries` en `/etc/docker/daemon.json`.
*   **Contraseña perdida**: Si no anotaste la contraseña inicial, revisa el archivo `nexus_admin_password.txt` generado durante el despliegue.

## Documentación Detallada

*   📘 **[Instalación y Configuración (Nginx, SSL)](roles/setup_nexus_linux/README.md)**
*   🐳 **[Configuración Docker Registry](roles/configure_docker_registry/README.md)**
*   🔧 **[Crear Repositorios Genéricos](roles/create_repository/README.md)**
*   👥 **[Gestión de Usuarios](roles/add_users/README.md)**
*   📝 **[Formato users.json](roles/add_users/files/README.md)**