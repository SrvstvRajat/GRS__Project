# #!/bin/bash

# echo "============================================"
# echo " Launching CPU stress on minikube-m03"
# echo "============================================"

# kubectl apply -f 9_cpu_stress_pod.yaml

# echo "Waiting for stress pod to start..."
# kubectl wait --for=condition=Ready pod/cpu-stress --timeout=30s 2>/dev/null || true

# echo ""
# kubectl get pod cpu-stress -o wide

# echo ""
# echo "CPU stress running on minikube-m03 for 300 seconds."
# echo "Run your wrk + bpftrace experiments NOW."
# echo ""
# echo "To stop stress early:"
# echo "  kubectl delete pod cpu-stress"

#!/bin/bash

echo "============================================"
echo " Launching CPU stress on minikube-m03"
echo "============================================"

kubectl apply -f S_9_cpu_stress_pod.yaml

echo "Waiting for stress pod to start..."
kubectl wait --for=condition=Ready pod/cpu-stress --timeout=60s 2>/dev/null || true

echo ""
kubectl get pod cpu-stress -o wide

echo ""
echo "CPU stress running on minikube-m03 for 300 seconds."
echo "Run your wrk + bpftrace experiments NOW."
echo ""
echo "To stop stress early:"
echo "  kubectl delete pod cpu-stress --grace-period=0"