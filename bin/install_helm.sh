#!/bin/bash

###############################################################################
echo -e "${LBLUE}Downdloading helm package...${WHITE}"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 > /dev/null 2>&1
chmod 777 get_helm.sh
echo -e "${LBLUE}installing helm package...${WHITE}"
./get_helm.sh > /dev/null 2>&1

sudo chown root:${USER} /usr/local/bin/helm
sudo chmod -R 777 /usr/local/bin/helm