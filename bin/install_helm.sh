#!/bin/bash

###############################################################################
echo -e "${LBLUE}Downdloading helm package...${WHITE}"
sudo apt-get upgrade -y
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
echo -e "${LBLUE}installing helm package...${WHITE}"
./get_helm.sh
echo -e "${LBLUE}Helm package manager successfully installed!${WHITE}"
