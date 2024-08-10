#!/bin/bash

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.9.1/cert-manager.yaml

# let's wait for mongodb deployment / stateful set to be ready
kubectl wait --for=condition=Ready --all pods --all-namespaces --timeout=5000s &
wait

mkdir $HOME/cert-manager
cat << EOF | tee $HOME/cert-manager/clusterissuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer # I'm using ClusterIssuer here
metadata:
  name: letsencrypt-certificate
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: test@hotmail.it
    privateKeySecretRef:
      name: letsencrypt-certificate
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f $HOME/cert-manager/clusterissuer.yaml

