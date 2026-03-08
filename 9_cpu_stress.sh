#!/bin/bash

echo "Running CPU stress experiment..."

kubectl run cpu-stress2 \
  --image=polinux/stress \
  --restart=Never \
  -- stress --cpu 4 --timeout 120

kubectl get pods