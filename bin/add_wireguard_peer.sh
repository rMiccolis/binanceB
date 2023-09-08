#!/bin/bash

###############################################################################

# usage info
usage(){
  echo " Run this script to add a 'client' peer to the wireguard vpn"
  echo ""
  echo "Usage:"
  echo "  $0 -p new-peer-name"
  echo ""
  echo "-p is the name of the peer to be added to the wireguard vpn"
  exit
}

while getopts ":p:" opt; do
  case $opt in
    p) peer_name="$OPTARG"
    ;;
    \?) usage
        exit
    ;;
  esac
done

source /home/$USER/.profile

cd wireguard/keys
wg genkey | tee ${peer_name}_privatekey | wg pubkey > ${peer_name}_publickey

# cd /home/$USER/wireguard/config_files

declare -i counter=50
server_ip=$master_host_ip_eth0

if [ -f /home/$USER/wireguard/config_files/counter ]; then
    counter=$(cat /home/$USER/wireguard/config_files/counter)
fi

# if [ "$environment" == "production" ]; then
server_ip=$load_balancer_dns_name
# fi

counter+=1
cat << EOF | tee /home/$USER/wireguard/config_files/counter > /dev/null
$counter
EOF

interface_range=()
IFS='.' read -r -a interface_range <<< "$master_host_ip"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}
interface="$interface_1.$interface_2.0.0"
peer_ip="$interface_1.$interface_2.$interface_3.$counter"

echo -e "${LBLUE}Generating Configuration for $peer_name ${WHITE}"
sudo cat << EOF | tee /home/$USER/wireguard/config_files/${peer_name}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = $peer_ip/24
PrivateKey = $(cat ${peer_name}_privatekey)
Dns = ${master_host_ip}

[Peer]
PublicKey = $(cat /home/$USER/wireguard/keys/${master_host_name}_publickey)
Endpoint = ${server_ip}:51820
AllowedIPs = $interface/16
PersistentKeepalive = 30
EOF

echo -e "${LBLUE}Adding peer $peer_name to server Configuration ${WHITE}"
sudo wg set wg0 peer "$(cat /home/$USER/wireguard/keys/${peer_name}_publickey)" allowed-ips ${peer_ip}/32
sudo ip -4 route add ${peer_ip}/32 dev wg0

echo -e "${LBLUE}This is the Configuration file for $peer_name ${WHITE}"
echo -e "${LBLUE}Available at /home/$USER/wireguard/config_files/${peer_name}_wg0.conf ${WHITE}"
echo "Text configuration at:"
echo "$(cat /home/$USER/wireguard/config_files/${peer_name}_wg0.conf)"
cat /home/$USER/wireguard/config_files/${peer_name}_wg0.conf | qrencode -t ansiutf8 

sudo wg-quick down wg0
sleep 5
sudo wg-quick up wg0