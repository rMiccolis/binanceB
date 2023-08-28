#!/bin/bash

###############################################################################

# usage info
usage(){
  echo " Run this script to install wireguard on master and other 'client' peers"
  echo ""
  echo "Usage:"
  echo "  $0 -c /path/to/main_config.yaml"
  echo ""
  exit
}

while getopts ":c:" opt; do
  case $opt in
    c) config_file_path="$OPTARG"
    ;;
    \?) usage
        exit
    ;;
  esac
done

hosts=()
hosts+=($(yq '.master_host' $config_file_path))
hosts+=($(yq '.hosts[]' $config_file_path))
master_host_ip=""
master_host_name=""
master_host_ip_vpn=""
mkdir wireguard_keys
cd wireguard_keys
declare -i counter=1

sudo apt install wireguard -y
umask 077

for h in "${hosts[@]}"; do
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}


if [ "${host_username}" == "m1" ]; then
wg genkey | tee ${host_username}_privatekey | wg pubkey > ${host_username}_publickey
sudo chmod -R u+rw /etc/wireguard/
master_host_ip=$host_ip
master_host_ip_vpn="10.10.1.${counter}/16"
master_host_name=$host_username
sudo cat << EOF | sudo tee /etc/wireguard/wg0.conf > /dev/null
[Interface]
Address = 10.10.1.${counter}/16
ListenPort = 51820
PrivateKey = $(cat ${host_username}_privatekey)

EOF

counter=1
else

wg genkey | tee ${host_username}_privatekey | wg pubkey > ${host_username}_publickey

ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
wait

ssh ${host_username}@$host_ip "sudo apt install wireguard -y" &
wait
ssh ${host_username}@$host_ip "umask 077" &
wait

sudo cat << EOF | sudo tee -a /etc/wireguard/${host_username}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = 10.10.1.${counter}/24
PrivateKey = $(cat ${host_username}_privatekey)

[Peer]
PublicKey = $(cat ${master_host_name}_publickey)
Endpoint = ${master_host_ip}:51820
AllowedIPs = 10.10.0.0/16
PersistentKeepalive = 30
EOF

sudo cat << EOF | sudo tee -a /etc/wireguard/wg0.conf > /dev/null
[Peer]
# $host_username
PublicKey = $(cat ${host_username}_publickey)
AllowedIPs = 10.10.1.${counter}/32

EOF

ssh ${host_username}@$host_ip "sudo chmod -R u+rw /etc/wireguard/" &
wait

scp -q /etc/wireguard/${host_username}_wg0.conf $host_ip:/etc/wireguard/wg0.conf &
wait

ssh ${host_username}@$host_ip "sudo wg-quick up wg0" &
wait
fi

counter+=1
done

sudo wg-quick up wg0