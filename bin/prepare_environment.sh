#!/bin/bash

# set host name and address
echo -e "${LBLUE}Getting Master host info...${WHITE}"
eval ip_addr="$(hostname -I)"
export master_host_ip=$ip_addr
export master_host_name=$(whoami)
echo -e "${LBLUE}Master name and IP address found ===> $master_host_name - $master_host_ip${WHITE}"
echo -e "${LBLUE}Setting Master host name ===> $master_host_name${WHITE}"
sudo hostnamectl set-hostname $master_host_name


echo -e "${LBLUE}Setting Master IP address into hosts file${WHITE}"
# save host ip address into host file
cat << EOF | sudo tee -a /etc/hosts > /dev/null
$master_host_ip $master_host_name
EOF

echo -e "${LBLUE}Installing jq library to read and parse json files...${WHITE}"
# install jq library to read and parse json files
sudo apt-get install -y -q jq > /dev/null

# list of hosts IP that will join the cluster
hosts=()

echo -e "${LBLUE}Processing data from input JSON config file...${WHITE}"
# read hosts array from configuration file
hosts="$(jq -r '.hosts | @sh' $config_file_path)"
cluster_dns_name="$(jq -r '.cluster_dns_name | @sh' $config_file_path)"


echo -e "${LLBLUE}Collecting workers' names and IPs...${WHITE}"
#split hosts string into and array
hosts=($hosts)
# cleaning strings from single quotes elements read by json file through jq library
# (from 'w1@ip' to w1@ip)
for h in "${!hosts[@]}"; do
  temp_host=${hosts[$h]}
  eval hosts[$h]=$temp_host
done


echo -e "${LBLUE}Adding worker nodes to the hosts file...${WHITE}"
host_list=""
printable_hosts=()
for h in "${hosts[@]}"; do
# adding remote hosts to the hosts file
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
printable_hosts+=("$host_username - $host_ip")
# add host to hosts file
sudo tee -a /etc/hosts << EOF > /dev/null
$host_ip $host_username
EOF
#adding remote host to the remote host list string (so it can be exported as variable and read by other scripts)
host_list="$host_list $h"
done

echo -e "${LPURPLE}----------------${WHITE}"
echo -e "${LPURPLE}Cluster worker host list:${WHITE}"
for h in "${printable_hosts[@]}"; do
echo -e "${LPURPLE}$h${WHITE}"
done
echo -e "${LPURPLE}----------------${WHITE}"

export host_list=$host_list

echo -e "${LBLUE}Exporting repository root directory...${WHITE}"
export repository_root_dir=$(pwd)

echo -e "${LBLUE}Adding github to the list of known_hosts addresses${WHITE}"
ssh-keyscan github.com >> ~/.ssh/known_hosts
