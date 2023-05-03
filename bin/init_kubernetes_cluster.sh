#!/bin/bash

###############################################################################
# Init kubeadm cluster
echo -e "${LBLUE}Init kubeadm cluster${WHITE}"
sudo apt-get upgrade -y
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=$master_host_ip

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install calico CNI to kubernetes cluster:
echo -e "${LBLUE}Installing calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O
kubectl apply -f calico.yaml

sleep 5

kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=2000s &
wait