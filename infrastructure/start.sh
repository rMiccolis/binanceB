#!/bin/bash

# list of hosts IP that will join the cluster
hosts=()
############### IMPORTANT ###############
while getopts ":u:p:c:" opt; do
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

export docker_username=$docker_username
export LGREEN="\033[1;32m"
export WHITE="\033[1;37m"

# clone github repository code 
echo -e "${LGREEN}Cloning code repository...${WHITE}"
git clone --single-branch --branch cloud-init git@github.com:rMiccolis/binanceB.git /home/$host_username/binanceB
chmod -R u+x ./binanceB
echo -e "${LCYAN}Operation Done!${WHITE}"

# export colors to highlight output text in console
. ./binanceB/bin/export_colors.sh # executed this way: . ./filename to let exported variables into the script to be added to (this) main process
                                  # if executed this other way: ./filename filename open a new shell that is closed when script ends. So exported variables are not visible here


echo -e "${LGREEN}Starting phase 0: Reading data and preparing working environment:${WHITE}"
export config_file_path=$config_file_path
. ./binanceB/bin/prepare_environment.sh

echo -e "${LGREEN}Starting phase 1 ===> Setting up host settings and dependencies: $(hostname -I)${WHITE}"
./binanceB/bin/set_host_settings.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 2 ===> Installing Docker${WHITE}"
./binanceB/bin/install_docker.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Docker Hub login with username: $docker_username${WHITE}";
# login into docker
sudo docker login --username $docker_username --password $docker_password > /dev/null 2>&1
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 3 ===> Installing Cri-Docker (Container Runtime Interface)${WHITE}"
./binanceB/bin/install_cri_docker.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 4 ===> Installing Kubernetes${WHITE}"
./binanceB/bin/install_kubernetes.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 5 ===> Initialize Kubernetes cluster${WHITE}"
./binanceB/bin/init_kubernetes_cluster.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 6 ===> Setup worker nodes and joining them to cluster ${WHITE}"
./binanceB/bin/setup_worker_nodes.sh
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
echo -e "${LCYAN}Operation Done!${WHITE}"

echo -e "${LGREEN}Starting phase 7 ===> Installing Helm (package manager for Kubernetes)${WHITE}"
./binanceB/bin/install_helm.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 8 ===> Installing Nginx (to be used as a reverse proxy for Kubernetes cluster)${WHITE}"
./binanceB/bin/install_nginx.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 9 ===> Building server and client docker images and pushing them to docker hub${WHITE}"
./binanceB/bin/manage_docker_images.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 10 ===> Applying configuration file and deployng the application to the cluster${WHITE}"
./binanceB/bin/install_app.sh
echo -e "${LCYAN}Operation Done!${WHITE}"


echo -e "${LGREEN}Waiting for the Application to get started...${WHITE}"
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait


echo -e "${LGREEN}Application is correctly running!${WHITE}"
echo -e "${LGREEN}Check it out at http://$cluster_dns_name/${WHITE}"