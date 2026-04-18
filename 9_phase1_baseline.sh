#!/bin/bash

# ============================================
#  PHASE 1: Baseline
#  No cpu-stress running.
#  Measures natural latency of flask → redis.
# ============================================

source ./9_wrk_config.sh

echo "============================================"
echo " PHASE 1: Baseline (no cpu-stress)"
echo " Target: $SERVICE_URL"
echo "============================================"

# Ensure stress pod is not running
kubectl delete pod cpu-stress --grace-period=0 2>/dev/null || true
sleep 3

# Verify service
check_service

# Init CSV
echo $CSV_HEADER > $CSV_BASELINE
echo ""
echo "Saving results to: $CSV_BASELINE"
echo ""

# Run load test
for c in "${LOADS[@]}"; do
  run_wrk $c "baseline" $CSV_BASELINE
done

echo ""
echo "============================================"
echo " Phase 1 complete. Results:"
echo "============================================"
cat $CSV_BASELINE