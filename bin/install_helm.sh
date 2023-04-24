#!/bin/bash

###############################################################################
echo -e "${LBLUE}Downdloading helm package...${WHITE}"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
echo -e "${LBLUE}installing helm package...${WHITE}"
sudo ./get_helm.sh
echo -e "${LBLUE}Helm package manager successfully installed!${WHITE}"
