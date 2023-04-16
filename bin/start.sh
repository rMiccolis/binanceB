#!/bin/bash

############### IMPORTANT ###############
  # provide docker username (-du) and password (-dp)

#export colors for colored output strings
export BLACK="\033[0;30m"
export DARK_GREY="\033[1;30m"
export RED="\033[0;31m"
export LRED="\033[1;31m"
export GREEN="\033[0;32m"
export LGREEN="\033[1;32m"
export ORANGE="\033[0;33m"
export YELLOW="\033[1;33m"
export BLUE="\033[0;34m"
export LBLUE="\033[1;34m"
export PURPLE="\033[0;35m"
export LPURPLE="\033[1;35m"
export CYAN="\033[0;36m"
export LCYAN="\033[1;36m"
export LGRAY="\033[0;37m"
export WHITE="\033[1;37m"
echo -e "${GREEN}Starting phase 0: Setting up host environment and dependencies: ===> HOST IP: $(hostname) - $(hostname -I)${WHITE}"

while getopts du:dp: option
do
    case "${option}"
        in
        u)docker_username=${OPTARG};;
        p)docker_password=${OPTARG};;
    esac
done

# take sudof psw so it is asked just once and ensure that sudof is used just when really needed
echo "[sudo] password for m1:"; read -s sudoPass W
sudof  () {
  echo $sudoPass W | sudo-S "$@"
}
export sudoPass=$sudoPass
export -f sudof

# add github to the list of known_hosts addresses
echo -e "${GREEN}Cloning private repository: ===> git@github.com:rMiccolis/binanceB.git${WHITE}"
ssh-keyscan github.com >> ~/.ssh/known_hosts
# clone github repository code 
git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git
chmod u+x ./binanceB/bin/set-host-settings.sh
chmod u+x ./binanceB/bin/install-docker.sh
chmod u+x ./binanceB/bin/install-cri-docker.sh
chmod u+x ./binanceB/bin/install-kubernetes.sh
chmod u+x ./binanceB/bin/install-helm.sh
chmod u+x ./binanceB/bin/install-nginx.sh
chmod u+x ./binanceB/bin/install-app.sh
cd binanceB

echo -e "${GREEN}Starting phase 1 ===> Setting up host settings and dependencies: $(hostname -I)${WHITE}"
./bin/set-host-settings.sh
echo -e "${GREEN}Starting phase 2 ===> Installing Docker${WHITE}"
./bin/install-docker.sh -u $docker_username -p $docker_password
echo -e "${GREEN}Starting phase 2 ===> Installing Cri-Docker (Container Runtime Interface)${WHITE}"
./bin/install-cri-docker.sh
echo -e "${GREEN}Starting phase 2 ===> Installing Kubernetes${WHITE}"
./bin/install-kubernetes.sh
echo -e "${GREEN}Starting phase 2 ===> Installing Helm (package manager for Kubernetes)${WHITE}"
./bin/install-helm.sh
echo -e "${GREEN}Starting phase 2 ===> Installing Nginx (to be used as a reverse proxy for Kubernetes cluster)${WHITE}"
./bin/install-nginx.sh
