# echo "[probe3] Starting TCP Retransmit probe..."
# sudo bpftrace -e '
# kprobe:tcp_retransmit_skb
# {
#     @retransmits = count();
# }'

echo "[probe3] Starting TCP Retransmit probe..."
sudo bpftrace -e '
tracepoint:tcp:tcp_retransmit_skb
{
    @retransmits = count();
    @retransmit_by_comm[comm] = count();
}'