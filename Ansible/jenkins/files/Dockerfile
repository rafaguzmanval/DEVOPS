FROM jenkins/jenkins:lts

# Install Jenkins plugins (as root)
COPY plugins.txt /tmp/plugins.txt
RUN jenkins-plugin-cli --plugin-file /tmp/plugins.txt || true

# Create casc_configs directory and copy JCasC files if they exist
USER root
RUN mkdir -p /var/jenkins_home/casc_configs

# Copy JCasC configuration, jobs and pipelines
COPY jcasc/ /var/jenkins_home/casc_configs/
COPY jobs/ /var/jenkins_home/jobs/
COPY pipelines/ /var/jenkins_home/pipelines/

# Set proper permissions for all copied files
RUN chown -R jenkins:jenkins /var/jenkins_home/jobs /var/jenkins_home/pipelines /var/jenkins_home/casc_configs

# Set JCasC environment variable
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs

USER jenkins
