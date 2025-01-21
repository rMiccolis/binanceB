#!/bin/bash

# usage info
usage(){
  echo " Run this script to build and deploy client and server images when you need to apply changes to server or client code"
  echo ""
  echo "Usage:"
  echo "  $0 -s 1 -c 1 => will build both server and client"
  echo ""
  echo "  $0 -s 1 => will build just server"
  echo ""
  echo "Options:"
  echo "  pass 1 if you want to build client or server. If no arguments are provided, then both client and server will be built"
  echo ""
  exit
}

while getopts ":c:s:p:" opt; do
  case $opt in
    c) client="$OPTARG"
    ;;
    s) server="$OPTARG"
    ;;
    \?) usage
        exit
    ;;
  esac
done

# if $repository_root_dir is not set, then set its path
if [ -z ${repository_root_dir+x} ]; then repository_root_dir="/home/$USER"; fi

###############################################################################
# Build docker images from server and client applications
# cd into project root directory
cd $repository_root_dir/binanceB/

echo -e "${LBLUE}Pulling code...${WHITE}"
source /home/$USER/.profile
git checkout .
git pull origin $github_branch_name
cd ..
chmod -R u+x binanceB
cd $repository_root_dir/binanceB/


# if either client and server are not passed as argument set them to 1 (meaning we build both)
if [ -z "$client" ] && [ -z "$server" ]; then client=1; server=1; fi

if [ "$client" == "1" ]; then
# Set environment variable VITE_SERVER_URI
echo -e "${LBLUE}Setting Server IP address: Public or Private...${WHITE}"
# cluster_ip=$master_host_ip
# if [ "$environment" == "production" ]; then
# echo -e "${LBLUE}Setting Server Public IP address: $load_balancer_public_ip ${WHITE}"
# cluster_ip=$load_balancer_public_ip
# fi
# before building images we have to set a .env file to pass client its environment variables
echo -e "${LBLUE}Setting Server IP for client environment...${WHITE}"
protocol='http'
if [ "$host_ip_index" == "1" ]; then
    echo -e "${ORANGE}SETTING APPLICATION WITH =====> HTTPS PROTOCOL${WHITE}"
    protocol='https'
fi
cat << EOF | tee $repository_root_dir/binanceB/client/.env.production > /dev/null
VITE_SERVER_URI="$protocol://$app_server_addr/server/"
EOF

envsubst < $repository_root_dir/binanceB/client/capacitor.config.json | tee $repository_root_dir/binanceB/client/capacitor.config.json > /dev/null

# Start building docker client image
echo -e "${LBLUE}Building client docker image...${WHITE}"
sudo docker build -t $docker_username/$docker_client_repository_name -f ./client/client.dockerfile ./client/
# Push generated client docker image to docker hub
sudo docker push $docker_username/$docker_client_repository_name:latest
kubectl -n binance-b scale --replicas=0 deployment client; kubectl -n binance-b scale --replicas=1 deployment client
fi

if [ "$server" == "1" ]; then
echo -e "${LBLUE}Building server docker image...${WHITE}"
# Start building docker server image
sudo docker build -t $docker_username/$docker_server_repository_name -f ./server/docker/server.dockerfile ./server/

echo -e "${LBLUE}Building docker image for kubernetes jobs to be launched...${WHITE}"
# Start building docker image for kubernetes jobs to be launched
sudo docker build -t $docker_username/${docker_server_repository_name}_job -f ./server/docker/job.dockerfile ./server/

echo -e "${LBLUE}Pushing docker image to dockerhub...${WHITE}"
# Push generated server docker image to docker hub
sudo docker push $docker_username/$docker_server_repository_name:latest
sudo docker push $docker_username/${docker_server_repository_name}_job:latest
kubectl -n binance-b scale --replicas=0 deployment server; kubectl -n binance-b scale --replicas=$server_replica_count deployment server
fi
