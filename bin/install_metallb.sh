#!/bin/bash

echo -e "${LBLUE}Installing METAL LB${WHITE}"

kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait
echo -e "${LBLUE}METAL LB successfully installed with Helm!${WHITE}"

echo -e "${LBLUE}Applying configuration to METAL LB...${WHITE}"

cat << EOF | tee 'metallb_ipaddresspool.yaml' > /dev/null 2>&1
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.200/32
EOF

# cat << EOF | tee 'metallb_L2Advertisement.yaml' > /dev/null 2>&1
# apiVersion: metallb.io/v1beta1
# kind: L2Advertisement
# metadata:
#   name: example
#   namespace: metallb-system
# spec:
#   ipAddressPools:
#   - first-pool
# EOF

kubectl apply -f metallb_ipaddresspool.yaml
# kubectl apply -f metallb_L2Advertisement.yaml
