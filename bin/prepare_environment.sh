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
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -q -O /usr/bin/yq && sudo chmod +x /usr/bin/yq > /dev/null

echo -e "${LBLUE}Processing data from input JSON config file...${WHITE}"

# list of hosts IP that will join the cluster
export master_host_ip=$master_host_ip
export master_host_name=$master_host_name
export hosts=($(yq '.hosts[]' $config_file_path))
export environment=$(yq '.environment' $config_file_path)
export cluster_public_ip=$(yq '.cluster_public_ip' $config_file_path)
export cluster_dns_name=$(yq '.cluster_dns_name' $config_file_path)
export docker_server_repository_name=$(yq '.docker_server_repository_name' $config_file_path)
export docker_client_repository_name=$(yq '.docker_client_repository_name' $config_file_path)
export github_branch_name=$(yq '.github_branch_name' $config_file_path)
export docker_username=$(yq '.docker_username' $config_file_path)
export docker_server_repository_name=$(yq '.docker_server_repository_name' $config_file_path)
export docker_client_repository_name=$(yq '.docker_client_repository_name' $config_file_path)
export skip_docker_build=$(yq '.skip_docker_build' $config_file_path)
export mongodb_replica_count=$(yq '.mongodb_replica_count' $config_file_path)
export docker_password=$(yq '.docker_password' $config_file_path)
#exporting host list as a string (so it can be exported as variable and read by other scripts)
export host_list=$(yq '.hosts[]' $config_file_path)


# export variables at login
cat << EOF | tee -a /home/$USER/.profile > /dev/null
export master_host_ip=$master_host_ip
export master_host_name=$master_host_name
export hosts=${hosts[@]}
export host_list=$host_list
export environment=$environment
export cluster_public_ip=$cluster_public_ip
export cluster_dns_name=$cluster_dns_name
export docker_server_repository_name=$docker_server_repository_name
export docker_client_repository_name=$docker_client_repository_name
export github_branch_name=$github_branch_name
export docker_username=$docker_username
export docker_server_repository_name=$docker_server_repository_name
export docker_client_repository_name=$docker_client_repository_name
export skip_docker_build=$skip_docker_build
export mongodb_replica_count=$mongodb_replica_count
export docker_password=$docker_password
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
EOF


echo -e "${LBLUE}Adding worker nodes to the hosts file...${WHITE}"
printable_hosts=()
control_plane_hosts_string=""
for h in "${hosts[@]}"; do
# adding remote hosts to the hosts file
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
printable_hosts+=("$host_username - $host_ip")
if [ "${host_username:0:1}" == "m" ]; then
    control_plane_hosts_string+=", $host_ip"
fi
# add host to hosts file
sudo tee -a /etc/hosts << EOF > /dev/null
$host_ip $host_username
EOF
done

export control_plane_hosts_string=$control_plane_hosts_string

echo -e "${LBLUE}externalIPs: [$master_host_ip $control_plane_hosts_string]${WHITE}"

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
