#!/bin/bash

sudof
# provide docker username and password
###############################################################################
# Install Docker Engine
echo -e "${CYAN}Installinging Docker Engine${WHITE}"
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg

# Add Docker’s official GPG key:
sudo mkdir -m 0755 -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# sudo chmod a+r /etc/apt/keyrings/docker.gpg

sudo apt-get update

# install the latest version
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker

sudo systemctl enable docker

# Verify installation
sudo docker run hello-world
###############################################################################

#login into docker hub
echo "${CYAN}Docker Hub login with username: $docker_username${WHITE}";
# login into docker
sudo docker login --username $docker_username --password $docker_password