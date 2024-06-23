#!/bin/bash

echo -e "${LBLUE}Installing NGINX to be reachble on $master_host_ip.${WHITE}"
#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null
helm repo update > /dev/null

# NGINX DOCUMENTATION:
# see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
# see https://kubernetes.github.io/ingress-nginx

# create a certificate for https protocol
KEY_FILE=nginx-key-cert
CERT_FILE=filecert
$HOST=$app_server_addr
cert_file_name='https-nginx-cert'
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}" -addext "subjectAltName = DNS:${HOST}"
kubectl create secret tls $cert_file_name --key ${KEY_FILE} --cert ${CERT_FILE}

# to set a tls certificate pass to helm: --set controller.extraArgs.default-ssl-certificate="__NAMESPACE__/_SECRET__"
# or set it into helm config file (like we do in next rows)

# externalIPs="$master_host_ip"
# externalIPs: [$master_host_ip $control_plane_hosts_string]

#tcp:
#  27017: "mongodb/mongodb:27017" => tcp_port_to_expose: namespace/service_name:service_port
cat << EOF | tee nginx_helm_config.yaml > /dev/null
tcp:
  27017: "mongodb/mongodb:27017"
controller:
  extraArgs:
    default-ssl-certificate: default/$cert_file_name
  service:
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
    minReplicas: 1
    maxReplicas: 3
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
EOF

cat << 'EOF' | tee -a nginx_helm_config.yaml > /dev/null
  config:
    use-forwarded-headers: true
    use-gzip: true
    error-log-level: warn
    log-format-escape-json: true
    enable-underscores-in-headers: true
    log-format-upstream: '{"time": "$time_iso8601", "proxy_add_x_forwarded_for": "$proxy_add_x_forwarded_for", "remote_addr": "$remote_addr" }'
EOF

kubectl create namespace ingress-nginx
helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx -f nginx_helm_config.yaml > /dev/null
# to expose port 27017 with nginx
# --set tcp.PORT="namespace/service_name:PORT"
# --set tcp.27017="mongodb/mongodb:27017"
echo -e "${LBLUE}Nginx successfully installed with Helm!${WHITE}"