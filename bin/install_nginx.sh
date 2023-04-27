#!/bin/bash

#export ip address
# export ip_addr=$(hostname -I | awk '{print $1}')
echo -e "${LCYAN}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

cat <<EOF | sudo tee nginx_helm_config.yaml
controller:
  service:
    externalIPs: [$master_host_ip]
EOF

helm install --namespace ingress-nginx --create-namespace ingress-nginx ingress-nginx/ingress-nginx -f nginx_helm_config.yaml
kubectl wait --for=condition=ContainersReady --all pods -n ingress-nginx &
wait
echo -e "${LBLUE}Nginx successfully installed with Helm!${WHITE}"
