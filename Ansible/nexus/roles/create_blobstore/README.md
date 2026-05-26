# Rol Genérico: Crear Blob Store

Este rol crea un Blob Store de tipo File en Nexus. Los Blob Stores son áreas de almacenamiento donde Nexus guarda los artefactos.

## Uso

Este rol se invoca típicamente desde otros roles de composición. Ejemplo:

```yaml
- name: Crear Blob Store para Maven
  include_role:
    name: create_blobstore
  vars:
    blobstore_name: "maven-releases"
    blobstore_path: "maven-releases"  # Opcional
```

## Variables

| Variable | Descripción | Requerido | Por defecto |
|----------|-------------|-----------|-------------|
| `blobstore_name` | Nombre del Blob Store | Sí | - |
| `blobstore_path` | Ruta en disco donde se almacenarán los datos | No | Mismo que `blobstore_name` |

## Comportamiento

- Si el Blob Store ya existe (código 400), la tarea no falla y se marca como "ok" (sin cambios)
- Si se crea exitosamente (código 201 o 204), se marca como "changed"
- Los Blob Stores se crean en `/opt/sonatype-work/nexus3/blobs/` por defecto

## Buenas Prácticas

- Usa Blob Stores separados para diferentes tipos de repositorios (Maven, Docker, NPM, etc.)
- Esto facilita la gestión de espacio y backups selectivos
- Los nombres deben ser descriptivos: `docker-images`, `maven-releases`, `npm-packages`, etc.
