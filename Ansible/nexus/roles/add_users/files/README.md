# Guía para Añadir Usuarios a Nexus

Este directorio contiene el archivo `users.json` que actúa como fuente de verdad para los usuarios aprovisionados en Nexus.

## Cómo añadir un nuevo usuario

Para dar de alta un nuevo usuario, edita el archivo `users.json` y añade un nuevo objeto al array principal siguiendo este formato:

```json
{
    "userId": "jdoe",                  // ID único del usuario (login)
    "firstName": "John",               // Nombre
    "lastName": "Doe",                 // Apellido
    "emailAddress": "jdoe@boyaca.es",  // Correo electrónico
    "source": "default",               // Siempre "default" para usuarios locales
    "status": "active",                // "active" o "disabled"
    "readOnly": false,                 // false permite modificar su perfil
    "roles": [                         // Lista de roles asignados
        "nx-developer",                // Rol personalizado para desarrolladores
        "nx-anonymous"                 // Otros roles...
    ],
    "externalRoles": [],               // Dejar vacío para usuarios locales
    "password": "PasswordSeguro123!"   // Contraseña inicial
}
```

### Roles Disponibles

*   **nx-admin**: Administrador total del sistema.
*   **nx-anonymous**: Acceso de solo lectura anónimo.
*   **nx-developer**: Rol personalizado con permisos para:
    *   Subir componentes (`nx-component-upload`)
    *   Leer y navegar repositorios
    *   Ver estado de salud (Healthcheck)
    *   Gestión completa de repositorios Docker

### Notas Importantes

1.  **Sintaxis JSON**: Asegúrate de que el JSON sea válido. Si añades un usuario al final, recuerda poner una coma `,` en el objeto anterior. El último objeto no debe llevar coma final.
2.  **Contraseñas**: Las contraseñas aquí están en texto plano para el aprovisionamiento inicial. Se recomienda que los usuarios cambien su contraseña tras el primer inicio de sesión.
3.  **IDs Únicos**: El campo `userId` no puede repetirse.

### Ejemplo de archivo con múltiples usuarios

```json
[
    {
        "userId": "admin_infra",
        "firstName": "Admin",
        "lastName": "Infra",
        "emailAddress": "admin@boyaca.es",
        "source": "default",
        "status": "active",
        "readOnly": false,
        "roles": ["nx-admin"],
        "externalRoles": [],
        "password": "AdminPassword1"
    },
    {
        "userId": "dev01",
        "firstName": "Developer",
        "lastName": "Uno",
        "emailAddress": "dev01@boyaca.es",
        "source": "default",
        "status": "active",
        "readOnly": false,
        "roles": ["nx-developer"],
        "externalRoles": [],
        "password": "DevPassword1"
    }
]
```
