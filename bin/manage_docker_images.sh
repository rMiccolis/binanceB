#!/bin/bash

###############################################################################
# Build docker images from server and client applications
# cd into project root directory
cd $repository_root_dir/binanceB/

# Set environment variable VITE_SERVER_URI
echo -e "${LBLUE}Setting Server IP address: Public or Private...${WHITE}"
environment=$(yq '.environment' $config_file_path)
cluster_ip=$master_host_ip
if [ "$environment" == "production" ]; then
cluster_ip=$(yq '.cluster_public_ip' $config_file_path)
fi

# before building images we have to set a .env file to pass client its environment variables
echo -e "${LBLUE}Setting Server IP for client environment...${WHITE}"
cat << EOF | sudo tee $repository_root_dir/binanceB/client/.env.production > /dev/null
VITE_SERVER_URI="http://$cluster_ip/server/"
EOF

echo -e "${LBLUE}Building docker images...${WHITE}"
# Start building docker images
sudo docker build -t $docker_username/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
sudo docker build -t $docker_username/binanceb_vuejs_client -f ./client/client.dockerfile ./client/

echo -e "${LBLUE}Pushing docker images to dockerhub...${WHITE}"
# Push generated docker images to docker hub
sudo docker push $docker_username/binanceb_nodejs_server:latest
sudo docker push $docker_username/binanceb_vuejs_client:latest