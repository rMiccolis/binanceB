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

reload_images=0

echo -e "${LBLUE}Pulling code...${WHITE}"
source /home/$USER/.profile
reload_images=1
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
cluster_ip=$master_host_ip
if [ "$environment" == "production" ]; then
echo -e "${LBLUE}Setting Server Public IP address: $cluster_public_ip ${WHITE}"
cluster_ip=$cluster_public_ip
fi
# before building images we have to set a .env file to pass client its environment variables
echo -e "${LBLUE}Setting Server IP for client environment...${WHITE}"
cat << EOF | tee $repository_root_dir/binanceB/client/.env.production > /dev/null
VITE_SERVER_URI="http://$cluster_ip/server/"
EOF

# Start building docker client image
echo -e "${LBLUE}Building client docker image...${WHITE}"
sudo docker build -t $docker_username/$docker_client_repository_name -f ./client/client.dockerfile ./client/
# Push generated client docker image to docker hub
sudo docker push $docker_username/$docker_client_repository_name:latest
fi

if [ "$server" == "1" ]; then
echo -e "${LBLUE}Building server docker image...${WHITE}"
# Start building docker server image
sudo docker build -t $docker_username/$docker_server_repository_name -f ./server/server.dockerfile ./server/

echo -e "${LBLUE}Pushing docker image to dockerhub...${WHITE}"
# Push generated server docker image to docker hub
sudo docker push $docker_username/$docker_server_repository_name:latest
fi

if [ "$reload_images" == "1" ]; then 
kubectl -n binance-b scale --replicas=0 deployment server; kubectl -n binance-b scale --replicas=1 deployment server
kubectl -n binance-b scale --replicas=0 deployment client; kubectl -n binance-b scale --replicas=1 deployment client
fi
