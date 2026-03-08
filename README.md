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
### Terminal 1 (Kubernetes Setup):
#### 1. Start Minikube
Run the script and make it executable:
```bash
chmod +x 9_start_minikube.sh
./9_start_minikube.sh
```
#### 2. Install Cilium
Run the script and make it executable:
```bash
chmod +x 9_install_cilium.sh
./9_install_cilium.sh
```
#### 3. Deploy nginx microservice
Run the script and make it executable:
```bash
chmod +x 9_deploy_nginx.sh
./9_deploy_nginx.sh
```

### Terminal 2 (Traffic Generator using curl pod)
#### 4. Generate traffic
Run a curl pod:
```bash
kubectl run curl --image=curlimages/curl -it --restart=Never -- sh
```
Inside the pod:
```bash
while true; do curl -s http://web > /dev/null; done
```

### Terminal 3 (Network Flow Monitoring using Hubble)
#### 5. Observe network flows
```bash
cilium hubble port-forward &
hubble observe
```

### Terminal 4 (Kernel TCP Latency Probe):
Terminal 1 can be reused here
#### 6. Run kernel latency probe
Run the script and make it executable:
```bash
chmod +x 9_baseline_bpftrace.sh
./9_baseline_bpftrace.sh
```
Let the probe run for 10–20 seconds while traffic is being generated, then stop it using `Ctrl+C` to print the latency histogram.

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

## Experimental Results
- Baseline: typical latency around tens of microseconds, tail around ~1 ms
- CPU stress: tail latency increased to approximately 2–4 ms
- Parallel load: rare outliers extended to tens of milliseconds

## Conclusion
Tail latency in Kubernetes microservices increases under contention and higher concurrency. Combining Hubble and bpftrace provides visibility into both dataplane flow behavior and kernel-level TCP latency.

## Repository Structure
```bash
GRS_project/
│
├── README.md
├── 9_nginx_deployment.yaml
├── 9_nginx_service.yaml
├── 9_start_minikube.sh
├── 9_install_cilium.sh
├── 9_deploy_nginx.sh
├── 9_baseline_bpftrace.sh
├── 9_cpu_stress.sh
└── 9_report.md
```
