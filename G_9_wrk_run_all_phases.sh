#!/bin/bash

# ============================================
#  MASTER EXPERIMENT RUNNER
#  Runs all 3 phases in order and produces
#  a single combined CSV for analysis.
# ============================================

set -e

source ./G_9_wrk_config.sh

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     Tail Latency Experiment — wrk        ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Target:   $SERVICE_URL"
echo "Threads:  $THREADS"
echo "Duration: $DURATION per run"
echo "Loads:    ${LOADS[*]} connections"
echo "Output:   $RESULTS_DIR/"
echo ""

# Verify service before starting
check_service
echo ""

# Init combined CSV once
echo $CSV_HEADER > $CSV_COMBINED

# ─── Run all phases ───────────────────────────
bash G_9_phase1_baseline.sh
echo ""

bash G_9_phase2_stress.sh
echo ""

bash G_9_phase3_recovery.sh
echo ""

# ─── Print combined results ───────────────────
echo "╔══════════════════════════════════════════╗"
echo "║         Combined Results Summary         ║"
echo "╚══════════════════════════════════════════╝"
cat $CSV_COMBINED

echo ""
echo "Files saved:"
echo "  $CSV_BASELINE"
echo "  $CSV_STRESS"
echo "  $CSV_RECOVERY"
echo "  $CSV_COMBINED"
echo ""
echo "Experiment complete."