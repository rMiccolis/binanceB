#!/bin/bash

# provide docker username and password
###############################################################################
# Install Docker Engine
echo -e "${CYAN}Installinging Docker Engine${WHITE}"
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudof apt-get update

sudof apt-get install \
    ca-certificates \
    curl \
    gnupg

# Add Docker’s official GPG key:
sudof mkdir -m 0755 -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudof gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudof tee /etc/apt/sources.list.d/docker.list > /dev/null

# sudof chmod a+r /etc/apt/keyrings/docker.gpg

sudof apt-get update

# install the latest version
sudof apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudof systemctl start docker

sudof systemctl enable docker

# Verify installation
sudof docker run hello-world
###############################################################################

#login into docker hub
echo "${CYAN}Docker Hub login with username: $docker_username${WHITE}";
# login into docker
sudof docker login --username $docker_username --password $docker_password