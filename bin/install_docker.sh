#!/bin/bash

# provide docker username and password
###############################################################################
# Install Docker Engine
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
echo -e "${LBLUE}Update the apt package index and install packages to allow apt to use a repository over HTTPS...${WHITE}"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install ca-certificates curl gnupg -q > /dev/null 2>&1

# Add Docker’s official GPG key:
sudo mkdir -m 0755 -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1

# set up the repository:
echo -e "${LBLUE}Setting up the repository...${WHITE}"
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>&1

# sudo chmod a+r /etc/apt/keyrings/docker.gpg

sudo apt-get update > /dev/null 2>&1

# install the latest version
echo -e "${LBLUE}Installing the latest Docker Engine version...${WHITE}"
sudo apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

sudo systemctl start docker > /dev/null 2>&1

sudo systemctl enable docker > /dev/null 2>&1

# Verify installation
# sudo docker run hello-world > /dev/null
###############################################################################
