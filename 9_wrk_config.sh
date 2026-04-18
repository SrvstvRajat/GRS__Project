#!/bin/bash

# ============================================
#  Shared config — sourced by all phase scripts
# ============================================

SERVICE_URL="http://$(minikube ip):30080"
THREADS=4
DURATION=30s
LOADS=(10 50 100 200 300)

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

CSV_BASELINE="$RESULTS_DIR/phase1_baseline.csv"
CSV_STRESS="$RESULTS_DIR/phase2_stress.csv"
CSV_RECOVERY="$RESULTS_DIR/phase3_recovery.csv"
CSV_COMBINED="$RESULTS_DIR/combined_results.csv"

CSV_HEADER="timestamp,connections,phase,p50_ms,p75_ms,p90_ms,p99_ms,rps,errors"

# ── Latency parser ────────────────────────────
parse_latency() {
  echo "$1" | awk '{
    val = $2
    if (val ~ /us/) { gsub(/us/, "", val); val = val / 1000 }
    else if (val ~ /s/ && val !~ /ms/) { gsub(/s/, "", val); val = val * 1000 }
    else { gsub(/ms/, "", val) }
    printf "%.2f", val
  }'
}

# ── Single wrk run ────────────────────────────
run_wrk() {
  local CONNECTIONS=$1
  local PHASE=$2
  local OUTPUT_CSV=$3

  echo "  [connections=$CONNECTIONS] Running..."

  RESULT=$(wrk -t$THREADS -c$CONNECTIONS -d$DURATION --latency $SERVICE_URL 2>&1)

  P50=$(parse_latency "$(echo "$RESULT" | grep "50%")")
  P75=$(parse_latency "$(echo "$RESULT" | grep "75%")")
  P90=$(parse_latency "$(echo "$RESULT" | grep "90%")")
  P99=$(parse_latency "$(echo "$RESULT" | grep "99%")")
  RPS=$(echo "$RESULT" | grep "Requests/sec" | awk '{printf "%.0f", $2}')
  ERRORS=$(echo "$RESULT" | grep "Non-2xx" | awk '{print $NF}' || echo "0")
  TS=$(date +%s)

  ROW="$TS,$CONNECTIONS,$PHASE,$P50,$P75,$P90,$P99,$RPS,$ERRORS"

  # Write to phase CSV
  echo "$ROW" >> $OUTPUT_CSV

  # Also append to combined CSV
  echo "$ROW" >> $CSV_COMBINED

  echo "    p50=${P50}ms  p75=${P75}ms  p90=${P90}ms  p99=${P99}ms  rps=$RPS"
}

# ── Verify service is reachable ───────────────
check_service() {
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $SERVICE_URL)
  if [ "$HTTP_STATUS" != "200" ]; then
    echo "ERROR: app not reachable at $SERVICE_URL (status: $HTTP_STATUS)"
    echo "Check: kubectl get pods -o wide"
    exit 1
  fi
  echo "Service reachable at $SERVICE_URL"
}