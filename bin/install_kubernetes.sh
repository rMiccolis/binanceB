#!/bin/bash

###############################################################################
#disable swap
echo -e "${LBLUE}Disabling swap...${WHITE}"
/home/$USER/binanceB/bin/disable_swap.sh

# Install Kubernetes
# install kubeadm, kubelet and kubectl:
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
echo -e "${LBLUE}Update the apt package index and install packages needed to use the Kubernetes apt repository${WHITE}"
sudo apt-get update > /dev/null # 2>&1
sudo apt-get upgrade -y -q > /dev/null # 2>&1
sudo apt-get install -y apt-transport-https ca-certificates curl gpg > /dev/null # 2>&1

# Download the Google Cloud public signing key:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Add the Kubernetes apt repository:
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null # 2>&1

# Update apt package index, install latest versions of kubelet, kubeadm and kubectl, and pin their version:
echo -e "${LBLUE}Update apt package index, install latest versions of kubelet, kubeadm and kubectl, and pin their version${WHITE}"
sudo apt-get update > /dev/null # 2>&1


sudo apt-get install -y -q kubelet kubeadm kubectl > /dev/null # 2>&1
# sudo apt-get install -y kubelet=1.27.1-00 kubeadm=1.27.1-00 kubectl=1.27.1-00
sudo apt-mark hold kubelet kubeadm kubectl > /dev/null # 2>&1
# Enable the kubelet service before running kubeadm
sudo systemctl enable --now kubelet
###############################################################################
