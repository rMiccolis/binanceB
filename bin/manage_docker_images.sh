#!/bin/bash

###############################################################################
# Build docker images from server and client applications
# cd into project root directory
cd $repository_root_dir/binanceB/

#before building images we have to set a .env file to pass client its environment variables
cat << EOF | sudo tee $repository_root_dir/binanceB/client/.env.production
VITE_SERVER_URI=http://$master_host_ip/server/
EOF

# Start building docker images
sudo docker build -t rmiccolis/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
sudo docker build -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/

# Push generated docker images to docker hub
sudo docker push rmiccolis/binanceb_nodejs_server:latest
sudo docker push rmiccolis/binanceb_vuejs_client:latest