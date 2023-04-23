#!/bin/bash

join=$(kubeadm token create --print-join-command)
touch ~/.ssh/known_hosts
for h in ${hosts[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[1]}
  ssh-keyscan $host_ip >> ~/.ssh/known_hosts
  scp /home/binanceB/bin/infrastructure_setup.sh $h:/home/$host_username/
  # add github to the list of known_hosts addresses
  ssh -A $h "ssh-keyscan github.com >> ~/.ssh/known_hosts"
  # clone github repository code 
  ssh -A $h "git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git"
  ssh -A $h "cd binanceB"
  ssh -A $h "./bin/set_host_settings.sh"
  ssh -A $h "./bin/install_docker.sh"
  ssh -A $h "./bin/install_cri_docker.sh"
  ssh -A $h "./bin/install_kubernetes.sh"
  ssh -A $h "$join"
done