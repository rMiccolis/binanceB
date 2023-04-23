#!/bin/bash

join=$(kubeadm token create --print-join-command)
touch ~/.ssh/known_hosts
for h in ${host_list[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[1]}
  echo -e "${LCYAN}LOOPING ON $host_username@$host_ip"
  ssh-keyscan $host_ip >> ~/.ssh/known_hosts &
  wait
  scp /home/binanceB/bin/infrastructure_setup.sh $h:/home/$host_username/ &
  wait
  # add github to the list of known_hosts addresses
  ssh -A $h "ssh-keyscan github.com >> ~/.ssh/known_hosts" &
  wait
  # clone github repository code 
  echo -e "${LCYAN}Cloning repository"
  ssh -A $h "git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git" &
  wait

  echo -e "${LCYAN}set_host_settings.sh"
  ssh -A $h "/home/binanceB/bin/set_host_settings.sh" &
  wait

  echo -e "${LCYAN}install_docker.sh"
  ssh -A $h "/home/binanceB/bin/install_docker.sh" &
  wait

  echo -e "${LCYAN}install_cri_docker.sh"
  ssh -A $h "/home/binanceB/bin/install_cri_docker.sh" &
  wait

  echo -e "${LCYAN}install_kubernetes.sh" &
  ssh -A $h "/home/binanceB/bin/install_kubernetes.sh" &
  wait

  echo -e "${LCYAN}Joining cluster.sh" &
  wait
  ssh -A $h "$join"
  wait
done