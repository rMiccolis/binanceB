#!/bin/bash

echo -e "${LBLUE}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null 2>&1
helm repo update > /dev/null 2>&1
externalIPs="$master_host_ip"

cat << EOF | tee nginx_helm_config.yaml > /dev/null 2>&1
controller:
  service:
    externalIPs: [$master_host_ip]
  config:
    use-forwarded-headers: true
    use-gzip: true
    generate-request-id: true
    proxy-body-size: 1024k
    client-body-buffer-size: 1024k
    client-header-buffer-size: 1024k
    error-log-level: warn
    http2-max-header-size: 1024k
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 3
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
EOF

kubectl create namespace ingress-nginx
helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx -f nginx_helm_config.yaml > /dev/null 2>&1
# helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx

echo -e "${LBLUE}Nginx successfully installed with Helm!${WHITE}"