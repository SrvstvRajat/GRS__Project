#!/bin/bash

# ============================================
#  PHASE 2: Under CPU Stress
#  Launches cpu-stress pod on minikube-m03.
#  Measures tail latency under noisy neighbor.
# ============================================

source ./G_9_wrk_config.sh

echo "============================================"
echo " PHASE 2: Under CPU stress"
echo " Target: $SERVICE_URL"
echo "============================================"

# Verify service
check_service

# Launch stress pod
echo "Launching cpu-stress pod on minikube-m03..."
kubectl apply -f G_9_cpu_stress_pod.yaml

echo "Waiting for stress pod to be Ready..."
kubectl wait --for=condition=Ready pod/cpu-stress --timeout=60s
echo "Stress pod is running."
echo ""

# Init CSV
echo $CSV_HEADER > $CSV_STRESS
echo "Saving results to: $CSV_STRESS"
echo ""

# Run load test
for c in "${LOADS[@]}"; do
  run_wrk $c "stress" $CSV_STRESS
done

echo ""
echo "============================================"
echo " Phase 2 complete. Results:"
echo "============================================"
cat $CSV_STRESS

echo ""
echo "NOTE: cpu-stress pod is still running."
echo "Run G_9_phase3_recovery.sh to kill it and measure recovery."