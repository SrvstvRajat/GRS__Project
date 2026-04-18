#!/bin/bash

set -e

echo "============================================"
echo " Starting Minikube with 3 nodes"
echo "============================================"

# Delete any existing cluster
minikube delete 2>/dev/null || true

# Start with 3 nodes
minikube start \
  --nodes=3 \
  --driver=docker \
  --cpus=4 \
  --memory=4096 \
  --cni=calico

echo ""
echo "Waiting for all nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo ""
echo "============================================"
echo " Cluster Nodes:"
echo "============================================"
kubectl get nodes -o wide

echo ""
echo "Labeling worker nodes for pod placement..."
kubectl label node minikube-m02 role=nginx   --overwrite
kubectl label node minikube-m03 role=stress  --overwrite
kubectl label node minikube      role=control --overwrite

echo ""
echo "Node layout:"
echo "  minikube      → control-plane + redis"
echo "  minikube-m02  → flask-redis app"
echo "  minikube-m03  → cpu-stress (noisy neighbor)"

echo ""
echo "Minikube started successfully."