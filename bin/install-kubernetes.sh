#!/bin/bash

sudof
###############################################################################
# Install Kubernetes
echo -e "${CYAN}Installinging Kubernetes${WHITE}"
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

sudo apt-get install -y kubelet kubeadm kubectl

# sudo apt-get install -y kubelet=1.26.0-00 kubeadm=1.26.0-00 kubectl=1.26.0-00
sudo apt-mark hold kubelet kubeadm kubectl
###############################################################################

###############################################################################
# Init kubeadm cluster
echo -e "${CYAN}Init kubeadm cluster${WHITE}"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install calico CNI to kubernetes cluster:
echo -e "${CYAN}Installinging calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O

kubectl apply -f calico.yaml
