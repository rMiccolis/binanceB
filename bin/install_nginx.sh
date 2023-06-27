#!/bin/bash

echo -e "${LBLUE}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null 2>&1
helm repo update > /dev/null 2>&1
externalIPs="$master_host_ip"

cat << EOF | tee nginx_helm_config.yaml > /dev/null 2>&1
controller:
  service:
    # externalIPs: [$master_host_ip $control_plane_hosts_string]
    externalTrafficPolicy: Local
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule
  tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 3
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
EOF

cat << 'EOF' | tee -a nginx_helm_config.yaml > /dev/null 2>&1
  config:
    use-forwarded-headers: true
    use-gzip: true
    error-log-level: warn
    log-format-escape-json: true
    enable-underscores-in-headers: true
    log-format-upstream: '{"time": "$time_iso8601", "proxy_protocol_addr": "$proxy_protocol_addr", "proxy_add_x_forwarded_for": "$proxy_add_x_forwarded_for", "remote_addr": "$remote_addr" }'
EOF

kubectl create namespace ingress-nginx
helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx -f nginx_helm_config.yaml > /dev/null 2>&1
# helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx

echo -e "${LBLUE}Nginx successfully installed with Helm!${WHITE}"