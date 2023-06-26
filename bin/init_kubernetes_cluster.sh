#!/bin/bash

###############################################################################
# Init kubeadm cluster
echo -e "${LBLUE}Init kubeadm cluster${WHITE}"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=$master_host_ip --upload-certs > certs.txt #> /dev/null 2>&1

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
