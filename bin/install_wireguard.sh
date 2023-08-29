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

echo -e "${LBLUE}Installing Wireguard...${WHITE}"
sudo apt install wireguard -y
umask 077

for h in "${hosts[@]}"; do
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
host_ip_vpn=${host_string[2]}

echo -e "${LBLUE}Generating keys for $host_username ${WHITE}"
wg genkey | tee ${host_username}_privatekey | wg pubkey > ${host_username}_publickey

if [ "${host_username}" == "m1" ]; then

master_host_ip=$host_ip
master_host_ip_vpn="${host_ip_vpn}/16"
master_host_name=$host_username

sudo chown root:${host_username} /etc/wireguard/
sudo chmod -R 777 /etc/wireguard/

echo -e "${LBLUE}Generating Configuration for $host_username ${WHITE}"
sudo cat << EOF | tee /etc/wireguard/wg0.conf > /dev/null
[Interface]
Address = ${host_ip_vpn}/16
ListenPort = 51820
PrivateKey = $(cat ${host_username}_privatekey)

EOF

echo -e "${LBLUE}Activating wg0 Interface for $host_username ${WHITE}"
sudo wg-quick up wg0

else

ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
wait

echo -e "${LBLUE}Installing Wireguard for $host_username ${WHITE}"
ssh ${host_username}@$host_ip "sudo apt install wireguard -y" &
wait
ssh ${host_username}@$host_ip "umask 077" &
wait

echo -e "${LBLUE}Generating Configuration for $host_username ${WHITE}"
sudo cat << EOF | tee -a /etc/wireguard/${host_username}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = ${host_ip_vpn}/24
PrivateKey = $(cat ${host_username}_privatekey)

[Peer]
PublicKey = $(cat ${master_host_name}_publickey)
Endpoint = ${master_host_ip}:51820
AllowedIPs = 10.10.0.0/16
PersistentKeepalive = 30
EOF

ssh ${host_username}@$host_ip "sudo chown root:${host_username} /etc/wireguard/" &
wait
ssh ${host_username}@$host_ip "sudo chmod -R 777 /etc/wireguard/" &
wait

echo -e "${LBLUE}Sending peer Configuration to $host_username ${WHITE}"
scp -q /etc/wireguard/${host_username}_wg0.conf ${host_username}@$host_ip:/etc/wireguard/wg0.conf &
wait

echo -e "${LBLUE}Applying peer Configuration to $host_username ${WHITE}"
ssh ${host_username}@$host_ip "sudo wg-quick up wg0" &
wait

echo -e "${LBLUE}Adding peer $host_username to server Configuration ${WHITE}"
sudo wg set wg0 peer "$(cat ${host_username}_publickey)" allowed-ips ${host_ip_vpn}/32
sudo ip -4 route add ${host_ip_vpn}/32 dev wg0
fi

done