# Rol de Gestión de Usuarios Nexus

Este rol automatiza la creación y gestión de usuarios y roles en Nexus Repository Manager utilizando la API REST.

## Funcionalidades

*   **Creación de Roles Personalizados**: Define roles con privilegios específicos (ej. `nx-developer`).
*   **Aprovisionamiento de Usuarios**: Crea o actualiza usuarios basándose en un archivo JSON de definición.
*   **Gestión de Contraseñas**: Asigna contraseñas iniciales a los usuarios.

## Estructura

*   `tasks/main.yaml`: Contiene la lógica para llamar a la API de Nexus.
*   `files/users.json`: Archivo de datos que define la lista de usuarios a crear.
*   `vars/main.yaml`: Variables de configuración (credenciales de admin, URL de Nexus).

## Requisitos

*   Nexus debe estar en ejecución y accesible vía HTTP en `localhost:8081` (o la URL configurada) desde la máquina donde se ejecuta el rol.
*   Se requieren credenciales de administrador de Nexus para ejecutar estas tareas.

## Cómo añadir usuarios

Para añadir nuevos usuarios, edita el archivo `files/users.json`. Consulta el archivo `files/README.md` para ver la documentación detallada del formato JSON.
