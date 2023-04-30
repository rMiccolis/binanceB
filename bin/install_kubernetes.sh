#!/bin/bash

###############################################################################
# Install Kubernetes
echo -e "${LBLUE}Installing Kubernetes${WHITE}"
# install kubeadm, kubelet and kubectl:
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update

# sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-get install -y kubelet=1.26.1-00 kubeadm=1.26.1-00 kubectl=1.26.1-00
sudo apt-mark hold kubelet kubeadm kubectl
###############################################################################
