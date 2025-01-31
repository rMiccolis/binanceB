#!/bin/bash

###############################################################################

# Select the right interface to be used
interface_range=()
IFS='.' read -r -a interface_range <<< "$master_host_ip"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}
interface="$interface_1.$interface_2.0.0"

# Init kubeadm cluster
echo -e "${LBLUE}Init kubeadm cluster${WHITE}"
echo -e "submitting:"
echo -e "sudo kubeadm init --pod-network-cidr=${interface}/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=$master_host_ip --upload-certs # > /dev/null 2>&1"
sudo kubeadm init --pod-network-cidr=${interface}/16 --cri-socket=unix:///var/run/cri-dockerd.sock --control-plane-endpoint=$master_host_ip --upload-certs # > /dev/null 2>&1

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config


# setting the "hosts" part of kubernetes coredns to recognize $master_host_ip as dns name $application_dns_name
# cat << EOF | tee /home/$USER/coredns_configmap.yaml > /dev/null
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: coredns
#   namespace: kube-system
# data:
#   Corefile: |
#     .:53 {
#         errors
#         health {
#            lameduck 5s
#         }
#         ready
#         kubernetes cluster.local in-addr.arpa ip6.arpa {
#            pods insecure
#            fallthrough in-addr.arpa ip6.arpa
#            ttl 30
#         }
#         hosts {
#         $master_host_ip $application_dns_name
#         fallthrough
#         }
#         prometheus :9153
#         forward . /etc/resolv.conf
#         cache 30
#         loop
#         reload
#         loadbalance
#     }
# EOF

# kubectl apply -f /home/$USER/coredns_configmap.yaml

# setting the "hosts" part of kubernetes coredns to recognize $master_host_ip as dns name $application_dns_name
# cat << EOF | tee /home/$USER/coredns_configmap.yaml > /dev/null
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: coredns
#   namespace: kube-system
# data:
#   Corefile: |
#     .:53 {
#         errors
#         health {
#            lameduck 5s
#         }
#         ready
#         kubernetes cluster.local in-addr.arpa ip6.arpa {
#            pods insecure
#            fallthrough in-addr.arpa ip6.arpa
#            ttl 30
#         }
#         hosts {
#         $master_host_ip $application_dns_name
#         fallthrough
#         }
#         prometheus :9153
#         forward . 8.8.8.8
#         cache 30
#         loop
#         reload
#         loadbalance
#     }
# EOF

# kubectl apply -f /home/$USER/coredns_configmap.yaml

# kubectl wait --for=condition=Ready --all pods --all-namespaces --timeout=3000s &
# wait

#install calico CNI to kubernetes cluster:
echo -e "${LBLUE}Installing calico CNI to kubernetes cluster${WHITE}"
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml -O > /dev/null 2>&1
kubectl apply -f calico.yaml > /dev/null 2>&1

kubectl wait --for=condition=Ready --all pods --all-namespaces --timeout=3000s &
wait
