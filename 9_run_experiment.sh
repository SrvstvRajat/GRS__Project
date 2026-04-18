#!/bin/bash

# ============================================
#  MASTER RUN SCRIPT
#  Full experiment flow — run this once
#  to set everything up in order.
# ============================================

set -e

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Tail Latency eBPF Experiment Setup    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── STEP 1: Start cluster ───────────────────
echo "STEP 1: Starting 3-node Minikube cluster..."
bash 9_start_minikube.sh
echo ""

# ─── STEP 2: Deploy microservices ────────────
echo "STEP 2: Deploying flask-redis app + redis..."
bash 9_deploy_all.sh
echo ""

# ─── STEP 3: Verify placement ────────────────
echo "STEP 3: Verifying pod-to-node placement..."
echo ""
echo "Expected layout:"
echo "  minikube      → redis (control-plane)"
echo "  minikube-m02  → flask-redis app"
echo "  minikube-m03  → cpu-stress (noisy neighbor, launched during experiment)"
echo ""
kubectl get pods -o wide
echo ""

# ─── STEP 4: Print bpftrace commands ─────────
echo "STEP 4: eBPF Probe Instructions"
echo "────────────────────────────────────────"
bash 9_ebpf_probes.sh
echo ""

echo "════════════════════════════════════════"
echo " ACTION REQUIRED:"
echo "════════════════════════════════════════"
echo ""
echo " 1. Open 5 terminals on this HOST machine"
echo " 2. Run one bpftrace probe per terminal"
echo "    (commands printed above)"
echo " 3. Once all probes are running, execute:"
echo ""
echo "      bash 9_wrk_load_stress_latency.sh"
echo ""
echo " 4. When wrk finishes, hit Ctrl+C on each"
echo "    probe terminal to get the histograms."
echo ""
echo "════════════════════════════════════════"
echo " Node Summary:"
kubectl get nodes -o wide
echo ""
echo " Pod Summary:"
kubectl get pods -o wide
echo "════════════════════════════════════════"