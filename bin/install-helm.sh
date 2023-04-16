#!/bin/bash

###############################################################################
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudof chmod 700 get_helm.sh
sudof ./get_helm.sh