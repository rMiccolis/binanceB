#!/bin/bash

#export ip address
# export ip_addr=$(hostname -I | awk '{print $1}')
echo -e "${LCYAN}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
sudo apt-get upgrade -y
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
externalIPs="$master_host_ip"
for h in "${host_list[@]}"; do
IFS='@' read -r -a host_string <<< "$h"
host_username=${host_string[0]}
host_ip=${host_string[1]}
externalIPs=$externalIPs,$host_ip
done
cat << EOF | tee nginx_helm_config.yaml
controller:
  service:
    loadBalancerIP: [$master_host_ip]
  config:
    use-forwarded-headers: true
    use-gzip: true
    generate-request-id: true
    proxy-body-size: 1024k
    client-body-buffer-size: 1024k
    client-header-buffer-size: 1024k
    error-log-level: warn
    http2-max-header-size: 1024k
EOF

kubectl create namespace ingress-nginx
helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx -f nginx_helm_config.yaml --version '4.5.2'
# helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx
kubectl wait --for=condition=ContainersReady --all pods -n ingress-nginx --timeout=1200s &
wait
echo -e "${LBLUE}Nginx successfully installed with Helm!${WHITE}"