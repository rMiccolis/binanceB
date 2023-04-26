#!/bin/bash

# list of hosts IP that will join the cluster
hosts=()
############### IMPORTANT ###############
while getopts ":u:p:c:h:" opt; do
  case $opt in
    u) docker_username="$OPTARG"
    ;;
    p) docker_password="$OPTARG"
    ;;
    c) config_file_path="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit
    ;;
  esac
done

export config_file_path=$config_file_path

sudo apt-get install -y jq
export host_list=("$(jq -r '.hosts | @sh' $config_file_path)")

echo "${GREEN}Cluster host list:${WHITE}"
for h in ${host_list[@]}; do
  echo $h
done

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

# save host ip address
export ip_addr=$(hostname -I)
export host_name=$(cat /etc/hosts | grep -i 127.0.1.1 | awk 'NR==1{print $2}')
#hostnamectl set-hostname $host_name

# add github to the list of known_hosts addresses
echo -e "${GREEN}Cloning private repository: ===> git@github.com:rMiccolis/binanceB.git${WHITE}"
ssh-keyscan github.com >> ~/.ssh/known_hosts
# clone github repository code 
git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git
chmod u+x ./binanceB/bin/set_host_settings.sh
chmod u+x ./binanceB/bin/install_docker.sh
chmod u+x ./binanceB/bin/install_cri_docker.sh
chmod u+x ./binanceB/bin/install_kubernetes.sh
chmod u+x ./binanceB/bin/init_kubernetes_cluster.sh
chmod u+x ./binanceB/bin/setup_worker_nodes.sh
chmod u+x ./binanceB/bin/install_helm.sh
chmod u+x ./binanceB/bin/install_nginx.sh
chmod u+x ./binanceB/bin/install_app.sh
cd binanceB

export repository_root_dir=$(pwd)

echo -e "${GREEN}Starting phase 1 ===> Setting up host settings and dependencies: $(hostname -I)${WHITE}"
./bin/set_host_settings.sh

echo -e "${GREEN}Starting phase 2 ===> Installing Docker${WHITE}"
./bin/install_docker.sh
echo "${LBLUE}Docker Hub login with username: $docker_username${WHITE}";
# login into docker
sudo docker login --username $docker_username --password $docker_password

echo -e "${GREEN}Starting phase 3 ===> Installing Cri-Docker (Container Runtime Interface)${WHITE}"
./bin/install_cri_docker.sh

echo -e "${GREEN}Starting phase 4 ===> Installing Kubernetes${WHITE}"
./bin/install_kubernetes.sh

echo -e "${GREEN}Starting phase 5 ===> Initialize Kubernetes cluster${WHITE}"
./bin/init_kubernetes_cluster.sh

echo -e "${GREEN}Starting phase 6 ===> Setup worker nodes and joining them to cluster ${WHITE}"
./bin/setup_worker_nodes.sh
wait
echo -e "${GREEN}Starting phase 7 ===> Installing Helm (package manager for Kubernetes)${WHITE}"
./bin/install_helm.sh

echo -e "${GREEN}Starting phase 8 ===> Installing Nginx (to be used as a reverse proxy for Kubernetes cluster)${WHITE}"
./bin/install_nginx.sh

echo -e "${GREEN}Starting phase 9 ===> Applying configuration file and deployng the application to the cluster${WHITE}"
./bin/install_app.sh

echo -e "${GREEN}Starting phase 10 ===> Starting Application...${WHITE}"
kubectl apply -f ./kubernetes/app/1-namespaces/
kubectl apply -f ./kubernetes/app/2-mongodb/
kubectl apply -f ./kubernetes/app/3-server/
kubectl apply -f ./kubernetes/app/4-client/

echo -e "${GREEN}Waiting for the Application to get started...${WHITE}"
sleep 120
status=$(kubectl get pods --all-namespaces --field-selector status.phase!=Running)

if [[ $a != NAMESPACE* ]]
then
  echo -e "${GREEN}Application is correctly running!${WHITE}"
  echo -e "${GREEN}Check it out at http://$cluster_dns_name/${WHITE}"
else
  echo -e "${RED}Something is not working... :( ${WHITE}"
  echo -e "${YELLOW}kubectl get pod -A to see what is not working!(${WHITE}"
