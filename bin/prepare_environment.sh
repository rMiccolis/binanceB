#!/bin/bash

# set host name and address
echo -e "${LBLUE}Getting Master host info...${WHITE}"
# eval ip_addr="$(hostname -I)"
# ip_addr=()
# ip_addr+=($(hostname -I))
# export master_host_ip=${ip_addr[1]}
master_host_vpn_ip=()
IFS='@' read -r -a master_host_vpn_ip <<< "$(yq '.master_host' $config_file_path)"
export master_host_ip_eth0=${master_host_vpn_ip[1]}
export master_host_ip=${master_host_vpn_ip[2]}
export master_host_name=$(whoami)
echo -e "${LBLUE}Setting Master host name ===> $master_host_name${WHITE}"
sudo hostnamectl set-hostname $master_host_name

echo -e "${LBLUE}Processing data from input JSON config file...${WHITE}"
# list of hosts IP that will join the cluster
export android_app_ready=$(yq '.android_app_ready' $config_file_path)
export app_run_on_vpn=$(yq '.app_run_on_vpn' $config_file_path)
export kubernetes_version=$(yq '.kubernetes_version' $config_file_path)
export application_dns_name=$(yq '.application_dns_name' $config_file_path)
export noip_username=$(yq '.noip_username' $config_file_path)
export noip_password=$(yq '.noip_password' $config_file_path)
export master_host_ip_eth0=$master_host_ip_eth0
export master_host_ip=$master_host_ip
export master_host_name=$master_host_name
export hosts=($(yq '.hosts[]' $config_file_path))
export environment=$(yq '.environment' $config_file_path)
export load_balancer_public_ip=$(yq '.load_balancer_public_ip' $config_file_path)
export load_balancer_dns_name=$(yq '.load_balancer_dns_name' $config_file_path)
export docker_server_repository_name=$(yq '.docker_server_repository_name' $config_file_path)
export docker_client_repository_name=$(yq '.docker_client_repository_name' $config_file_path)
export github_branch_name=$(yq '.github_branch_name' $config_file_path)
export docker_username=$(yq '.docker_username' $config_file_path)
export docker_server_repository_name=$(yq '.docker_server_repository_name' $config_file_path)
export docker_client_repository_name=$(yq '.docker_client_repository_name' $config_file_path)
export mongodb_replica_count=$(yq '.mongodb_replica_count' $config_file_path)
export docker_access_token=$(yq '.docker_access_token' $config_file_path)
export server_replica_count=$(yq '.server_replica_count' $config_file_path)
#exporting host list as a string (so it can be exported as variable and read by other scripts)
export host_list="$(yq '.hosts[]' $config_file_path)"

export app_server_addr=$load_balancer_dns_name

host_eth_ip_index=1
host_vpn_ip_index=2
export host_ip_index=1
if [ "$app_run_on_vpn" == "true" ]; then
    export host_ip_index=2
fi
export master_host_ip=${master_host_vpn_ip[$host_ip_index]}
if [ "$android_app_ready" == "true" ]; then
    export app_server_addr=$load_balancer_dns_name
fi

if [ "$app_run_on_vpn" == "true" ]; then
    export app_server_addr=$master_host_ip
fi

echo -e "${LBLUE}Master name and IP address found ===> $master_host_name - $master_host_ip${WHITE}"
echo -e "${LBLUE}USING ETH0 IP ADDRESS FOR APPLICATION${WHITE}"

echo -e "${LBLUE}Setting Master IP address into hosts file${WHITE}"
# save host ip address into host file
cat << EOF | sudo tee -a /etc/hosts > /dev/null
$master_host_ip $master_host_name $load_balancer_dns_name
EOF

# export variables at login
cat << EOF | tee -a /home/$USER/.profile > /dev/null
export noip_username=$noip_username
export noip_password=$noip_password
export kubernetes_version=$kubernetes_version
export host_ip_index=$host_ip_index
export app_server_addr=$app_server_addr
export application_dns_name=$application_dns_name
export master_host_ip_eth0=$master_host_ip_eth0
export master_host_ip=$master_host_ip
export master_host_name=$master_host_name
export hosts="${hosts[@]}"
export host_list="${hosts[@]}"
export environment=$environment
export load_balancer_public_ip=$load_balancer_public_ip
export load_balancer_dns_name=$load_balancer_dns_name
export docker_server_repository_name=$docker_server_repository_name
export docker_client_repository_name=$docker_client_repository_name
export github_branch_name=$github_branch_name
export docker_username=$docker_username
export docker_server_repository_name=$docker_server_repository_name
export docker_client_repository_name=$docker_client_repository_name
export mongodb_replica_count=$mongodb_replica_count
export server_replica_count=$server_replica_count
export docker_access_token=$docker_access_token
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
vpn_host_ip=${host_string[2]}
printable_hosts+=("$host_username - $host_ip - $vpn_host_ip")
if [ "${host_username:0:1}" == "m" ]; then
    control_plane_hosts_string+="$host_ip, $vpn_host_ip"
fi
# add host to hosts file
sudo tee -a /etc/hosts << EOF > /dev/null
$host_ip $host_username
EOF
done

export control_plane_hosts_string=$control_plane_hosts_string

echo -e "${LBLUE}externalIPs: [$control_plane_hosts_string]${WHITE}"

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
