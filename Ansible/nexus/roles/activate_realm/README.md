# Rol Genérico: Activar Realm

Este rol activa un Realm de seguridad en Nexus. Los Realms controlan cómo Nexus autentica a los usuarios.

## Uso

Este rol se invoca típicamente desde otros roles de composición. Ejemplo:

```yaml
- name: Activar Docker Token Realm
  include_role:
    name: activate_realm
  vars:
    realm_id: "DockerToken"
```

## Variables Requeridas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `realm_id` | ID del Realm a activar | `DockerToken`, `NuGetApiKey`, `NpmToken` |

## Realms Comunes

- **DockerToken**: Necesario para autenticación Docker
- **NuGetApiKey**: Para repositorios NuGet
- **NpmToken**: Para repositorios NPM
- **NexusAuthenticatingRealm**: Realm por defecto (siempre activo)

## Comportamiento

El rol:
1. Obtiene la lista actual de Realms activos
2. Añade el nuevo Realm si no está ya activado
3. Preserva todos los Realms existentes
