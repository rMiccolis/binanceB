#!/bin/bash

###############################################################################

# usage info
usage(){
  echo " Run this script to install a DNS server"
  echo " This script is used to create a DNS server to be used from the VPN peers to translate the 'application_dns_name' into the master VPN IP address"
  echo " Usage:"
  echo "  $0 -c /path/to/main_config.yaml"
  echo " For info about this installation, refer to: https://ubuntu.com/server/docs/service-domain-name-service-dns" in the "Primary server" section.
  echo ""
  exit
}

while getopts ":c:" opt; do
  case $opt in
    c) config_file_path="$OPTARG"
    ;;
    \?) usage
        exit
    ;;
  esac
done

application_dns_name=$(yq '.application_dns_name' $config_file_path)
master_host=$(yq '.master_host' $config_file_path)

host_string=()
IFS='@' read -r -a host_string <<< "$master_host"
master_username=${host_string[0]}
master_ip=${host_string[1]}
master_ip_vpn=${host_string[2]}

IFS='.' read -r -a interface_range <<< "$master_ip_vpn"
interface_1=${interface_range[0]}
interface_2=${interface_range[1]}
interface_3=${interface_range[2]}

sudo apt-get install -y bind9 > /dev/null 2>&1

sudo apt-get install dnsutils > /dev/null 2>&1

cat << EOF | sudo tee /etc/bind/named.conf.local > /dev/null 2>&1
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "$application_dns_name" {
     type master;
     file "/etc/bind/db.$application_dns_name";
};


EOF

cat << EOF | sudo tee /etc/bind/db.$application_dns_name > /dev/null
;
; BIND data file for $application_dns_name
;
EOF

cat << 'EOF' | sudo tee -a /etc/bind/db.$application_dns_name > /dev/null
$TTL    604800
EOF

cat << EOF | sudo tee -a /etc/bind/db.$application_dns_name > /dev/null
@       IN      SOA     $application_dns_name. root.$application_dns_name. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.$application_dns_name.
@       IN      A       $master_ip_vpn
@       IN      AAAA    ::1
ns      IN      A       $master_ip_vpn
EOF

sudo systemctl restart bind9.service > /dev/null 2>&1

cat << EOF | sudo tee -a /etc/bind/named.conf.local > /dev/null
zone "$interface_1.$interface_2.$interface_3.in-addr.arpa" {
     type master;
     file "/etc/bind/db.$interface_1";
};
EOF

cat << EOF | sudo tee /etc/bind/db.$interface_1 > /dev/null
;
; BIND reverse data file for local $interface_1.$interface_2.$interface_3.XXX net
;
EOF

cat << 'EOF' | sudo tee -a /etc/bind/db.$interface_1 > /dev/null
$TTL    604800
EOF

cat << EOF | sudo tee -a /etc/bind/db.$interface_1 > /dev/null
@       IN      SOA     ns.$application_dns_name. root.$application_dns_name. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
10      IN      PTR     ns.$application_dns_name.
EOF

sudo systemctl restart bind9.service > /dev/null 2>&1
