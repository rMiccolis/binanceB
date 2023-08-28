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

sudo apt install wireguard -y
umask 077

for h in "${hosts[@]}"; do
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
host_ip_vpn=${host_string[2]}

wg genkey | tee ${host_username}_privatekey | wg pubkey > ${host_username}_publickey

if [ "${host_username}" == "m1" ]; then

master_host_ip=$host_ip
master_host_ip_vpn="${host_ip_vpn}/16"
master_host_name=$host_username

sudo chown root:${host_username} /etc/wireguard/
sudo chmod -R 770 /etc/wireguard/

sudo cat << EOF | tee /etc/wireguard/wg0.conf > /dev/null
[Interface]
Address = ${host_ip_vpn}/16
ListenPort = 51820
PrivateKey = $(cat ${host_username}_privatekey)

EOF

else

ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
wait

ssh ${host_username}@$host_ip "sudo apt install wireguard -y" &
wait
ssh ${host_username}@$host_ip "umask 077" &
wait

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

sudo cat << EOF | tee -a /etc/wireguard/wg0.conf > /dev/null
[Peer]
# $host_username
PublicKey = $(cat ${host_username}_publickey)
AllowedIPs = ${host_ip_vpn}/32

EOF

ssh ${host_username}@$host_ip "sudo chown root:${host_username} /etc/wireguard/" &
wait
ssh ${host_username}@$host_ip "sudo chmod -R 770 /etc/wireguard/" &
wait

scp -q /etc/wireguard/${host_username}_wg0.conf ${host_username}@$host_ip:/etc/wireguard/wg0.conf &
wait

ssh ${host_username}@$host_ip "sudo wg-quick up wg0" &
wait
fi

done

sudo wg-quick up wg0