#!/bin/bash

#export ip address
export ip_addr=$(hostname -I | awk '{print $1}')

#add nginx helm repository (kubernetes version)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

cat <<EOF | sudof tee nginx_helm_config.yaml
controller:
  service:
    externalIPs: [$ip_addr]
  config:
    use-forwarded-headers: true
    use-gzip: true
    generate-request-id: true
    proxy-body-size: 1024k
    client-body-buffer-size: 1024k
    client-header-buffer-size: 1024k
    error-log-level: warn
    http2-max-header-size: 1024k
    log-format-escape-json: true
    log-format-upstream: '{"time": "", "remote_addr": "", "x_forwarded_for": "", "request_id": "","remote_user": "", "bytes_sent": , "request_time": , "status": , "vhost": "", "request_proto": "",   "path": "", "request_query": "", "request_length": , "duration": ,"method": "", "http_referrer": "","http_user_agent": "" }'
EOF

helm install --namespace ingress-nginx --create-namespace ingress-nginx ingress-nginx/ingress-nginx -f ./nginx_helm_config.yaml
