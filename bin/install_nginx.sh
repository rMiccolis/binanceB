#!/bin/bash

echo -e "${LBLUE}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null 2>&1
helm repo update > /dev/null 2>&1
externalIPs="$master_host_ip"

cat << EOF | tee nginx_helm_config.yaml > /dev/null 2>&1
controller:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule
  service:
    externalIPs: [$master_host_ip]
  config:
    use-forwarded-headers: true
    use-gzip: true
    error-log-level: warn
    log-format-escape-json: true
    enable-underscores-in-headers: true
    log-format-upstream: '{"time": "$time_iso8601", "proxy_protocol_addr": "$proxy_protocol_addr", "proxy_add_x_forwarded_for": "$proxy_add_x_forwarded_for", "remote_addr": "$remote_addr", "x_forwarded_for": "$x_forwarded_for" }'
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