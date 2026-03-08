# GRS Project

Project ID: 9

Title: Understanding Tail Latency in Kubernetes Microservices

Team Members:
- Harsha Verma (MT25024)
- Rajat Kumar Srivastava (MT25078)
- Anurag Sharma (MT25063)

## Project Overview
This project studies tail latency in Kubernetes microservices using eBPF-based observability. A simple nginx microservice is deployed on a Minikube cluster. Traffic is generated from a curl pod, network-level flow visibility is obtained through Cilium + Hubble, and kernel-level TCP latency is measured using bpftrace probes attached to `tcp_sendmsg`.

## Motivation
Kubernetes provides convenient deployment and service abstraction, but it does not directly explain why tail latency increases. To understand latency spikes, we need visibility into both:
- Kubernetes/Cilium network flows
- Linux kernel TCP stack behavior

## System Architecture
Load Generator (curl pod)  
→ Kubernetes Service (`web`)  
→ Cilium eBPF dataplane  
→ Linux kernel TCP stack  
→ bpftrace latency probe (`tcp_sendmsg`)  
→ Hubble flow monitoring

## Components Used
- Minikube
- kubectl
- Docker
- Cilium
- Hubble
- bpftrace
- nginx
- curlimages/curl
- polinux/stress

## Setup Steps
### 1. Start Minikube
```bash
minikube start --driver=docker
kubectl get nodes
```
### 2. Install Clium
```bash
cilium install
cilium hubble enable --ui
cilium status --wait
```
### 3. Deploy nginx microservice
```bash
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml
kubectl get pods
kubectl get svc
```

### 4. Generate traffic
Run a curl pod:
```bash
kubectl run curl --image=curlimages/curl -it --restart=Never -- sh
```
Inside the pod:
```bash
while true; do curl -s http://web > /dev/null; done
```

### 5. Observe network flows
```bash
cilium hubble port-forward &
hubble observe
```

### 6. Run kernel latency probe
```bash
sudo bpftrace -e 'kprobe:tcp_sendmsg { @start[tid] = nsecs; } kretprobe:tcp_sendmsg /@start[tid]/ { @lat = hist((nsecs - @start[tid]) / 1000); delete(@start[tid]); }'
```

## Experiments
### Experiment 1: Baseline
Continuous curl traffic to nginx service.

### Experiment 2: CPU Contention
```bash
kubectl run cpu-stress2 --image=polinux/stress --restart=Never -- stress --cpu 4 --timeout 120
```

### Experiment 3: Parallel Load
Inside curl pod:
```bash
while true; do
  curl -s http://web > /dev/null &
  curl -s http://web > /dev/null &
  curl -s http://web > /dev/null &
  curl -s http://web > /dev/null &
  wait
done
```

## Observations
- Hubble successfully showed packet flows between curl and web
- bpftrace successfully measured TCP send latency at kernel level
- CPU stress increased tail latency modestly
- Parallel request load caused much stronger tail-latency spikes

## Approximate Results
- Baseline: typical latency around tens of microseconds, tail around ~1 ms
- CPU stress: tail extended to ~2–4 ms
- Parallel load: rare outliers extended to tens of milliseconds

## Conclusion
Tail latency in Kubernetes microservices increases under contention and higher concurrency. Combining Hubble and bpftrace provides visibility into both dataplane flow behavior and kernel-level TCP latency.

## Repository Structure
GRS_project/
│
├── README.md
├── 9_nginx_deployment.yaml
└── 9_nginx_service.yaml
├── 9_start_minikube.sh
├── 9_install_cilium.sh
├── 9_deploy_nginx.sh
├── 9_baseline_bpftrace.sh
└── 9_cpu_stress.sh
└── 9_report.md
