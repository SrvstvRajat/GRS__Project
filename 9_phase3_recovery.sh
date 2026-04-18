#!/bin/bash

# ============================================
#  PHASE 3: Recovery
#  Kills cpu-stress pod, waits for system
#  to settle, then measures recovered latency.
# ============================================

source ./9_wrk_config.sh

echo "============================================"
echo " PHASE 3: Recovery (stress removed)"
echo " Target: $SERVICE_URL"
echo "============================================"

# Verify service
check_service

# Kill stress pod
echo "Deleting cpu-stress pod..."
kubectl delete pod cpu-stress --grace-period=0 2>/dev/null || true

echo "Waiting 10s for system to settle..."
sleep 10
echo "Ready."
echo ""

# Init CSV
echo $CSV_HEADER > $CSV_RECOVERY
echo "Saving results to: $CSV_RECOVERY"
echo ""

# Run load test
for c in "${LOADS[@]}"; do
  run_wrk $c "recovery" $CSV_RECOVERY
done

echo ""
echo "============================================"
echo " Phase 3 complete. Results:"
echo "============================================"
cat $CSV_RECOVERY