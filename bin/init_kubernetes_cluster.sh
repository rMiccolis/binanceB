#!/bin/bash

###############################################################################

# Select the right interface to be used
interface_range=()
IFS='.' read -r -a interface_range <<< "$master_host_ip_vpn"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}
interface="$interface_1.$interface_2.0.0"

# Init kubeadm cluster
echo -e "${LBLUE}Init kubeadm cluster${WHITE}"
sudo kubeadm init --pod-network-cidr=$interface/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=$master_host_ip --upload-certs > /dev/null 2>&1

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install calico CNI to kubernetes cluster:
echo -e "${LBLUE}Installing calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O > /dev/null 2>&1
kubectl apply -f calico.yaml > /dev/null 2>&1
