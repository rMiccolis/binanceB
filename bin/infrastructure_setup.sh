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

export config_file_path=$config_file_path

# set host name and address
eval ip_addr="$(hostname -I)"
export master_host_ip=$ip_addr
export master_host_name=$(whoami)
sudo hostnamectl set-hostname $master_host_name

echo -e "${GREEN}master_host_ip => $master_host_ip${WHITE}"
echo -e "${GREEN}master_host_name => $master_host_name${WHITE}"

# save host ip address into host file
cat << EOF | sudo tee -a /etc/hosts > /dev/null
$master_host_ip $master_host_name
EOF

# install jq library to read and parse json files
sudo apt-get install -y jq
# read hosts array from configuration file
hosts="$(jq -r '.hosts | @sh' $config_file_path)"
cluster_dns_name="$(jq -r '.cluster_dns_name | @sh' $config_file_path)"
#split hosts string into and array
hosts=($hosts)

# cleaning strings single quotes from elements read by json file through jq library
for h in "${!hosts[@]}"; do
  temp_host=${hosts[$h]}
  eval hosts[$h]=$temp_host
done

export repository_root_dir=$(pwd)

echo -e "${GREEN}Cluster worker host list:${WHITE}"

host_list=""
for h in "${hosts[@]}"; do
# adding remote hosts to the hosts file
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
if [ $master_host_name != $host_username ]; then
sudo tee -a /etc/hosts << EOF > /dev/null
$host_ip $host_username
EOF
fi
#adding remote host to the remote host list
host_list="$host_list $h"
echo -e "${LPURPLE}$h${WHITE}"
done
export host_list=$host_list

echo -e "${LPURPLE}----------------${WHITE}"
echo -e "${GREEN}Starting phase 0: Setting up host environment and dependencies: ===> HOST IP: $(hostname) - $(hostname -I)${WHITE}"


# add github to the list of known_hosts addresses
echo -e "${GREEN}Cloning private repository: ===> git@github.com:rMiccolis/binanceB.git${WHITE}"
ssh-keyscan github.com >> ~/.ssh/known_hosts
# clone github repository code
# git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git
# chmod -R u+x ./binanceB

cd binanceB

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
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1200s &
wait
echo -e "${GREEN}Starting phase 7 ===> Installing Helm (package manager for Kubernetes)${WHITE}"
./bin/install_helm.sh

echo -e "${GREEN}Starting phase 8 ===> Installing Nginx (to be used as a reverse proxy for Kubernetes cluster)${WHITE}"
./bin/install_nginx.sh

echo -e "${GREEN}Starting phase 9 ===> Applying configuration file and deployng the application to the cluster${WHITE}"
./bin/install_app.sh

echo -e "${GREEN}Waiting for the Application to get started...${WHITE}"
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1200s &
wait

echo -e "${GREEN}Application is correctly running!${WHITE}"
echo -e "${GREEN}Check it out at http://$cluster_dns_name/${WHITE}"