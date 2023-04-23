#!/bin/bash

join=$(kubeadm token create --print-join-command)
for h in ${hosts[@]}; do
  host_string=()
  IFS='@' read -r -a host_string <<< "$h"
  host_username=${host_string[0]}
  host_ip=${host_string[1]}
  scp /home/binanceB/bin/infrastructure_setup.sh $h:/home/$host_username/
  ssh -A $h
  chmod u+x ./infrastructure_setup.sh
done