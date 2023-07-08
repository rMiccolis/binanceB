#!/bin/bash

start_time="$(date -u +%s)"

# usage info
usage(){
  echo " Run this script to configure all the nodes provided from main_config.yaml and to build and start all the application."
  echo " This script manages the control plane(s) and worker nodes: creates and adds them to the cluster"
  echo ""
  echo "Usage:"
  echo "  $0 -c '/path/to/the/main_config.yaml' => see the main_config.example.yaml in the root directory for an example"
  echo ""
  echo "Options:"
  echo "  -c argument : the path to the main_config.yaml file"
  echo ""
  echo "  if no arguments are provided, then script exits"
  echo ""
  exit
}

############### IMPORTANT ###############
while getopts ":c:" opt; do
  case $opt in
    c) config_file_path="$OPTARG"
    ;;
    \?) usage
        exit
    ;;
  esac
done

if [ -z "$config_file_path" ]; then usage; exit; fi

# export colors to highlight output text in console
. ./binanceB/bin/export_colors.sh # executed this way: . ./filename to let exported variables into the script to be added to (this) main process
                                  # if executed this other way: ./filename filename open a new shell that is closed when script ends. So exported variables are not visible here

echo -e "${LGREEN}Starting phase 0 / 10: Reading data and preparing working environment:${WHITE}"
export config_file_path=$config_file_path
. ./binanceB/bin/prepare_environment.sh

echo -e "${LGREEN}Starting phase 1 / 10 ===> Setting up host settings and dependencies: $(hostname -I)${WHITE}"
./binanceB/bin/set_host_settings.sh
echo -e "${LGREEN}Phase 1 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 2 / 10 ===> Installing Docker${WHITE}"
./binanceB/bin/install_docker.sh
echo -e "${LGREEN}Phase 2 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Docker Hub login with username: $docker_username${WHITE}";
# login into docker
sudo docker login --username $docker_username --password $docker_access_token > /dev/null 2>&1
echo -e "${LGREEN}Login succeded!!${WHITE}"


echo -e "${LGREEN}Starting phase 3 / 10 ===> Installing Cri-Docker (Container Runtime Interface)${WHITE}"
./binanceB/bin/install_cri_docker.sh
echo -e "${LGREEN}Phase 3 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 4 / 10 ===> Installing Kubernetes${WHITE}"
./binanceB/bin/install_kubernetes.sh
echo -e "${LGREEN}Phase 4 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 5 / 10 ===> Initialize Kubernetes cluster${WHITE}"
./binanceB/bin/init_kubernetes_cluster.sh
echo -e "${LGREEN}Phase 5 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 6 / 10 ===> Setup worker nodes and joining them to cluster ${WHITE}"
./binanceB/bin/setup_worker_nodes.sh
echo -e "${LGREEN}Phase 6 / 10 ===> Operation Done!${WHITE}"

echo -e "${LGREEN}Starting phase 7 / 10 ===> Installing Helm (package manager for Kubernetes)${WHITE}"
./binanceB/bin/install_helm.sh
echo -e "${LGREEN}Phase 7 / 10 ===> Operation Done!${WHITE}"

echo -e "${LGREEN}Starting EXTRA phase ===> Installing metallb${WHITE}"
./binanceB/bin/install_metallb.sh
echo -e "${LGREEN}EXTRA Phase ===> Operation Done!${WHITE}"

echo -e "${LGREEN}Starting phase 8 / 10 ===> Installing Nginx (to be used as a reverse proxy for Kubernetes cluster)${WHITE}"
./binanceB/bin/install_nginx.sh
echo -e "${LGREEN}Phase 8 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 9 / 10 ===> Building server and client docker images and pushing them to docker hub${WHITE}"
./binanceB/bin/manage_docker_images.sh
echo -e "${LGREEN}Phase 9 / 10 ===> Operation Done!${WHITE}"


echo -e "${LGREEN}Starting phase 10 / 10 ===> Applying configuration file and deployng the application to the cluster${WHITE}"
./binanceB/bin/install_app.sh
echo -e "${LGREEN}Phase 10 / 10 ===> Operation Done!${WHITE}"

end_time="$(date -u +%s)"
elapsed_time=$(($end_time-$start_time))
elapsed_time=$(($elapsed_time/60))
echo -e "${LGREEN}Elapsed time:'$(($elapsed_time))' minutes ${WHITE}"

echo -e "${LGREEN}Waiting for the Application to get started...${WHITE}"
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait


echo -e "${LGREEN}Application is correctly running!${WHITE}"
echo -e "${LGREEN}Check it out at http://$cluster_dns_name/${WHITE}"
end_time="$(date -u +%s)"
elapsed_time=$(($end_time-$start_time))
elapsed_time=$(($elapsed_time/60))
echo -e "${LGREEN}Elapsed time:'$(($elapsed_time))' minutes ${WHITE}"