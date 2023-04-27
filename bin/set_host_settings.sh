#!/bin/bash

###############################################################################
remote=0
while getopts ":r:" opt; do
  case $opt in
    r) remote="$OPTARG"
    ;;
  esac
done

host_list=($host_list)

if [ "$remote" -eq "1" ]; then
cat << EOF | sudo tee -a /etc/hosts > /dev/null
$master_host_ip $master_host_name
EOF
fi

#disable swap
echo -e "${CYAN}disable swap${WHITE}"
sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Forwarding IPv4 and letting iptables see bridged traffic
echo -e "${CYAN}Forwarding IPv4 and letting iptables see bridged traffic${WHITE}"
cat << EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF

cat << EOF | sudo tee /etc/modules-load.d/modules.conf > /dev/null
overlay
br_netfilter
EOF

sudo modprobe overlay

sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# installing jq to parse and read json files
sudo apt-get install -y jq

# sudo apt-get upgrade -y

# Verify that the br_netfilter, overlay modules are loaded by running below instructions:
# lsmod | grep br_netfilter
# lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running below instruction:
# sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
###############################################################################