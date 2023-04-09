install nginx with helm:
    - run: cd kubernetes/nginx/
    - run: helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    - run: helm repo update
    <!-- - helm pull nginx/nginx --untar -->
    <!-- - helm install -f ngingx_helm_values.yaml nginx-helm ingress-nginx/ingress-nginx -->
    - run: helm install --namespace ingress-nginx --create-namespace ingress-nginx ingress-nginx/ingress-nginx -f ./ngingx_helm_values.yaml

uninstall nginx with helm:
    - helm uninstall ingress-nginx -n ingress-nginx

resolve problem with validatingwebhookconfiguration:
      - I had the same problem and found a solution from another SO thread.
        I had previously installed nginx-ingress using the manifests. I deleted the namespace it created, and the clusterrole and clusterrolebinding as noted in the documentation, but that does not remove the ValidatingWebhookConfiguration that is installed in the manifests, but NOT when using helm by default. As Arghya noted above, it can be enabled using a helm parameter.

        Once I deleted the ValidatingWebhookConfiguration, my helm installation went flawlessly.

        list validatingwebhooks: 
        - run: kubectl get validatingwebhookconfiguration and then:
        - run: kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission