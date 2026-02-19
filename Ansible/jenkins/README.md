# Jenkins Docker Ansible Role

Ansible role to deploy Jenkins as a Docker container with automatic admin user setup, jobs configuration, and Docker Cloud for pipeline execution.

## Features

- Deploys Jenkins LTS as a Docker container
- Creates admin user with customizable credentials (default: `admin/admin`)
- Installs specified plugins automatically
- **Configuration as Code (JCasC)** for declarative configuration
- **Modular JCasC** configuration (users, credentials, clouds separated)
- **Docker Cloud** container for running pipeline containers
- Creates Jenkins jobs from YAML configuration files
- **Docker Compose** for clear and maintainable container configuration
- **Selective reconfiguration** using Ansible tags
- Persistent storage using Docker volumes
- Auto-restart policy for high availability

## Requirements

- Ansible 2.9 or higher
- Target system: Ubuntu 20.04/22.04 or Debian 11/12
- Docker must be installable on the target system
- Required Ansible collections (install on your control host):
  ```bash
  ansible-galaxy collection install community.docker community.general
  ```

## Installation

Install required collections before running the playbook:

```bash
cd /home/rafaelg/Projects/DEVOPS/Ansible/jenkins
ansible-galaxy collection install -r requirements.yml
```

Or install manually:

```bash
ansible-galaxy collection install community.docker community.general
```

## Directory Structure

```
jenkins/
├── files/                    # Jenkins state (single source of truth)
│   ├── plugins.yml           # List of plugins to install
│   ├── users.yml             # Additional users configuration
│   ├── credentials.yml       # Additional credentials configuration
│   ├── jcasc/                # JCasC configuration (generated)
│   │   ├── jcasc.yaml
│   │   ├── jcasc-users.yaml
│   │   ├── jcasc-credentials.yaml
│   │   └── jcasc-cloud.yaml
│   ├── jenkins_init/         # Initialization scripts (generated)
│   │   └── jobs/             # Job configurations (generated)
│   └── jobs/                 # Job definition files
│       ├── sample-project.yml
│       └── backend-service.yml
├── roles/
│   ├── setup/                # Initial setup role
│   │   ├── tasks/
│   │   ├── templates/
│   │   ├── handlers/
│   │   ├── defaults/
│   │   └── meta/
│   └── reconfigure/          # Reconfiguration role
│       ├── tasks/
│       ├── templates/
│       ├── handlers/
│       ├── defaults/
│       └── meta/
├── setup.yml                 # Full deployment playbook
├── reconfigure.yml           # Reconfiguration playbook
├── update_jobs.yml           # Jobs-only update playbook
├── update_users.yml          # Users-only update playbook
├── update_credentials.yml    # Credentials-only update playbook
├── update_docker_cloud.yml   # Docker Cloud update playbook
└── README.md                 # This file
```

## Usage

### Testing with Vagrant (Recommended for Development)

This role includes a Vagrantfile for easy local testing:

```bash
# Start the VM and provision Jenkins
vagrant up

# Access Jenkins in your browser
# http://localhost:8080
# Username: admin
# Password: admin

# SSH into the VM
vagrant ssh

# View logs
vagrant ssh -c "docker logs jenkins"
vagrant ssh -c "docker logs docker-cloud"

# Destroy the VM when done
vagrant destroy -f
```

### Full Deployment (Production)

Deploy Jenkins from scratch:

```bash
ansible-playbook playbook.yml -e "target_hosts=all"
```

### Reconfiguration Playbooks

#### Full Reconfiguration

Reconfigure Jenkins without redeploying containers:

```bash
ansible-playbook reconfigure.yml -e "target_hosts=all"
```

#### Update Jobs Only

Add or update jobs without touching other configurations:

```bash
ansible-playbook update_jobs.yml -e "target_hosts=all"
```

#### Update Users Only

Add or update users without touching other configurations:

```bash
ansible-playbook update_users.yml -e "target_hosts=all"
```

#### Update Credentials Only

Add or update credentials without touching other configurations:

```bash
ansible-playbook update_credentials.yml -e "target_hosts=all"
```

#### Update Docker Cloud Configuration

Update Docker agent templates and cloud settings:

```bash
ansible-playbook update_docker_cloud.yml -e "target_hosts=all"
```

### Using Ansible Tags

You can also use tags for selective execution:

```bash
# Full setup
ansible-playbook playbook.yml -e "target_hosts=all" --tags setup

# Only deploy containers
ansible-playbook playbook.yml -e "target_hosts=all" --tags deploy

# Only configure Jenkins (plugins, JCasC, jobs)
ansible-playbook playbook.yml -e "target_hosts=all" --tags configure

# Only install/update plugins
ansible-playbook playbook.yml -e "target_hosts=all" --tags plugins

# Only update jobs
ansible-playbook playbook.yml -e "target_hosts=all" --tags jobs

# Only update users
ansible-playbook playbook.yml -e "target_hosts=all" --tags users

# Only update credentials
ansible-playbook playbook.yml -e "target_hosts=all" --tags credentials

# Only reload JCasC (users, credentials, docker-cloud templates)
ansible-playbook playbook.yml -e "target_hosts=all" --tags jcasc

# Update Docker Cloud only
ansible-playbook playbook.yml -e "target_hosts=all" --tags docker-cloud

# Multiple tags
ansible-playbook playbook.yml -e "target_hosts=all" --tags "configure,jobs"
```

### Customizing Admin Credentials

Override the default credentials in your playbook or inventory:

```yaml
vars:
  jenkins_admin_user: "myadmin"
  jenkins_admin_password: "secure_password"
```

### Adding Users

Edit `files/users.yml` to add additional users:

```yaml
---
additional_users:
  - id: "developer"
    password: "dev_password"
    name: "Developer User"
    email: "developer@example.com"
  - id: "ci-bot"
    password: "bot_password"
    name: "CI/CD Bot"
    email: "ci-bot@example.com"
```

### Adding Credentials

Edit `files/credentials.yml` to add additional credentials:

```yaml
---
additional_credentials:
  - id: "github-credentials"
    username: "github-user"
    password: "github-token"
    description: "GitHub Personal Access Token"
    scope: "GLOBAL"
  - id: "nexus-credentials"
    username: "nexus-deploy"
    password: "nexus-password"
    description: "Nexus Repository Deploy User"
    scope: "SYSTEM"
```

### Adding Jobs

Create a new YAML file in `files/jobs/` for each job:

```yaml
---
# Job: my-project
# Git repository: https://github.com/example/my-project.git

name: "my-project"
git_url: "https://github.com/example/my-project.git"
branch: "main"
path: "Jenkinsfile"
```

**Job file fields:**

| Field | Description | Required |
|-------|-------------|----------|
| `name` | Job name (Jenkins identifier) | Yes |
| `git_url` | Git repository URL | Yes |
| `branch` | Branch to build | Yes |
| `path` | Path to Jenkinsfile in repository | Yes |

### Customizing Plugins

Edit `files/plugins.yml` to add or remove plugins:

```yaml
---
plugins:
  - git
  - docker
  - kubernetes
  - pipeline
  - blueocean
  - configuration-as-code
  - docker-plugin
  - docker-java-api
  - your-custom-plugin
```

### Customizing Docker Cloud / dind

Override dind configuration variables in your playbook:

```yaml
vars:
  jenkins_docker_cloud_enabled: true
  jenkins_dind_image: "docker:24-dind"
  jenkins_dind_container_name: "jenkins-dind"
  jenkins_dind_network_name: "jenkins-network"
  jenkins_dind_docker_host: "tcp://jenkins-dind:2375"
  jenkins_dind_container_template:
    image: "docker:24-dind"
    privileged: true
    memory_limit: 4294967296  # 4GB
    cpu_limit: 4
```

### Customizing Jenkins Container

```yaml
vars:
  jenkins_docker_image: "jenkins/jenkins:2.426.1"
  jenkins_container_name: "my-jenkins"
  jenkins_host_port: 9090
  jenkins_agent_port: 50001
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `jenkins_docker_image` | Docker image to use | `jenkins/jenkins:lts` |
| `jenkins_container_name` | Container name | `jenkins` |
| `jenkins_hostname` | Hostname binding | `0.0.0.0` |
| `jenkins_host_port` | Host port for web UI | `8080` |
| `jenkins_agent_port` | Agent port | `50000` |
| `jenkins_admin_user` | Admin username | `admin` |
| `jenkins_admin_password` | Admin password | `admin` |
| `jenkins_admin_email` | Admin email | `admin@localhost` |
| `jenkins_docker_cloud_enabled` | Enable Docker Cloud | `true` |
| `jenkins_dind_image` | dind Docker image | `docker:dind` |
| `jenkins_dind_container_name` | dind container name | `jenkins-dind` |
| `jenkins_dind_network_name` | Docker network name | `jenkins-network` |
| `jenkins_dind_docker_host` | Docker host URI for JCasC | `tcp://jenkins-dind:2375` |
| `docker_registry_username` | Docker registry username | `docker-user` |
| `docker_registry_password` | Docker registry password | `docker-password` |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Host                             │
│                                                             │
│  ┌─────────────────┐     ┌─────────────────────────────┐   │
│  │   dind          │     │   Jenkins                   │   │
│  │   Container     │◄────┤   Container                 │   │
│  │                 │     │                             │   │
│  │  Port: 2375     │     │  Port: 8080 (Web UI)        │   │
│  │                 │     │  Port: 50000 (Agent)        │   │
│  │  dind_data      │     │  jenkins_data               │   │
│  └─────────────────┘     │                             │   │
│         │                │  JCasC Config               │   │
│         │                │  - Users                    │   │
│         │                │  - Credentials              │   │
│         │                │  - Docker Cloud             │   │
│         │                │  - Security                 │   │
│         └────────────────┤                             │   │
│                          └─────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              jenkins-network                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Docker Cloud Configuration

The role configures Docker Cloud using JCasC with the following features:

- **dind (Docker-in-Docker)**: Runs Docker daemon in a separate container
- **Network isolation**: Jenkins and dind communicate over a dedicated Docker network
- **Dynamic agents**: Pipeline builds spawn temporary Docker containers
- **Resource limits**: Configurable memory and CPU limits for build agents

### Pipeline Example

```groovy
pipeline {
    agent { label 'docker-agent' }
    
    stages {
        stage('Build') {
            steps {
                sh 'docker run --rm hello-world'
                sh 'docker build -t myapp .'
            }
        }
    }
}
```

## Accessing Jenkins

After deployment:

- **URL:** `http://<server-ip>:8080`
- **Username:** `admin`
- **Password:** `admin`

## Security Notes

⚠️ **Important:** Change the default credentials (`admin/admin`) in production environments!

Override the credentials using variables or Ansible Vault:

```bash
ansible-vault encrypt_string 'your_secure_password' --name 'jenkins_admin_password'
```

## Troubleshooting

### Check container status

```bash
docker ps -a | grep jenkins
```

### View Jenkins logs

```bash
docker logs jenkins
```

### View Docker Cloud logs

```bash
docker logs docker-cloud
```

### Access Jenkins container shell

```bash
docker exec -it jenkins bash
```

### Access Docker Cloud container shell

```bash
docker exec -it docker-cloud bash
```

### Reload JCasC configuration manually

```bash
curl -XPOST http://localhost:8080/reload-configuration-as-code
```

### Check JCasC status

```bash
curl http://localhost:8080/management/loggers/io.jenkins.plugins.casc
```

### Manage with Docker Compose

```bash
cd /opt/jenkins
docker-compose ps
docker-compose logs -f
docker-compose restart
```

## License

MIT

## Author

Rafael Guzman
