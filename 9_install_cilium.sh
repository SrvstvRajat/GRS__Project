#!/bin/bash

echo "Installing Cilium..."

# Install Cilium CLI if not present
if ! command -v cilium &> /dev/null
then
    echo "Installing Cilium CLI..."
    curl -L --remote-name https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
    tar xzvf cilium-linux-amd64.tar.gz
    sudo mv cilium /usr/local/bin/
    rm cilium-linux-amd64.tar.gz
fi

echo "Installing Cilium in Kubernetes cluster..."
cilium install

echo "Enabling Hubble..."
cilium hubble enable --ui

echo "Waiting for Cilium status..."
cilium status --wait

echo "Cilium installation complete."
