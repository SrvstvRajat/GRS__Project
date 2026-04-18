# #!/bin/bash

# # ============================================
# #  eBPF Observability Suite
# #  Run each probe in a separate terminal
# #  All probes run inside minikube nodes via
# #  'minikube ssh -n <nodename>'
# # ============================================

# echo "============================================"
# echo " eBPF Probe Reference Guide"
# echo "============================================"
# echo ""
# echo "Open 4 terminals. Run one probe per terminal."
# echo "Use: minikube ssh -n <node> to enter a node"
# echo ""

# NGINX_NODE="minikube-m02"
# STRESS_NODE="minikube-m03"
# CONTROL_NODE="minikube"

# # ─────────────────────────────────────────────
# # PROBE 1: CPU Run-Queue Latency on nginx node
# # → Measures how long nginx threads wait before
# #   getting CPU time. Spikes = scheduling pressure.
# # ─────────────────────────────────────────────
# PROBE1='
# sudo bpftrace -e '"'"'
# tracepoint:sched:sched_wakeup
# {
#     @wake[args->pid] = nsecs;
# }

# tracepoint:sched:sched_switch
# /@wake[args->next_pid]/
# {
#     $lat = (nsecs - @wake[args->next_pid]) / 1000;
#     @runqlat_us = hist($lat);
#     delete(@wake[args->next_pid]);
# }

# interval:s:5
# {
#     print(@runqlat_us);
#     clear(@runqlat_us);
# }
# '"'"'
# '

# # ─────────────────────────────────────────────
# # PROBE 2: TCP Send Latency on nginx node
# # → Measures time inside tcp_sendmsg kernel fn.
# #   High values = socket buffer pressure or
# #   kernel TCP stack under load.
# # ─────────────────────────────────────────────
# PROBE2='
# sudo bpftrace -e '"'"'
# kprobe:tcp_sendmsg
# {
#     @start[tid] = nsecs;
# }

# kretprobe:tcp_sendmsg
# /@start[tid]/
# {
#     $lat = (nsecs - @start[tid]) / 1000;
#     @tcp_send_lat_us = hist($lat);
#     delete(@start[tid]);
# }

# interval:s:5
# {
#     print(@tcp_send_lat_us);
#     clear(@tcp_send_lat_us);
# }
# '"'"'
# '

# # ─────────────────────────────────────────────
# # PROBE 3: TCP Retransmits (cross-node traffic)
# # → Counts retransmit events. On multi-node
# #   setup these are real CNI-layer drops.
# #   Retransmits directly cause p99 spikes.
# # ─────────────────────────────────────────────
# PROBE3='
# sudo bpftrace -e '"'"'
# kprobe:tcp_retransmit_skb
# {
#     @retransmits = count();
#     printf("[%llu] TCP RETRANSMIT — total so far: %d\n", nsecs, @retransmits);
# }

# interval:s:5
# {
#     printf("--- 5s retransmit count: %d ---\n", @retransmits);
# }
# '"'"'
# '

# # ─────────────────────────────────────────────
# # PROBE 4: Socket Receive Buffer Saturation
# # → Detects when kernel drops packets because
# #   the app (nginx) isn't reading fast enough.
# #   Direct cause of tail latency under load.
# # ─────────────────────────────────────────────
# PROBE4='
# sudo bpftrace -e '"'"'
# tracepoint:skb:kfree_skb
# {
#     @dropped_packets = count();
# }

# interval:s:5
# {
#     printf("[%llu] Dropped packets (5s window): %d\n", nsecs, @dropped_packets);
#     clear(@dropped_packets);
# }
# '"'"'
# '

# # ─────────────────────────────────────────────
# # PROBE 5: Inter-node latency via Redis calls
# # → Measures time between redis command sent
# #   and response received. Shows cross-node
# #   network jitter between m02 and control node.
# # ─────────────────────────────────────────────
# PROBE5='
# sudo bpftrace -e '"'"'
# kprobe:tcp_sendmsg
# /comm == "redis-cli"/
# {
#     @redis_start[tid] = nsecs;
# }

# kretprobe:tcp_recvmsg
# /@redis_start[tid]/
# {
#     $lat = (nsecs - @redis_start[tid]) / 1000;
#     @redis_rtt_us = hist($lat);
#     delete(@redis_start[tid]);
# }

# interval:s:5
# {
#     print(@redis_rtt_us);
#     clear(@redis_rtt_us);
# }
# '"'"'
# '

# # ─────────────────────────────────────────────
# # Print all commands for copy-paste
# # ─────────────────────────────────────────────

# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "TERMINAL 1 — Run-Queue Latency (nginx node: $NGINX_NODE)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "minikube ssh -n $NGINX_NODE"
# echo "$PROBE1"
# echo ""

# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "TERMINAL 2 — TCP Send Latency (nginx node: $NGINX_NODE)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "minikube ssh -n $NGINX_NODE"
# echo "$PROBE2"
# echo ""

# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "TERMINAL 3 — TCP Retransmits (stress node: $STRESS_NODE)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "minikube ssh -n $STRESS_NODE"
# echo "$PROBE3"
# echo ""

# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "TERMINAL 4 — Socket Drop Detection (nginx node: $NGINX_NODE)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "minikube ssh -n $NGINX_NODE"
# echo "$PROBE4"
# echo ""

# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "TERMINAL 5 — Redis Inter-node RTT (control: $CONTROL_NODE)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "minikube ssh -n $CONTROL_NODE"
# echo "$PROBE5"
# echo ""



#!/bin/bash

# ============================================
#  eBPF Observability Suite
#  All probes run on the HOST kernel
#  (minikube nodes share the host kernel)
#
#  Run each probe in a separate terminal
#  BEFORE starting the wrk load test.
#  Hit Ctrl+C to stop — histogram prints automatically.
# ============================================

echo "============================================"
echo " eBPF Probe Reference Guide"
echo "============================================"
echo ""
echo "NOTE: All probes run on the HOST machine (not inside minikube ssh)"
echo "      because minikube nodes share the host kernel."
echo ""
echo "Open 5 terminals. Run one probe per terminal."
echo "Start all probes BEFORE running the wrk load test."
echo ""

# ─────────────────────────────────────────────
# PROBE 1: CPU Run-Queue Latency
# → Measures how long threads wait before
#   getting CPU time. Spikes = scheduling pressure
#   caused by cpu-stress noisy neighbor.
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TERMINAL 1 — Run-Queue Latency"
echo "What it shows: scheduler contention from cpu-stress"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
sudo bpftrace -e '
tracepoint:sched:sched_wakeup
{
    @wake[args->pid] = nsecs;
}
tracepoint:sched:sched_switch
/@wake[args->next_pid]/
{
    $lat = (nsecs - @wake[args->next_pid]) / 1000;
    @runqlat_us = hist($lat);
    delete(@wake[args->next_pid]);
}'
EOF
echo ""

# ─────────────────────────────────────────────
# PROBE 2: TCP Send Latency
# → Measures time inside tcp_sendmsg kernel fn.
#   High values = socket buffer pressure or
#   kernel TCP stack under load.
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TERMINAL 2 — TCP Send Latency"
echo "What it shows: kernel TCP stack latency under load"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
sudo bpftrace -e '
kprobe:tcp_sendmsg
{
    @start[tid] = nsecs;
}
kretprobe:tcp_sendmsg
/@start[tid]/
{
    $lat = (nsecs - @start[tid]) / 1000;
    @tcp_send_lat_us = hist($lat);
    delete(@start[tid]);
}'
EOF
echo ""

# ─────────────────────────────────────────────
# PROBE 3: TCP Retransmits
# → Counts retransmit events.
#   Retransmits directly cause p99 latency spikes.
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TERMINAL 3 — TCP Retransmits"
echo "What it shows: packet loss causing latency spikes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
sudo bpftrace -e '
kprobe:tcp_retransmit_skb
{
    @retransmits = count();
    printf("[%llu ns] TCP RETRANSMIT — total: %d\n", nsecs, @retransmits);
}'
EOF
echo ""

# ─────────────────────────────────────────────
# PROBE 4: Socket Packet Drops
# → Detects when kernel drops packets because
#   the app isn't reading fast enough.
#   Direct cause of tail latency under load.
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TERMINAL 4 — Socket Packet Drops"
echo "What it shows: kernel-level packet drops under high load"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
sudo bpftrace -e '
tracepoint:skb:kfree_skb
{
    @dropped_packets = count();
}'
EOF
echo ""

# ─────────────────────────────────────────────
# PROBE 5: Redis RTT (gunicorn → redis TCP calls)
# → Measures time between gunicorn sending a
#   redis command and receiving the response.
#   Shows cross-node network jitter impact on app.
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TERMINAL 5 — Redis RTT (gunicorn → redis)"
echo "What it shows: flask-to-redis latency per request"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
sudo bpftrace -e '
kprobe:tcp_sendmsg
/comm == "gunicorn"/
{
    @redis_start[tid] = nsecs;
}
kretprobe:tcp_recvmsg
/@redis_start[tid]/
{
    $lat = (nsecs - @redis_start[tid]) / 1000;
    @redis_rtt_us = hist($lat);
    delete(@redis_start[tid]);
}'
EOF
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Start all 5 probes, then run:"
echo "   bash 9_wrk_load_stress_latency.sh"
echo " Hit Ctrl+C on each probe when wrk finishes."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"