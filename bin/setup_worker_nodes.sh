#!/bin/bash

###############################################################################
# export the cluster join command to be executed on worker host
token=$(kubeadm token generate)
certkeyout=$(sudo kubeadm init phase upload-certs --upload-certs)
#copy the contents of certkeyout variable into an array and now a[1] contains the certificate key
readarray -td ':' a <<<"$certkeyout";declare -p a
certkey=${a[1]}

export join_control_plane="sudo $(sudo kubeadm token create $token --print-join-command --certificate-key $certkey) --control-plane --cri-socket=unix:///var/run/cri-dockerd.sock"
export join_worker="sudo $(sudo kubeadm token create $token --print-join-command) --cri-socket=unix:///var/run/cri-dockerd.sock"
# create known_hosts file if not exists. needed to add remote worker nodes inside of it
touch ~/.ssh/known_hosts

# create config_file.sh to export colors into the worker hosts
touch ~/config_file.sh
cat << EOF | tee ~/config_file.sh > /dev/null
#!/bin/bash
#export colors for colored output strings
export BLACK="\033[0;30m"
export DARK_GREY="\033[1;30m"
export RED="\033[0;31m"
export LRED="\033[1;31m"
export GREEN="\033[0;32m"
export LGREEN="\033[1;32m"
export ORANGE="\033[0;33m"
export YELLOW="\033[1;33m"
export BLUE="\033[0;34m"
export LBLUE="\033[1;34m"
export PURPLE="\033[0;35m"
export LPURPLE="\033[1;35m"
export CYAN="\033[0;36m"
export LCYAN="\033[1;36m"
export LGRAY="\033[0;37m"
export WHITE="\033[1;37m"
export master_host_ip=$master_host_ip
export master_host_name=$master_host_name
export host_list=(${host_list[@]})
EOF

echo -e "${LBLUE}Setting environment and installing dependencies to worker nodes which will join the cluster${WHITE}"
echo -e "${LBLUE}list of worker nodes: ${host_list[@]}${WHITE}"

for h in ${host_list[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[1]}
  echo -e "${LPURPLE}------------------------------------------------${WHITE}"
  echo -e "${LPURPLE}Working on: $host_username@$host_ip${WHITE}"

  echo -e "${LBLUE}Adding $host_ip to the list of known hosts...${WHITE}"
  ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
  wait

  # save host ip address
  ssh $h "sudo hostnamectl set-hostname $host_username" &
  wait

  # executing config_file.sh on the remote host
  scp -q ~/config_file.sh $h:/home/$host_username/ &
  wait
  ssh $h "chmod u+x /home/$host_username/config_file.sh" &
  wait
  ssh $h ". /home/$host_username/config_file.sh" &
  wait

  # add github to the list of known_hosts addresses
  echo -e "${LBLUE}Adding github.com to known_hosts addresses list...${WHITE}"
  ssh -q $h "ssh-keyscan github.com >> ~/.ssh/known_hosts" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # add master to the list of known_hosts addresses
  echo -e "${LBLUE}Adding master to known_hosts addresses list...${WHITE}"
  ssh -q $h "ssh-keyscan $master_host_ip >> ~/.ssh/known_hosts" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # clone github repository code 
  echo -e "${LBLUE}Cloning code repository...${WHITE}"
  # ssh -A $h "git clone --single-branch --branch $github_branch_name git@github.com:rMiccolis/binanceB.git /home/$host_username/binanceB" &
  scp -q -r /home/$master_host_name/binanceB $h:/home/$host_username/
  # wait
  ssh $h "chmod -R u+x ./binanceB" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # Setting host settings and dependencies
  echo -e "${LBLUE}Setting host settings and dependencies...${WHITE}"
  ssh -t $h "/home/$host_username/binanceB/bin/set_host_settings.sh" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # Installing Docker Engine
  echo -e "${LBLUE}Installing Docker Engine...${WHITE}"
  wait
  ssh -t $h "/home/$host_username/binanceB/bin/install_docker.sh" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # Installing Cri-Docker (Container Runtime Interface)
  echo -e "${LBLUE}Installing Cri-Docker (Container Runtime Interface)${WHITE}"
  wait
  ssh -t $h "/home/$host_username/binanceB/bin/install_cri_docker.sh" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  # Installing Kubernetes
  echo -e "${LBLUE}Installing Kubernetes${WHITE}"
  wait
  ssh -t $h "/home/$host_username/binanceB/bin/install_kubernetes.sh" &
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  
  
  echo -e "${LBLUE}Joining $host_username@$host_ip to the cluster${WHITE}"
  if [ "${host_username:0:1}" == "m" ]; then
    echo "Joining control-plane node to the cluster"
    ssh -q $h "$join_control_plane" &
    wait
    ssh -q $h "mkdir -p /home/$host_username/.kube" &
    wait
    ssh -q $h "sudo cp -i /etc/kubernetes/admin.conf /home/$host_username/.kube/config" &
    wait
    ssh -q $h "sudo chown $(id -u):$(id -g) /home/$host_username/.kube/config" &
    wait
  else
    echo "Joining worker node to the cluster"
    ssh -q $h "$join_worker" &
  fi
  wait
  echo -e "${LBLUE}Operation Done!${WHITE}"

  echo -e "${LPURPLE}HOST $host_username@$host_ip COMPLETED!${WHITE}"

done

echo -e "${LBLUE}All remote hosts configured and joined to the cluster!${WHITE}"
kubectl get nodes -o wide
echo -e "${LBLUE}------------------------------------------------${WHITE}"
