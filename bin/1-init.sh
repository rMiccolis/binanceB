#!/bin/bash

#take sudop psw so it is asked just once and ensure that sudop is used just when really needed
echo "[sudo] password for m1:"; read -s sudop W
sudop  () {
  echo $sudop W | sudo-S "$@"
}

#export colors for colored output strings
BLACK="\033[0;30m"
DARK_GREY="\033[1;30m"
RED="\033[0;31m"
LRED="\033[1;31m"
GREEN="\033[0;32m"
LGREEN="\033[1;32m"
ORANGE="\033[0;33m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
LBLUE="\033[1;34m"
PURPLE="\033[0;35m"
LPURPLE="\033[1;35m"
CYAN="\033[0;36m"
LCYAN="\033[1;36m"
LGRAY="\033[0;37m"
WHITE="\033[1;37m"
echo -e "${BLUE}Setting up cluster: => IP: $(hostname -I)${WHITE}"

# save host ip address
# export ip_addr=$(hostname -I)
# export host_name=$(cat /etc/hosts | grep -i 127.0.1.1 | awk 'NR==1{print $2}')
# hostnamectl set-hostname $host_name

# cat << EOF | sudop tee -a /etc/hosts
# $ip_addr $host_name
# EOF

#disable swap
echo -e "${CYAN}disable swap"
sudop sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
sudop swapoff -a

###############################################################################
# Forwarding IPv4 and letting iptables see bridged traffic
echo -e "${CYAN}Forwarding IPv4 and letting iptables see bridged traffic${WHITE}"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | tee /etc/modules-load.d/modules.conf
overlay
br_netfilter
EOF

sudop modprobe overlay

sudop modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudop sysctl --system

# Verify that the br_netfilter, overlay modules are loaded by running below instructions:
# lsmod | grep br_netfilter
# lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running below instruction:
# sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
###############################################################################

###############################################################################
# Install Docker Engine
echo -e "${CYAN}Installinging Docker Engine${WHITE}"
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudop apt-get update

sudop apt-get install \
    ca-certificates \
    curl \
    gnupg

# Add Docker’s official GPG key:
sudop mkdir -m 0755 -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudop gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudop tee /etc/apt/sources.list.d/docker.list > /dev/null

# sudop chmod a+r /etc/apt/keyrings/docker.gpg

sudop apt-get update

# install the latest version
sudop apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudop systemctl start docker

sudop systemctl enable docker

# Verify installation
sudop docker run hello-world
###############################################################################

###############################################################################
# Install the docker cri (Container Runtime Interface)
#https://github.com/Mirantis/cri-dockerd/releases this is the release package
echo -e "${CYAN}Installinging the docker cri (Container Runtime Interface)${WHITE}"
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd-0.3.1.amd64.tgz

sudop tar -xvf cri-dockerd-0.3.1.amd64.tgz

cd cri-dockerd/
mkdir -p /usr/local/bin

sudop install -o root -g root -m 0755 ./cri-dockerd /usr/local/bin/cri-dockerd

# check these file from https://github.com/Mirantis/cri-dockerd/tree/master/packaging/systemd
# edit line 'ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://'
# into: 'ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin='

sudop tee /etc/systemd/system/cri-docker.service << EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

sudop tee /etc/systemd/system/cri-docker.socket << EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service
[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
[Install]
WantedBy=sockets.target
EOF

sudop systemctl daemon-reload

sudop systemctl enable cri-docker.service

sudop systemctl enable --now cri-docker.socket

###############################################################################

###############################################################################
# Install Kubernetes
echo -e "${CYAN}Installinging Kubernetes${WHITE}"
# install kubeadm, kubelet and kubectl:
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudop apt-get update

sudop apt-get upgrade -y

sudop apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
sudop curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudop tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudop apt-get update

sudop apt-get install -y kubelet kubeadm kubectl

# sudop apt-get install -y kubelet=1.26.0-00 kubeadm=1.26.0-00 kubectl=1.26.0-00
sudop apt-mark hold kubelet kubeadm kubectl
###############################################################################

###############################################################################
# Init kubeadm cluster
echo -e "${CYAN}Init kubeadm cluster${WHITE}"
sudop kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

mkdir -p $HOME/.kube

sudop cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudop chown $(id -u):$(id -g) $HOME/.kube/config

#install calico CNI to kubernetes cluster:
echo -e "${CYAN}Installinging calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O

kubectl apply -f calico.yaml
