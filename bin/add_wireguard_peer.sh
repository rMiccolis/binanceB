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

if [ -f /home/$USER/wireguard/config_files/counter ]; then
    counter=$(cat /home/$USER/wireguard/config_files/counter)
fi

counter+=1
cat << EOF | tee /home/$USER/wireguard/config_files/counter
$counter
EOF
peer_ip=10.10.1.${counter}

echo -e "${LBLUE}Generating Configuration for $peer_name ${WHITE}"
sudo cat << EOF | tee -a /home/$USER/wireguard/config_files/${peer_name}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = $peer_ip/24
PrivateKey = $(cat ${peer_name}_privatekey)

[Peer]
PublicKey = $(cat /home/$USER/wireguard/keys/${master_host_name}_publickey)
Endpoint = ${master_host_ip_eth0}:51820
AllowedIPs = 10.10.0.0/16
PersistentKeepalive = 30
EOF

echo -e "${LBLUE}Adding peer $peer_name to server Configuration ${WHITE}"
sudo wg set wg0 peer "$(cat /home/$USER/wireguard/keys/${peer_name}_publickey)" allowed-ips ${peer_ip}/32
sudo ip -4 route add ${peer_ip}/32 dev wg0

echo -e "${LBLUE}This is the Configuration file for $peer_name ${WHITE}"
echo -e "${LBLUE}Available at /home/$USER/wireguard/config_files/${peer_name}_wg0.conf ${WHITE}"
echo "Text configuration at: $(cat /home/$USER/wireguard/config_files/${peer_name}_wg0.conf)"
cat /home/$USER/wireguard/config_files/${peer_name}_wg0.conf | qrencode -t ansiutf8 

# sudo wg-quick down wg0
# sudo wg-quick up wg0