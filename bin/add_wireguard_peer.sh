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
  echo ""
  echo "-a flag to add user as admin to have full vpn access"
  echo ""
  exit
}

admin=0
peer_name=""
while getopts ":p:a" opt; do
  case $opt in
    p) peer_name="$OPTARG"
    ;;
    a) admin=1
    ;;
    \?) usage
        exit
    ;;
  esac
done

if [ "$peer_name" == "" ]; then
usage
exit 1
fi

source /home/$USER/.profile

cd wireguard/keys
wg genkey | tee ${peer_name}_privatekey | wg pubkey > ${peer_name}_publickey

# cd /home/$USER/wireguard/config_files

declare -i counter=65
declare -i counter_full_vpn_access=50
server_ip=$master_host_ip_eth0
declare -i counter_used=$counter

if [ -f /home/$USER/wireguard/config_files/counter_full_vpn ]; then
    counter_full_vpn_access=$(cat /home/$USER/wireguard/config_files/counter_full_vpn)
fi

if [ -f /home/$USER/wireguard/config_files/counter ]; then
    counter=$(cat /home/$USER/wireguard/config_files/counter)
fi

# if [ "$environment" == "production" ]; then
server_ip=$load_balancer_dns_name
# fi

if [ "$admin" == "1" ]; then
echo "Creating ADMIN user type..."
if [ $counter_full_vpn_access -gt 61 ]; then
echo "Admin users limit reached!"
exit 1
fi
counter_full_vpn_access+=1
counter_used=$counter_full_vpn_access
cat << EOF | tee /home/$USER/wireguard/config_files/counter_full_vpn > /dev/null
$counter_full_vpn_access
EOF
else
echo "Creating normal user type..."
if [ $counter_full_vpn_access -gt 124 ]; then
echo "Normale users limit reached!"
exit 1
fi
counter+=1
counter_used=$counter
cat << EOF | tee /home/$USER/wireguard/config_files/counter > /dev/null
$counter
EOF
fi


interface_range=()
IFS='.' read -r -a interface_range <<< "$master_host_ip"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}
interface="$interface_1.$interface_2.0.0"
peer_ip="$interface_1.$interface_2.$interface_3.$counter_used"

echo -e "${LBLUE}Generating Configuration for $peer_name ${WHITE}"
sudo cat << EOF | tee /home/$USER/wireguard/config_files/${peer_name}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = $peer_ip/24
PrivateKey = $(cat ${peer_name}_privatekey)
Dns = ${master_host_ip}, 8.8.8.8, 8.8.4.4

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
