#!/bin/bash

set -e

echo "============================================"
echo " Deploying all microservices"
echo "============================================"

# Deploy Redis FIRST — app depends on it
echo "[1/3] Deploying Redis (node: minikube control-plane)..."
kubectl apply -f 9_redis_deployment.yaml

echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=Ready pod -l app=redis --timeout=90s
echo "Redis is up."
echo ""

# Deploy Flask app
echo "[2/3] Deploying Flask-Redis app (node: minikube-m02)..."
kubectl apply -f 9_nginx_microservice_deployment.yaml
kubectl apply -f 9_nginx_service.yaml

echo "Waiting for app pod to be ready (includes pip install, takes ~60s)..."
kubectl wait --for=condition=Ready pod -l app=nginx --timeout=120s
echo "App is up."
echo ""

# Verify placement
echo "[3/3] Pod placement:"
kubectl get pods -o wide
echo ""
kubectl get svc
echo ""

# Smoke tests
MINIKUBE_IP=$(minikube ip)
SERVICE_URL="http://$MINIKUBE_IP:30080"

echo "Smoke test /health ..."
curl -sf $SERVICE_URL/health
echo ""

echo "Smoke test / (Redis call)..."
curl -sf $SERVICE_URL/
echo ""

echo ""
echo "============================================"
echo " All services deployed."
echo " App URL: $SERVICE_URL"
echo "============================================"