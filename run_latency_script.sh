#!/bin/bash

SERVICE_URL="http://localhost:8080"
DURATION=30s

OUTPUT_FILE="latency_results.csv"

echo "connections,p50_ms,p90_ms,p99_ms" > $OUTPUT_FILE

LOADS=(10 50 100 200 300)

for c in "${LOADS[@]}"
do
    echo "Running test with $c connections..."

    RESULT=$(wrk -t4 -c$c -d$DURATION --latency $SERVICE_URL)

    P50=$(echo "$RESULT" | grep "50%" | awk '{print $2}' | sed 's/ms//')
    P90=$(echo "$RESULT" | grep "90%" | awk '{print $2}' | sed 's/ms//')
    P99=$(echo "$RESULT" | grep "99%" | awk '{print $2}' | sed 's/ms//')

    echo "$c,$P50,$P95,$P99" >> $OUTPUT_FILE
done

echo "Experiment completed."
echo "Results saved to $OUTPUT_FILE"