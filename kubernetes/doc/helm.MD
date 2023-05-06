
uninstall nginx with helm:
    - helm uninstall ingress-nginx -n ingress-nginx

resolve problem with validatingwebhookconfiguration:
- I had the same problem and found a solution from another SO thread.
  I had previously installed nginx-ingress using the manifests. 
  I deleted the namespace it created, and the clusterrole and clusterrolebinding as noted in the documentation, 
  but that does not remove the ValidatingWebhookConfiguration that is installed in the manifests, 
  but NOT when using helm by default. As Arghya noted above, it can be enabled using a helm parameter.

Once I deleted the ValidatingWebhookConfiguration, my helm installation went flawlessly.

list validatingwebhooks: 
- run: kubectl get validatingwebhookconfiguration and then:
- run: kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission