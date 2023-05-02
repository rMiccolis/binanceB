#!/bin/bash

###############################################################################
# Init kubeadm cluster
echo -e "${LBLUE}Init kubeadm cluster${WHITE}"
sudo apt-get upgrade -y
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --kubernetes-version=1.26.1 --control-plane-endpoint=$master_host_ip

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install calico CNI to kubernetes cluster:
echo -e "${LBLUE}Installing calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
kubectl apply -f calico.yaml
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
# watch kubectl get pods -n calico-system

sleep 100

kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1200s &
wait