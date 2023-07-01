#!/bin/bash

###############################################################################
echo -e "${LBLUE}Reading and processing application settings from input file...${WHITE}"

# Configuring application settings
export server_access_token_secret=$(echo -n $(yq '.server_access_token_secret' $config_file_path) | base64)

export server_refresh_token_secret=$(echo -n $(yq '.server_refresh_token_secret' $config_file_path) | base64)

export server_access_token_lifetime=$(yq '.server_access_token_lifetime' $config_file_path)

export server_refresh_token_lifetime=$(yq '.server_refresh_token_lifetime' $config_file_path)

export mongo_root_username=$(echo -n $(yq '.mongo_root_username' $config_file_path) | base64)

export mongo_root_password=$(echo -n $(yq '.mongo_root_password' $config_file_path) | base64)

mkdir /home/$USER/temp
cp -R $repository_root_dir/binanceB/kubernetes/app/* /home/$USER/temp
envsubst < $repository_root_dir/binanceB/kubernetes/app/2-mongodb/2-mongodb-secrets.yaml | sudo tee /home/$USER/temp/2-mongodb/2-mongodb-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/3-server-secrets.yaml | sudo tee /home/$USER/temp/3-server/3-server-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/4-server-configmap.yaml | sudo tee /home/$USER/temp/3-server/4-server-configmap.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/5-server-deployment.yaml | sudo tee /home/$USER/temp/3-server/5-server-deployment.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/4-client/4-client-deployment.yaml | sudo tee /home/$USER/temp/4-client/4-client-deployment.yaml > /dev/null

echo -e "${LBLUE}Starting Application...${WHITE}"
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
kubectl apply -f /home/$USER/temp/1-namespaces/
kubectl apply -f /home/$USER/temp/2-mongodb/
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
# when all mongodb replicas are created, let's setup the replicaset
kubectl exec mongodb-replica-0 -n mongodb "mongosh rs.initiate()"
kubectl exec mongodb-replica-0 -n mongodb "mongosh var cfg = rs.conf()"
kubectl exec mongodb-replica-0 -n mongodb "mongosh cfg.members[0].host="mongodb-replica-0.mongodb:27017""
kubectl exec mongodb-replica-0 -n mongodb "mongosh rs.reconfig(cfg)"
kubectl exec mongodb-replica-0 -n mongodb "mongosh rs.add("mongodb-replica-1.mongodb:27017")"
# kubectl exec mongodb-replica-0 -n mongodb "mongosh rs.add("mongodb-replica-2.mongodb:27017")"
kubectl exec mongodb-replica-0 -n mongodb "mongosh rs.status()"


kubectl apply -f /home/$USER/temp/3-server/
kubectl apply -f /home/$USER/temp/4-client/

# rm -rf /home/$USER/temp
# rm -rf /home/$USER/main_config.yaml