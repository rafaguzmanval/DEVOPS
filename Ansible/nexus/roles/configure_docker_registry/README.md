# Rol de Configuración de Docker Registry

Este rol configura Nexus para actuar como un Docker Registry privado. Es un **rol de composición** que orquesta la ejecución de múltiples roles genéricos.

## Qué hace

1.  **Activa el Realm `DockerToken`** (usando el rol `activate_realm`)
2.  **Crea un Blob Store** llamado `docker-blobstore` (usando el rol `create_blobstore`)
3.  **Crea un repositorio Docker Hosted** en el puerto 8082 (usando el rol `create_repository`)

El repositorio se configura con:
- **Puerto HTTP interno**: 8082 (proxied por Nginx en el puerto 8444 con SSL)
- **Autenticación**: Deshabilitada por defecto (`requireAuthentication: false`) para permitir pull anónimo
- **Force Basic Auth**: Habilitado para mayor seguridad en push

## Variables

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `nexus_docker_http_port` | Puerto HTTP interno para el conector Docker | `8082` |
| `blobstore_name` | Nombre del Blob Store a crear | `docker-blobstore` |

## Ejecución

Se recomienda usar el script `configure_docker.sh` desde la raíz del proyecto:

```bash
./configure_docker.sh
```

O ejecutar directamente el playbook:

```bash
ansible-playbook -i inventory init_nexus.yaml \
  -e "role_to_execute=configure_docker_registry" \
  -e "nexus_admin_password=TU_PASSWORD"
```

## Dependencias

Este rol depende de la existencia de los siguientes roles en el proyecto:
*   `activate_realm`
*   `create_blobstore`
*   `create_repository`
