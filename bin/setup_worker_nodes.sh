#!/bin/bash

join=$(kubeadm token create --print-join-command)
touch ~/.ssh/known_hosts
touch ~/config_file.sh
cat << EOF | sudo tee ~/config_file.sh
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
export docker_username=$docker_username
export docker_password=$docker_password
export join_command="$join"
EOF

for h in ${host_list[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[1]}
  echo -e "${LCYAN}LOOPING ON $host_username@$host_ip"
  ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
  wait

  scp ~/config_file.sh $h:/home/$host_username/ &
  wait

  ssh -A $h "chmod u+x /home/$host_username/config_file.sh" &
  wait

  ssh -A $h "/home/$host_username/config_file.sh" &
  wait

  # add github to the list of known_hosts addresses
  ssh -A $h "ssh-keyscan github.com >> ~/.ssh/known_hosts" &
  wait
  # clone github repository code 
  echo -e "${LCYAN}Cloning repository"
  ssh -A $h "git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git /home/$host_username/binanceB" &
  wait

  echo -e "${LCYAN}set_host_settings.sh"
  ssh -A $h "chmod u+x /home/$host_username/binanceB/bin/set_host_settings.sh" &
  wait
  ssh -A $h "/home/$host_username/binanceB/bin/set_host_settings.sh" &
  wait

  echo -e "${LCYAN}install_docker.sh"
  ssh -A $h "chmod u+x /home/$host_username/binanceB/bin/install_docker.sh" &
  wait
  ssh -A $h "/home/$host_username/binanceB/bin/install_docker.sh --username $docker_username --password $docker_password" &
  wait

  echo -e "${LCYAN}install_cri_docker.sh"
  ssh -A $h "chmod u+x /home/$host_username/binanceB/bin/install_cri_docker.sh" &
  wait
  ssh -A $h "/home/$host_username/binanceB/bin/install_cri_docker.sh" &
  wait

  echo -e "${LCYAN}install_kubernetes.sh" &
  ssh -A $h "chmod u+x /home/$host_username/binanceB/bin/install_kubernetes.sh" &
  wait
  ssh -A $h "/home/$host_username/binanceB/bin/install_kubernetes.sh" &
  wait

  echo -e "${LCYAN}Joining cluster.sh" &
  ssh -A $h "sudo $join"
  wait
done