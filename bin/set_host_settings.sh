#!/bin/bash

###############################################################################

sudo apt-get upgrade -y -q > /dev/null 2>&1

# Forwarding IPv4 and letting iptables see bridged traffic
echo -e "${LBLUE}Forwarding IPv4 and letting iptables see bridged traffic${WHITE}"
cat << EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null 2>&1
overlay
br_netfilter
EOF

cat << EOF | sudo tee /etc/modules-load.d/modules.conf > /dev/null 2>&1
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null 2>&1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
echo -e "${LBLUE}Applying sysctl params without reboot...${WHITE}"
sudo sysctl --system > /dev/null 2>&1

if [ "$master_host_name" != "$(whoami)" ]; then
# installing yq to parse and read json files
echo -e "${LBLUE}Installing yq library on $(whoami) to read and parse YAML files...${WHITE}"
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -q -O /usr/bin/yq && sudo chmod +x /usr/bin/yq > /dev/null

echo -e "${LBLUE}Setting Master IP address into hosts file${WHITE}"
# save host ip address into host file
cat << EOF | sudo tee -a /etc/hosts > /dev/null
$master_host_ip $master_host_name $load_balancer_dns_name
EOF
fi

###############################################################################