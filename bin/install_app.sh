#!/bin/bash

###############################################################################
# Configuring application settings
eval cluster_dns_name="$(jq -r '.cluster_dns_name | @sh' $config_file_path)"
export cluster_dns_name
eval server_access_token_secret="$(jq -r '.server_access_token_secret | @sh' $config_file_path | base64 --decode)"
eval server_refresh_token_secret="$(jq -r '.server_refresh_token_secret | @sh' $config_file_path | base64 --decode)"
eval server_access_token_lifetime="$(jq -r '.server_access_token_lifetime | @sh' $config_file_path)"
eval server_refresh_token_lifetime="$(jq -r '.server_refresh_token_lifetime | @sh' $config_file_path)"
eval mongo_root_username="$(jq -r '.mongo_root_username | @sh' $config_file_path | base64 --decode)"
eval mongo_root_password="$(jq -r '.mongo_root_password | @sh' $config_file_path | base64 --decode)"


envsubst < $repository_root_dir/kubernetes/mongodb/2-mongodb-secrets.yaml | sudo tee $repository_root_dir/kubernetes/mongodb/2-mongodb-secrets.yaml
envsubst < $repository_root_dir/kubernetes/server/3-server-secrets.yaml | sudo tee $repository_root_dir/kubernetes/server/3-server-secrets.yaml
envsubst < $repository_root_dir/kubernetes/server/4-server-configmap.yaml | sudo tee $repository_root_dir/kubernetes/server/4-server-configmap.yaml
envsubst < $repository_root_dir/kubernetes/client/3-client-configmap.yaml | sudo tee $repository_root_dir/kubernetes/client/3-client-configmap.yaml
