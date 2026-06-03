# DEVOPS — Agent Guidance

## Overview

Infrastructure automation collection with 3 Ansible projects + utility scripts. No tests, no CI/CD, no build system. `Dockers/` is a placeholder for future use. Despite README reference, no `CHANGELOG.md` exists.

## Conventions

- Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Semantic Versioning 2.0.0 (MAJOR = breaking role/Docker interface change)
- Target latest stable versions (Jenkins LTS, Nexus 3.x, Semaphore latest)

## Ansible Dispatcher Pattern

Nexus and Semaphore share a universal dispatcher entrypoint:

```
ansible-playbook <playbook>.yaml -e "host=<group> role_to_execute=<role_name>"
```

### Nexus (`Ansible/nexus/init_nexus.yaml`)

Roles: `setup_nexus_linux`, `activate_realm`, `create_blobstore`, `create_repository`, `add_users`, `configure_docker_registry`, `create_npm_group`

Key vars: `nexus_version` (default 3.86.2-01), `url`, `ssl_port` (443), `docker_ssl_port` (8444). Admin password captured from `/opt/sonatype-work/nexus3/admin.password`. Post-install config uses REST API v1 (`uri` module). Idempotent: HTTP 400 = already exists.

### Semaphore (`Ansible/semaphore/semaphoreui.yaml`)

Roles: `install_semaphore`, `uninstall_semaphore`, `setup_new_project`

All vars passed at runtime (no defaults file). Docker-based: creates dedicated bridge network (`172.28.0.0/16`), MySQL health gate before Semaphore starts, resource limits (0.5 CPU, 300m/1224m memory). `setup_new_project` generates a short-lived API token, uses it for all API calls, then destroys it in an `always` block.

### Jenkins (`Ansible/jenkins/`)

Now follows the universal dispatcher pattern:

```
ansible-playbook jenkins.yml -e "host=<group> role_to_execute=<role_name>"
```

- **Unified entrypoint**: `jenkins.yml` — aligned with Nexus/Semaphore dispatcher pattern
- **Roles** (via `role_to_execute`): `setup`, `reconfigure`
- **Backward-compatible wrappers**: `setup.yml`, `reconfigure.yml`, `update_*.yml` still work (they delegate to `jenkins.yml`)
- Host var: `host=<group>` (dispatcher), `target_hosts=<group>` (legacy wrappers)
- Required collections: `community.docker >= 3.4.0`, `community.general >= 7.0.0`
- Tags: `docker`, `prepare`, `deploy`, `compose`, `jcasc`, `jobs`, `credentials`, `users`, `plugins`, `build-inner-image`
- JCasC split across 4 templates: `jcasc.yaml`, `jcasc-users.yaml`, `jcasc-credentials.yaml`, `jcasc-jobs.yaml`
- Two roles: `setup` (full deploy) and `reconfigure` (post-deploy updates; use `--tags` to filter)
- Supports Debian/Ubuntu and RHEL families
- Secrets: no hardcoded passwords in defaults; pass via `-e` or group_vars

## Scripts (`Scripts/`)

- **`valid-truststore-generator/`**: bash scripts generating PKCS12 truststores from Spanish TSL XML. Uses `keytool`, `openssl`, `curl`, `perl`. SHA-256 verification of TSL download.
- **`aws/`**: Route53 CNAME UPSERT playbook targeting LocalStack mock (`172.17.0.1:4566`), and a trivial connectivity probe (`curl`).

## Commits

After completing any feature or fix, automatically suggest the conventional commit command:

```
git add -A && git commit -m "tipo: descripción corta"
```

Where `tipo` follows Conventional Commits: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`. Commit messages must be in English.
