#!/bin/bash

###############################################################################
#disable swap
echo -e "${LBLUE}Disabling swap...${WHITE}"
/home/$USER/binanceB/bin/disable_swap.sh

# Install Kubernetes
# install kubeadm, kubelet and kubectl:
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
echo -e "${LBLUE}Update the apt package index and install packages needed to use the Kubernetes apt repository${WHITE}"
sudo apt-get update > /dev/null 2>&1
sudo apt-get upgrade -y -q > /dev/null 2>&1
sudo apt-get install -y -q apt-transport-https ca-certificates curl > /dev/null 2>&1

# Download the Google Cloud public signing key:
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg > /dev/null 2>&1

# Add the Kubernetes apt repository:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null 2>&1

# Update apt package index, install latest versions of kubelet, kubeadm and kubectl, and pin their version:
echo -e "${LBLUE}Update apt package index, install latest versions of kubelet, kubeadm and kubectl, and pin their version${WHITE}"
sudo apt-get update > /dev/null 2>&1

# sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-get install -y -q kubelet kubeadm kubectl > /dev/null 2>&1
sudo apt-mark hold kubelet kubeadm kubectl > /dev/null 2>&1
###############################################################################
