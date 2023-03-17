install nginx with helm:
    - cd into kubernetes/nginx/ dir
    - helm repo add ingress-nginx https://charts.bitnami.com/bitnami
    <!-- - helm install -f ngingx_helm_values.yaml nginx-helm ingress-nginx/ingress-nginx -->
    -  helm install --namespace nginx --create-namespace ingress-nginx ingress-nginx/nginx

uninstall nginx with helm:
    - helm uninstall nginx-helm