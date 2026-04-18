#!/bin/bash


MINIKUBE_IP=$(minikube ip)
SERVICE_URL="http://$MINIKUBE_IP:30080"
# SERVICE_URL="http://$(minikube ip):30080"
OUTPUT_FILE="G_9_wrk_results.csv"
THREADS=4
DURATION=30s

echo "Target: $SERVICE_URL"
echo ""

# Verify app is reachable
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $SERVICE_URL)
if [ "$HTTP_STATUS" != "200" ]; then
  echo "ERROR: app not reachable at $SERVICE_URL (status: $HTTP_STATUS)"
  echo "Check: kubectl get pods -o wide"
  exit 1
fi

echo "timestamp,connections,phase,p50_ms,p75_ms,p90_ms,p9G_9_ms,rps,errors" > $OUTPUT_FILE

LOADS=(10 50 100 200 300)

run_wrk() {
  local CONNECTIONS=$1
  local PHASE=$2

  echo "  [connections=$CONNECTIONS] Running..."

  RESULT=$(wrk -t$THREADS -c$CONNECTIONS -d$DURATION --latency $SERVICE_URL 2>&1)

  parse_latency() {
    echo "$1" | awk '{
      val = $2
      if (val ~ /us/) { gsub(/us/, "", val); val = val / 1000 }
      else if (val ~ /s/ && val !~ /ms/) { gsub(/s/, "", val); val = val * 1000 }
      else { gsub(/ms/, "", val) }
      printf "%.2f", val
    }'
  }

  P50=$(parse_latency "$(echo "$RESULT" | grep "50%")")
  P75=$(parse_latency "$(echo "$RESULT" | grep "75%")")
  P90=$(parse_latency "$(echo "$RESULT" | grep "90%")")
  P99=$(parse_latency "$(echo "$RESULT" | grep "99%")")
  RPS=$(echo "$RESULT" | grep "Requests/sec" | awk '{printf "%.0f", $2}')
  ERRORS=$(echo "$RESULT" | grep "Non-2xx" | awk '{print $NF}' || echo "0")
  TS=$(date +%s)

  echo "$TS,$CONNECTIONS,$PHASE,$P50,$P75,$P90,$P99,$RPS,$ERRORS" >> $OUTPUT_FILE
  echo "    p50=${P50}ms  p75=${P75}ms  p90=${P90}ms  p99=${P99}ms  rps=$RPS"
}

# ─────────────────────────────
# PHASE 1: BASELINE
# ─────────────────────────────
echo "============================================"
echo " PHASE 1: Baseline (no cpu-stress)"
echo "============================================"

kubectl delete -f G_9_cpu_stress_pod.yaml 2>/dev/null || true
sleep 3

for c in "${LOADS[@]}"; do
  run_wrk $c "baseline"
done

# ─────────────────────────────
# PHASE 2: STRESS
# ─────────────────────────────
echo ""
echo "============================================"
echo " PHASE 2: Under CPU stress"
echo "============================================"

echo "Launching cpu-stress on minikube-m03..."
kubectl apply -f G_9_cpu_stress_pod.yaml

echo "Waiting for stress pod to be Ready..."
kubectl wait --for=condition=Ready pod/cpu-stress --timeout=60s

for c in "${LOADS[@]}"; do
  run_wrk $c "stress"
done

# ─────────────────────────────
# PHASE 3: RECOVERY
# ─────────────────────────────
echo ""
echo "============================================"
echo " PHASE 3: Recovery"
echo "============================================"

kubectl delete pod cpu-stress --grace-period=0 2>/dev/null || true
sleep 5

for c in "${LOADS[@]}"; do
  run_wrk $c "recovery"
done

echo ""
echo "============================================"
echo " Experiment complete. Results:"
echo "============================================"
cat $OUTPUT_FILE