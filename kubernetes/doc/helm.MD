install nginx with helm:
    - cd into kubernetes/nginx/ dir 
    - helm install -n nginx -f ngingx_helm_values.yaml nginx-helm ingress-nginx/ingress-nginx

uninstall nginx with helm:
    - helm uninstall -n nginx nginx-helm