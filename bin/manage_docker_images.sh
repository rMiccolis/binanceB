#!/bin/bash

###############################################################################
# Build docker images from server and client applications
# cd into project root directory
cd $repository_root_dir/binanceB/

# if [ $skip_docker_build != true ]; then
# return
# fi

# Set environment variable VITE_SERVER_URI
echo -e "${LBLUE}Setting Server IP address: Public or Private...${WHITE}"
cluster_ip=$master_host_ip
if [ "$environment" == "production" ]; then
cluster_ip=$cluster_public_ip
fi

# before building images we have to set a .env file to pass client its environment variables
echo -e "${LBLUE}Setting Server IP for client environment...${WHITE}"
cat << EOF | sudo tee $repository_root_dir/binanceB/client/.env.production > /dev/null
VITE_SERVER_URI="http://$cluster_ip/server/"
EOF

echo -e "${LBLUE}Building docker images...${WHITE}"
# Start building docker images
sudo docker build -t $docker_username/$docker_server_repository_name -f ./server/server.dockerfile ./server/
sudo docker build -t $docker_username/$docker_client_repository_name -f ./client/client.dockerfile ./client/

echo -e "${LBLUE}Pushing docker images to dockerhub...${WHITE}"
# Push generated docker images to docker hub
sudo docker push $docker_username/$docker_server_repository_name:latest
sudo docker push $docker_username/$docker_client_repository_name:latest