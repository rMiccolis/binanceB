#!/bin/bash

###############################################################################
# Configuring application settings
eval cluster_dns_name="$(jq -r '.cluster_dns_name | @sh' $config_file_path)"
export cluster_dns_name=$cluster_dns_name

eval server_access_token_secret="$(jq -r '.server_access_token_secret | @sh' $config_file_path)"
server_access_token_secret=$(echo $server_access_token_secret | base64)
export server_access_token_secret=$server_access_token_secret

eval server_refresh_token_secret="$(jq -r '.server_refresh_token_secret | @sh' $config_file_path)"
server_refresh_token_secret=$(echo $server_refresh_token_secret | base64)
export server_refresh_token_secret=$server_refresh_token_secret

eval server_access_token_lifetime="$(jq -r '.server_access_token_lifetime | @sh' $config_file_path)"
export server_access_token_lifetime=$server_access_token_lifetime

eval server_refresh_token_lifetime="$(jq -r '.server_refresh_token_lifetime | @sh' $config_file_path)"
export server_refresh_token_lifetime=$server_refresh_token_lifetime

eval mongo_root_username="$(jq -r '.mongo_root_username | @sh' $config_file_path)"
mongo_root_username=$(echo $mongo_root_username | base64)
export mongo_root_username=$mongo_root_username

eval mongo_root_password="$(jq -r '.mongo_root_password | @sh' $config_file_path)"
mongo_root_password=$(echo $mongo_root_password | base64)
export mongo_root_password=$mongo_root_password

mkdir /home/$USER/temp
cp $repository_root_dir/binanceB/kubernetes/app/ /home/$USER/temp
envsubst < $repository_root_dir/binanceB/kubernetes/app/2-mongodb/2-mongodb-secrets.yaml | sudo tee /home/$USER/temp/binanceB/kubernetes/app/2-mongodb/2-mongodb-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/3-server-secrets.yaml | sudo tee /home/$USER/temp/binanceB/kubernetes/app/3-server/3-server-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/4-server-configmap.yaml | sudo tee /home/$USER/temp/binanceB/kubernetes/app/3-server/4-server-configmap.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/4-client/3-client-configmap.yaml | sudo tee /home/$USER/temp/binanceB/kubernetes/app/4-client/3-client-configmap.yaml > /dev/null

echo -e "${GREEN}Starting Application...${WHITE}"
kubectl apply -f /home/$USER/temp/1-namespaces/
kubectl apply -f /home/$USER/temp/2-mongodb/
kubectl apply -f /home/$USER/temp/3-server/
kubectl apply -f /home/$USER/temp/4-client/

rm -rf /home/$USER/temp