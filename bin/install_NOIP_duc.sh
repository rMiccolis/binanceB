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

export application_dns_name=$(yq '.application_dns_name' $config_file_path)
export noip_username=$(yq '.noip_username' $config_file_path)
export noip_password=$(yq '.noip_password' $config_file_path)

mkdir noip
cd noip
wget https://dmej8g5cpdyqd.cloudfront.net/downloads/noip-duc_3.0.0-beta.7.tar.gz
tar xf noip-duc_3.0.0-beta.7.tar.gz
cd /home/$USER/noip/noip-duc_3.0.0-beta.7/binaries && sudo apt install ./noip-duc_3.0.0-beta.7_amd64.deb

#make Dynamic Update Client run at system startup
sudo cp /home/$USER/noip/noip-duc_3.0.0-beta.7/debian/service /etc/systemd/system/noip-duc.service
cat << EOF | sudo tee /etc/default/noip-duc > /dev/null
## File: /etc/default/noip-duc
NOIP_USERNAME=$noip_username
NOIP_PASSWORD=$noip_password
NOIP_HOSTNAMES=$load_balancer_dns_name
EOF

# reload systemd daemon
sudo systemctl daemon-reload
#Then enable the service:
sudo systemctl enable noip-duc
# start the program:
sudo systemctl start noip-duc

# noip-duc --username $noip_username --password $noip_password --hostnames $load_balancer_dns_name

fi