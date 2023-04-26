#!/bin/bash

kubectl apply -f ./kubernetes/app/1-namespaces/
kubectl apply -f ./kubernetes/app/2-mongodb/
kubectl apply -f ./kubernetes/app/3-server/
kubectl apply -f ./kubernetes/app/4-client/
