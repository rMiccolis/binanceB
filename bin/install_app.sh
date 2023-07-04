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
envsubst < $repository_root_dir/binanceB/kubernetes/app/2-mongodb/3-mongodb-secrets.yaml | sudo tee /home/$USER/temp/2-mongodb/3-mongodb-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/2-mongodb/6-mongodb-statefulset.yaml | sudo tee /home/$USER/temp/2-mongodb/6-mongodb-statefulset.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/3-server-secrets.yaml | sudo tee /home/$USER/temp/3-server/3-server-secrets.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/4-server-configmap.yaml | sudo tee /home/$USER/temp/3-server/4-server-configmap.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/3-server/5-server-deployment.yaml | sudo tee /home/$USER/temp/3-server/5-server-deployment.yaml > /dev/null
envsubst < $repository_root_dir/binanceB/kubernetes/app/4-client/4-client-deployment.yaml | sudo tee /home/$USER/temp/4-client/4-client-deployment.yaml > /dev/null

echo -e "${LBLUE}Starting Application...${WHITE}"
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
kubectl apply -f /home/$USER/temp/1-namespaces/
kubectl apply -f /home/$USER/temp/2-mongodb/

# let's wait for mongodb stateful set to be ready
exit_loop=""
ready_sts_condition="$mongodb_replica_count/$mongodb_replica_count"
while [ "$exit_loop" != "$ready_sts_condition" ]; do
    sleep 10
    exit_loop=$(kubectl get sts -n mongodb | awk 'NR==2{print $2}')
    echo "StatefulSet pod ready: $exit_loop"
done

# when all mongodb replicas are created, let's setup the replicaset
members=()
for i in $(seq $mongodb_replica_count); do
    replica_index="$(($i-1))"
    if [ "$i" != "$mongodb_replica_count" ]; then
        member_str="{ _id: $replica_index, host : '"mongodb-replica-$replica_index.mongodb:27017"' },"
    else
        member_str="{ _id: $replica_index, host : '"mongodb-replica-$replica_index.mongodb:27017"' }"
    fi
    members+=($member_str)
done
initiate_command="rs.initiate({ _id: 'rs0',version: 1,members: [ ${members[@]} ] })"
kubectl exec -it -n mongodb mongodb-replica-0 -- mongosh '$initiate_command'

echo -n "${LBLUE}EXECUTED: mongosh '$initiate_command' ${WHITE}"

kubectl exec -n mongodb mongodb-replica-0 mongosh 'rs.status()'

kubectl apply -f /home/$USER/temp/3-server/
kubectl apply -f /home/$USER/temp/4-client/

# rm -rf /home/$USER/temp
# rm -rf /home/$USER/main_config.yaml