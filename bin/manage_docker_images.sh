#!/bin/bash

###############################################################################
# Build docker images from server and client applications
# cd into project root directory
cd $repository_root_dir/binanceB/

eval environment="$(jq -r '.environment | @sh' $config_file_path)"
cluster_ip=$master_host_ip
if [ "$environment" == "production" ]; then
eval cluster_public_ip="$(jq -r '.cluster_public_ip | @sh' $config_file_path)"
cluster_ip=$cluster_public_ip
fi

#before building images we have to set a .env file to pass client its environment variables
cat << EOF | sudo tee $repository_root_dir/binanceB/client/.env.production
VITE_SERVER_URI="http://$cluster_ip/server/"
EOF

# Start building docker images
sudo docker build -t rmiccolis/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
sudo docker build -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/

# Push generated docker images to docker hub
sudo docker push rmiccolis/binanceb_nodejs_server:latest
sudo docker push rmiccolis/binanceb_vuejs_client:latest