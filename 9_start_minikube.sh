#!/bin/bash

echo "Starting Minikube cluster..."

minikube start --driver=docker

echo "Checking cluster nodes..."

kubectl get nodes
