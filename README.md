# GRS Project

Project ID: 9

Title: Understanding Tail Latency in Kubernetes Microservices

Team Members:
- Harsha Verma (MT25024)
- Rajat Kumar Srivastava (MT25078)
- Anurag Sharma (MT25063)

This project investigates tail latency in Kubernetes microservices using eBPF instrumentation.

## Architecture
Client Load → Kubernetes Service → Cilium eBPF → Kernel TCP stack → bpftrace probes

## Setup

1. Start Minikube
2. Install Cilium
3. Deploy nginx
4. Generate load
5. Run latency probes

## Experiments
1. Baseline latency
2. CPU contention
3. High request concurrency

## Results
Tail latency increased from ~1 ms to ~64 ms under high load.
