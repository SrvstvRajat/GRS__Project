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
Install these tools on Linux host:
```bash
- minikube
- kubectl
- docker
- wrk
- bpftrace
- sudo access (required for probes)
```
Quick check:

```bash
minikube version
kubectl version --client
docker --version
wrk --version
bpftrace --version
```

## 2. Give Execute Permission

Run once inside this folder:

```bash
chmod +x 9_start_minikube.sh \
        9_deploy_all.sh \
        9_run_experiment.sh \
        9_ebpf_probes.sh \
        9_wrk_run_all_phases.sh \
        9_phase1_baseline.sh \
        9_phase2_stress.sh \
        9_phase3_recovery.sh
```

## 3. Full Setup (Cluster + App)

Recommended single command:

```bash
bash 9_run_experiment.sh
```

What this does:

1. Starts a 3-node Minikube cluster.
2. Labels nodes for fixed pod placement.
3. Deploys Redis and Flask app service.
4. Prints eBPF probe commands.

## 4. Run eBPF Probes (5 Terminals)

Open 5 terminals and run one probe per terminal. You can print all commands with:

```bash
bash 9_ebpf_probes.sh
```

Or run each script directly in separate terminals:

```bash
bash 9_probe_run_queue.sh
```

```bash
bash 9_probe_tcp_send.sh
```

```bash
bash 9_probe_tcp_retransmit.sh
```

```bash
bash 9_probe_socket_drop.sh
```

```bash
bash 9_probe_reddis.sh
```

Keep probes running while workload runs. Use Ctrl+C to stop and print final histograms/counters.

## 5. Run Load Experiment

### Option A (recommended): all phases in one command

```bash
bash 9_wrk_run_all_phases.sh
```

This runs:

1. Baseline (no stress)
2. Stress (cpu-stress pod enabled)
3. Recovery (stress removed)

### Option B: run phases manually

```bash
bash 9_phase1_baseline.sh
bash 9_phase2_stress.sh
bash 9_phase3_recovery.sh
```

## 6. Results Output

Generated CSV files:

- [results/phase1_baseline.csv](results/phase1_baseline.csv)
- [results/combined_results.csv](results/combined_results.csv)
- Additional phase CSVs for stress and recovery are generated after full execution.

## 7. Plot Scripts

Run plot scripts after CSV data is available:

```bash
python3 9_wrk_load_plot_latency.py
python3 9_tcp_tail_latency_plot.py
python3 9_cpu_scheduling_plot.py
```

## 8. Quick Troubleshooting

Check pods and nodes:

```bash
kubectl get nodes -o wide
kubectl get pods -o wide
kubectl get svc
```

If app is not reachable:

```bash
curl -i "http://$(minikube ip):30080/health"
```

If needed, redeploy app stack:

```bash
bash 9_deploy_all.sh
```

## 9. Clean Restart

```bash
minikube delete
```
