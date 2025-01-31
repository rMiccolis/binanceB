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

# install qrencode to print a QR code to be scanned by smartphone to join vpn on wireguard app
sudo apt install qrencode -y > /dev/null 2>&1

load_balancer_public_ip=$(yq '.load_balancer_public_ip' $config_file_path)
load_balancer_dns_name=$(yq '.load_balancer_dns_name' $config_file_path)
environment=$(yq '.environment' $config_file_path)

hosts=()
hosts+=($(yq '.master_host' $config_file_path))
hosts+=($(yq '.hosts[]' $config_file_path))
master_host_ip=""
master_host_name=""
master_host_ip_vpn=""
master_host_ip_vpn_addr=""
master_host_ip_vpn_for_dns=""

cd
mkdir wireguard
cd wireguard
mkdir keys
mkdir config_files
cd keys

echo -e "${LBLUE}Installing Resolvconf for $USER ${WHITE}"
sudo apt install resolvconf > /dev/null 2>&1
sudo systemctl enable resolvconf.service > /dev/null 2>&1
sudo systemctl start resolvconf.service > /dev/null 2>&1
# sudo systemctl status resolvconf.service

# sudo cat << EOF | sudo tee -a /etc/resolvconf/resolv.conf.d/head > /dev/null
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# EOF
# sudo systemctl restart resolvconf.service
# sudo systemctl restart systemd-resolved.service

echo -e "${LBLUE}Installing Wireguard for $USER ${WHITE}"
sudo apt install wireguard -y > /dev/null 2>&1
umask 077

interface_range=()

for h in "${hosts[@]}"; do
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
host_ip_vpn=${host_string[2]}
master_host_ip_vpn_addr=${host_string[2]}

echo -e "${LBLUE}Generating keys for $host_username ${WHITE}"
wg genkey | tee ${host_username}_privatekey | wg pubkey > ${host_username}_publickey

if [ "${host_username}" == "m1" ]; then

# master_host_ip=$host_ip
master_host_ip_vpn="${host_ip_vpn}/16"
master_host_ip_vpn_for_dns=${host_ip_vpn}
master_host_name=$host_username

IFS='.' read -r -a interface_range <<< "$master_host_ip_vpn"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}
interface="$interface_1.$interface_2.0.0"

# if [ "$environment" == "production" ]; then
echo -e "${LBLUE}Setting Server Public IP address: $load_balancer_public_ip ${WHITE}"
master_host_ip=$load_balancer_dns_name
# fi

sudo chown root:${host_username} /etc/wireguard/
sudo chmod -R 777 /etc/wireguard/

sudo chown root:${host_username} /etc/sysctl.d
sudo chmod -R 777 /etc/sysctl.d

sudo cat << 'EOF' | sudo tee /etc/wireguard/postup.sh > /dev/null
WG_INTERFACE="wg0"
MASQUERADE_INTERFACE="eth0"
ADMIN_IPRANGE=10.11.1.1/26
USERS_IPRANGE=10.11.1.64/26
WG_LAN=10.11.1.1/24
LAN_NETWORK=192.168.1.2/24

# set default iptables FORWARD chain policy to DROP
sudo iptables -P FORWARD DROP

iptables -I FORWARD -i $WG_INTERFACE -s $ADMIN_IPRANGE -j ACCEPT;
iptables -I FORWARD -o $WG_INTERFACE -s $ADMIN_IPRANGE -j ACCEPT;
iptables -t nat -A POSTROUTING -o $MASQUERADE_INTERFACE -s $ADMIN_IPRANGE -j MASQUERADE;
iptables -I FORWARD -i $WG_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j ACCEPT;
iptables -I FORWARD -o $WG_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j ACCEPT;
iptables -t nat -A POSTROUTING -o $MASQUERADE_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j MASQUERADE;
EOF

sudo cat << 'EOF' | sudo tee /etc/wireguard/postdown.sh > /dev/null
WG_INTERFACE="wg0"
MASQUERADE_INTERFACE="eth0"
ADMIN_IPRANGE=10.11.1.1/26
USERS_IPRANGE=10.11.1.64/26
WG_LAN=10.11.1.1/24
LAN_NETWORK=192.168.1.2/24

# set default iptables FORWARD chain policy to ACCEPT
sudo iptables -P FORWARD ACCEPT

iptables -D FORWARD -i $WG_INTERFACE -s $ADMIN_IPRANGE -j ACCEPT;
iptables -D FORWARD -o $WG_INTERFACE -s $ADMIN_IPRANGE -j ACCEPT;
iptables -t nat -D POSTROUTING -o $MASQUERADE_INTERFACE -s $ADMIN_IPRANGE -j MASQUERADE;
iptables -D FORWARD -i $WG_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j ACCEPT;
iptables -D FORWARD -o $WG_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j ACCEPT;
iptables -t nat -D POSTROUTING -o $MASQUERADE_INTERFACE -s $USERS_IPRANGE -d $LAN_NETWORK,$WG_LAN -j MASQUERADE;
EOF

sudo chmod 777 /etc/wireguard/postup.sh
sudo chmod 777 /etc/wireguard/postdown.sh

# Example of postup.sh and postdown.sh rules with actual values
# PostUp = iptables -I FORWARD -i %i -s 10.11.1.1/26 -j ACCEPT; iptables -I FORWARD -o %i -s 10.11.1.1/26 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -s 10.11.1.1/26 -j MASQUERADE; iptables -I FORWARD -i %i -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j ACCEPT; iptables -I FORWARD -o %i -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j MASQUERADE;
# PostDown = iptables -D FORWARD -i %i -s 10.11.1.1/26 -j ACCEPT; iptables -D FORWARD -o %i -s 10.11.1.1/26 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -s 10.11.1.1/26 -j MASQUERADE; iptables -D FORWARD -i %i -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j ACCEPT; iptables -D FORWARD -o %i -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -s 10.11.1.64/26 -d 192.168.1.2/24,10.11.1.1/24 -j MASQUERADE;

echo -e "${LBLUE}Generating Configuration for $host_username ${WHITE}"
sudo cat << EOF | tee /etc/wireguard/wg0.conf > /dev/null
[Interface]
Address = ${host_ip_vpn}/24
ListenPort = 51820
PrivateKey = $(cat ${host_username}_privatekey)
SaveConfig = true
PostUp = /etc/wireguard/postup.sh
PostDown = /etc/wireguard/postdown.sh
EOF

echo -e "${LBLUE}Activating wg0 Interface for $host_username and Enable IP Forwarding${WHITE}"
# sudo cat << EOF | tee -a /etc/sysctl.d/70-wireguard-routing.conf > /dev/null
# net.ipv4.ip_forward = 1
# net.ipv4.conf.all.proxy_arp = 1
# EOF
# sudo sysctl -p /etc/sysctl.d/70-wireguard-routing.conf -w

# Enable IP Forwarding on the server:
# This tells the server it should pass along any traffic that is meant for a different computer on its network.
sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1

# make wireguard start on boot
sudo systemctl enable wg-quick@wg0.service > /dev/null 2>&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl start wg-quick@wg0 > /dev/null 2>&1
# systemctl status wg-quick@wg0
else

ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
wait

echo -e "${LBLUE}Installing Resolvconf for $host_username ${WHITE}"
ssh ${host_username}@$host_ip "sudo apt install resolvconf > /dev/null 2>&1" &
wait
ssh ${host_username}@$host_ip "sudo systemctl enable resolvconf.service" &
wait
ssh ${host_username}@$host_ip "sudo systemctl start resolvconf.service" &
wait

echo -e "${LBLUE}Installing Wireguard for $host_username ${WHITE}"
ssh ${host_username}@$host_ip "sudo apt install wireguard -y > /dev/null 2>&1" &
wait
ssh ${host_username}@$host_ip "umask 077" &
wait

echo -e "${LBLUE}Generating Configuration for $host_username ${WHITE}"

# Dns = ${master_host_ip_vpn_for_dns}, 8.8.8.8, 8.8.4.4
sudo cat << EOF | tee -a /etc/wireguard/${host_username}_wg0.conf > /dev/null
[Interface]
ListenPort = 51820
Address = ${host_ip_vpn}/24
PrivateKey = $(cat ${host_username}_privatekey)
PostUp = resolvectl dns %i ${master_host_ip_vpn_addr} 8.8.8.8 8.8.4.4; resolvectl domain %i ~

[Peer]
PublicKey = $(cat ${master_host_name}_publickey)
Endpoint = ${master_host_ip}:51820
AllowedIPs = $interface/16
PersistentKeepalive = 30
EOF

ssh ${host_username}@$host_ip "sudo chown root:${host_username} /etc/wireguard/" &
wait
ssh ${host_username}@$host_ip "sudo chmod -R 777 /etc/wireguard/" &
wait

# ssh ${host_username}@$host_ip "sudo chown root:${host_username} /etc/sysctl.d" &
# wait
# ssh ${host_username}@$host_ip "sudo chmod -R 777 /etc/sysctl.d" &
# wait

echo -e "${LBLUE}Sending peer Configuration to $host_username ${WHITE}"
scp -q /etc/wireguard/${host_username}_wg0.conf ${host_username}@$host_ip:/etc/wireguard/wg0.conf &
wait

# echo -e "${LBLUE}setting IP forwarding configuration ${WHITE}"
# scp -q /etc/sysctl.d/70-wireguard-routing.conf ${host_username}@$host_ip:/etc/sysctl.d/70-wireguard-routing.conf &
# wait

# ssh ${host_username}@$host_ip "sudo sysctl -p /etc/sysctl.d/70-wireguard-routing.conf -w" &
# wait

echo -e "${LBLUE}Applying peer Configuration to $host_username${WHITE}"
# make wireguard start on boot
ssh ${host_username}@$host_ip "sudo systemctl enable wg-quick@wg0.service > /dev/null 2>&1" &
wait
ssh ${host_username}@$host_ip "sudo systemctl daemon-reload > /dev/null 2>&1" &
wait
ssh ${host_username}@$host_ip "sudo systemctl start wg-quick@wg0 > /dev/null 2>&1" &
wait
# ssh ${host_username}@$host_ip "systemctl status wg-quick@wg0" &
# wait
# ssh ${host_username}@$host_ip "sudo wg-quick up wg0" &
# wait

echo -e "${LBLUE}Adding peer $host_username to server Configuration ${WHITE}"
sudo wg set wg0 peer "$(cat ${host_username}_publickey)" allowed-ips ${host_ip_vpn}/32
sudo ip -4 route add ${host_ip_vpn}/32 dev wg0

#############################################################

#echo new cron into cron file
cat << EOF | sudo tee -a /home/$USER/wg_ddns_update > /dev/null
sudo wg set wg0 peer $(cat ${master_host_name}_publickey) endpoint ${master_host_ip}:51820
EOF

scp -q /home/$USER/wg_ddns_update ${host_username}@$host_ip:/home/$host_username/wg_ddns_update &
wait

#install new cron job
cronjob=""
#write out current crontab
ssh ${host_username}@$host_ip "crontab -l > /home/$host_username/cron_ddns_wg_update" &
wait
#echo new cron into cron file
ssh ${host_username}@$host_ip 'echo "0 1 * * * /home/$USER/wg_ddns_update.sh" >> /home/$USER/cron_ddns_wg_update' &
wait
#install new cron file
ssh ${host_username}@$host_ip "crontab /home/$host_username/cron_ddns_wg_update" &
wait
# ssh ${host_username}@$host_ip "rm /home/$host_username/cron_ddns_wg_update" &
# wait

#############################################################


fi

done

sudo wg-quick down wg0
# sudo chown -R root:${host_username} /etc/wireguard/
# sudo chmod -R 777 /etc/wireguard/
sudo wg-quick up wg0
