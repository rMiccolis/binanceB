#!/bin/bash

# usage info
usage(){
  echo " Run this script to join a new node to the cluster (control plane or worker)"
  echo ""
  echo "Usage:"
  echo "  $0 -h user_host@host_address"
  echo ""
  echo "Options:"
  echo "  -h argument : set a host name and ip to be configured and added to the cluster, repeat it multiple times to add multiple hosts"
  echo ""
  echo "  if no arguments are provided, then a list of nodes coming from 'main_config.yaml' will be added to the cluster"
  echo ""
  echo "  Example: if you want to add a control plane node, its user name must start with 'm' ==> m1@192.168.1.200"
  echo ""
  echo "  Example: if you want to add a worker node, its user name must start with 'w' ==> w1@192.168.1.201"
  exit
}

while getopts ":h:" opt; do
  case $opt in
    h) host_list+=("$OPTARG")
    ;;
    \?) usage
        exit
    ;;
  esac
done

###############################################################################
# export the cluster join command to be executed on worker host
token=$(kubeadm token generate)
certkeyout=$(sudo kubeadm init phase upload-certs --upload-certs)
#copy the contents of certkeyout variable into an array and now a[1] contains the certificate key
readarray -td ':' a <<<"$certkeyout";declare -p a > /dev/null
certkey=${a[1]}

export join_control_plane="sudo $(sudo kubeadm token create $token --print-join-command --certificate-key $certkey) --control-plane --cri-socket=unix:///var/run/cri-dockerd.sock"
export join_worker="sudo $(sudo kubeadm token create --print-join-command) --cri-socket=unix:///var/run/cri-dockerd.sock"
# create known_hosts file if not exists. needed to add remote worker nodes inside of it
touch ~/.ssh/known_hosts

# create config_file.sh to export colors into the worker hosts
touch ~/env_variables
cat << EOF | tee ~/env_variables > /dev/null
BLACK="\033[0;30m"
DARK_GREY="\033[1;30m"
RED="\033[0;31m"
LRED="\033[1;31m"
GREEN="\033[0;32m"
LGREEN="\033[1;32m"
ORANGE="\033[0;33m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
LBLUE="\033[1;34m"
PURPLE="\033[0;35m"
LPURPLE="\033[1;35m"
CYAN="\033[0;36m"
LCYAN="\033[1;36m"
LGRAY="\033[0;37m"
WHITE="\033[1;37m"
kubernetes_version=$kubernetes_version
master_host_ip=$master_host_ip
master_host_name=$master_host_name
application_dns_name=$application_dns_name
load_balancer_dns_name=$load_balancer_dns_name
app_server_addr=$app_server_addr
host_list=(${host_list[@]})
host_ip_index=$host_ip_index
EOF

echo -e "${LBLUE}Setting environment and installing dependencies to worker nodes which will join the cluster${WHITE}"
echo -e "${LBLUE}list of worker nodes: ${host_list[@]}${WHITE}"

for h in ${host_list[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[$host_ip_index]}

  host_vpn_ssh_string=$host_username@$host_ip

  echo -e "${LPURPLE}------------------------------------------------${WHITE}"
  echo -e "${LPURPLE}Working on: $host_username@$host_ip${WHITE}"

  echo -e "${LBLUE}Adding $host_ip to the list of known hosts...${WHITE}"
  ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
  wait

  # save host ip address
  ssh $host_vpn_ssh_string "sudo hostnamectl set-hostname $host_username" &
  wait

  # executing env_variables.sh on the remote host
  scp -q ~/env_variables $host_vpn_ssh_string:/home/$host_username/ &
  wait
  # ssh $host_vpn_ssh_string "chmod u+x /home/$host_username/env_variables" &
  # wait
  # ssh $host_vpn_ssh_string ". /home/$host_username/env_variables" &
  # wait
  ssh $host_vpn_ssh_string "cat ~/env_variables | sudo tee -a /etc/environment" &
  wait

  # add github to the list of known_hosts addresses
  echo -e "${LBLUE}Adding github.com to known_hosts addresses list...${WHITE}"
  ssh -q $host_vpn_ssh_string "ssh-keyscan github.com >> ~/.ssh/known_hosts" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # add master to the list of known_hosts addresses
  echo -e "${LBLUE}Adding master to known_hosts addresses list...${WHITE}"
  ssh -q $host_vpn_ssh_string "ssh-keyscan $master_host_ip >> ~/.ssh/known_hosts" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # clone github repository code
  echo -e "${LBLUE}Cloning code repository...${WHITE}"
  # ssh -A $h "git clone --single-branch --branch $github_branch_name git@github.com:rMiccolis/binanceB.git /home/$host_username/binanceB" &
  scp -q -r /home/$master_host_name/binanceB $host_vpn_ssh_string:/home/$host_username/
  # wait
  ssh $host_vpn_ssh_string "chmod -R u+x ./binanceB" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # Setting host settings and dependencies
  echo -e "${LBLUE}Setting host settings and dependencies...${WHITE}"
  ssh -t $host_vpn_ssh_string "/home/$host_username/binanceB/bin/set_host_settings.sh > /dev/null 2>&1" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # Installing Docker Engine
  echo -e "${LBLUE}Installing Docker Engine...${WHITE}"
  wait
  ssh -t $host_vpn_ssh_string "/home/$host_username/binanceB/bin/install_docker.sh > /dev/null 2>&1" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # Installing Cri-Docker (Container Runtime Interface)
  echo -e "${LBLUE}Installing Cri-Docker (Container Runtime Interface)${WHITE}"
  wait
  ssh -t $host_vpn_ssh_string "/home/$host_username/binanceB/bin/install_cri_docker.sh > /dev/null 2>&1" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  # Installing Kubernetes
  echo -e "${LBLUE}Installing Kubernetes${WHITE}"
  wait
  ssh -t $host_vpn_ssh_string "/home/$host_username/binanceB/bin/install_kubernetes.sh" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"


  ssh $host_vpn_ssh_string "sudo chown root:${host_username} /etc/default/" &
  wait
  ssh $host_vpn_ssh_string "sudo chmod -R 777 /etc/default/" &
  wait

  echo -e "${LBLUE}Joining $host_username@$host_ip to the cluster${WHITE}"
  if [ "${host_username:0:1}" == "m" ]; then
    echo "Joining control-plane node to the cluster"
    ssh -q $host_vpn_ssh_string "$join_control_plane" &
    wait
    ssh -q $host_vpn_ssh_string "mkdir -p /home/$host_username/.kube" &
    wait
    ssh -q $host_vpn_ssh_string "sudo cp -i /etc/kubernetes/admin.conf /home/$host_username/.kube/config" &
    wait
    ssh -q $host_vpn_ssh_string "sudo chown $(id -u):$(id -g) /home/$host_username/.kube/config" &
    wait
  else
    echo -e "${LBLUE}Joining worker node to the cluster${WHITE}"
    ssh -q $host_vpn_ssh_string "$join_worker" &
    wait
  fi

  echo -e "${LBLUE}Setting $host_ip as internal IP for $host_username${WHITE}"

  set_ip_kubelet_command="echo -n "KUBELET_EXTRA_ARGS="'--node-ip $host_ip'"" | cat >> /etc/default/kubelet"
  ssh $host_vpn_ssh_string "$set_ip_kubelet_command" &
  wait
  ssh $host_vpn_ssh_string "sudo systemctl daemon-reload" &
  wait
  ssh $host_vpn_ssh_string "sudo systemctl restart kubelet" &
  wait

  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  echo -e "${LPURPLE}HOST $host_username@$host_ip COMPLETED!${WHITE}"

done

sleep 5
echo -e "${LBLUE}All remote hosts configured and joined to the cluster!${WHITE}"
kubectl get nodes -o wide
echo -e "${LBLUE}------------------------------------------------${WHITE}"
kubectl wait --for=condition=Ready --all pods --all-namespaces --timeout=3000s &
wait
