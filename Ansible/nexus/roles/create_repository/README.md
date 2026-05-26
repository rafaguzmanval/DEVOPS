# Rol Genérico para Crear Repositorios en Nexus

Este rol permite crear cualquier tipo de repositorio soportado por Nexus (Maven, NPM, Docker, Raw, PyPI, etc.) pasando la configuración como variables.

## Variables Requeridas

*   `repo_format`: El formato del repositorio (ej. `maven`, `npm`, `docker`, `raw`).
*   `repo_type`: El tipo de repositorio (`hosted`, `proxy`, `group`).
*   `repository_config`: Un diccionario con la configuración completa del repositorio según la API de Nexus.

## Ejemplo de Uso

Para crear un repositorio **Maven Hosted**:

```yaml
- name: Crear repositorio Maven Releases
  include_role:
    name: create_repository
  vars:
    repo_format: "maven"
    repo_type: "hosted"
    repository_config:
      name: "maven-releases-custom"
      online: true
      storage:
        blobStoreName: "default"
        writePolicy: "ALLOW"
      maven:
        versionPolicy: "RELEASE"
        layoutPolicy: "STRICT"
```

Para crear un repositorio **NPM Proxy**:

```yaml
- name: Crear repositorio NPM Proxy
  include_role:
    name: create_repository
  vars:
    repo_format: "npm"
    repo_type: "proxy"
    repository_config:
      name: "npm-proxy"
      online: true
      storage:
        blobStoreName: "default"
      proxy:
        remoteUrl: "https://registry.npmjs.org"
        contentMaxAge: 1440
        metadataMaxAge: 1440
      negativeCache:
        enabled: true
        timeToLive: 1440
```

## Referencia API

Consulta la documentación de la API de Nexus (`/service/rest/swagger.json` en tu instancia) para ver los campos requeridos en `repository_config` para cada formato.
