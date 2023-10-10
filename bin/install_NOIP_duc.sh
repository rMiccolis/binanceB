#!/bin/bash

# INSTALL NO-IP Dynamic Update Client to update IP address to the ddns 'A' record on no-ip.com
###############################################################################

# usage info
usage(){
  echo " Run this script to install Dynamic Update Client for no-ip ddns update"
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


if [ '$noip_username' != '' ]; then

export load_balancer_dns_name=$(yq '.load_balancer_dns_name' $config_file_path)
export noip_username=$(yq '.noip_username' $config_file_path)
export noip_password=$(yq '.noip_password' $config_file_path)

mkdir noip
cd noip
wget https://dmej8g5cpdyqd.cloudfront.net/downloads/noip-duc_3.0.0-beta.7.tar.gz > /dev/null 2>&1
tar xf noip-duc_3.0.0-beta.7.tar.gz > /dev/null 2>&1
cd /home/$USER/noip/noip-duc_3.0.0-beta.7/binaries && sudo apt install ./noip-duc_3.0.0-beta.7_amd64.deb > /dev/null 2>&1

#make Dynamic Update Client run at system startup
sudo cp /home/$USER/noip/noip-duc_3.0.0-beta.7/debian/service /etc/systemd/system/noip-duc.service
cat << EOF | sudo tee /etc/default/noip-duc > /dev/null
## File: /etc/default/noip-duc
NOIP_USERNAME=$noip_username
NOIP_PASSWORD=$noip_password
NOIP_HOSTNAMES=$load_balancer_dns_name
NOIP_CHECK_INTERVAL=15m
EOF

# reload systemd daemon
sudo systemctl daemon-reload > /dev/null 2>&1
#Then enable the service:
sudo systemctl enable noip-duc > /dev/null 2>&1
# start the program:
sudo systemctl start noip-duc > /dev/null 2>&1

# noip-duc --username $noip_username --password $noip_password --hostnames $load_balancer_dns_name

fi