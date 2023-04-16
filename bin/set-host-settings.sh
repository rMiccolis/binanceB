#!/bin/bash

###############################################################################
# save host ip address
# export ip_addr=$(hostname -I)
# export host_name=$(cat /etc/hosts | grep -i 127.0.1.1 | awk 'NR==1{print $2}')
# hostnamectl set-hostname $host_name

# cat << EOF | sudof tee -a /etc/hosts
# $ip_addr $host_name
# EOF

#disable swap
echo -e "${CYAN}disable swap"
sudof sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
sudof swapoff -a

# Forwarding IPv4 and letting iptables see bridged traffic
echo -e "${CYAN}Forwarding IPv4 and letting iptables see bridged traffic${WHITE}"
cat <<EOF | sudof tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudof tee /etc/modules-load.d/modules.conf
overlay
br_netfilter
EOF

sudof modprobe overlay

sudof modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudof tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudof sysctl --system

sudof apt-get upgrade -y

# Verify that the br_netfilter, overlay modules are loaded by running below instructions:
# lsmod | grep br_netfilter
# lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running below instruction:
# sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
###############################################################################