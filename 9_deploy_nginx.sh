#!/bin/bash

echo "Deploying nginx microservice..."

kubectl apply -f 9_nginx_deployment.yaml
kubectl apply -f 9_nginx_service.yaml

echo "Waiting for pods to start..."

kubectl get pods
kubectl get svc

echo "Nginx deployment completed."
