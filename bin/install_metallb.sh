#!/bin/bash

echo -e "${LBLUE}Installing METAL LB${WHITE}"

kubectl wait --for=condition=ContainersReady --all pods --all-namespaces --timeout=1800s &
wait

# If you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode.
# Note, you don’t need this if you’re using kube-router as service-proxy because it is enabling strict ARP by default.
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

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
  - ${master_host_ip}/32
EOF

temp_host_list=(${hosts[@]})
addresses=(${hosts[@]})
for h in "${addresses[@]}"; do
# adding remote hosts to the hosts file
host_string=()
IFS='@' read -r -a host_string <<< "$h"
host_ip=${host_string[$host_ip_index]}
cat << EOF | tee -a 'metallb_ipaddresspool.yaml' > /dev/null 2>&1
  - ${host_ip}/32
EOF
done

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
