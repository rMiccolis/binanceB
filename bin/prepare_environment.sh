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

# install yq library to read and parse json files
echo -e "${LBLUE}Installing yq library to read and parse YAML files...${WHITE}"
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq

echo -e "${LBLUE}Processing data from input JSON config file...${WHITE}"

# list of hosts IP that will join the cluster
hosts=($(yq '.hosts[]' $config_file_path))

export cluster_dns_name=$(yq '.cluster_dns_name' $config_file_path)
export docker_server_repository_name=$(yq '.docker_server_repository_name' $config_file_path)
export docker_client_repository_name=$(yq '.docker_client_repository_name' $config_file_path)
export github_branch_name=$(yq '.github_branch_name' $config_file_path)
export docker_username=$(yq '.docker_username' $config_file_path)
export docker_password=$(yq '.docker_password' $config_file_path)

echo -e "${LBLUE}Adding worker nodes to the hosts file...${WHITE}"
#exporting host list as a string (so it can be exported as variable and read by other scripts)
export host_list=$(yq '.hosts[]' $config_file_path)
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
done

echo -e "${LPURPLE}----------------${WHITE}"
echo -e "${LPURPLE}Cluster worker host list:${WHITE}"
for h in "${printable_hosts[@]}"; do
echo -e "${LPURPLE}$h${WHITE}"
done
echo -e "${LPURPLE}----------------${WHITE}"

echo -e "${LBLUE}Exporting repository root directory...${WHITE}"
export repository_root_dir=$(pwd)

echo -e "${LBLUE}Adding github to the list of known_hosts addresses${WHITE}"
ssh-keyscan github.com >> ~/.ssh/known_hosts
