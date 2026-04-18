echo "[probe3] Starting TCP Retransmit probe..."
sudo bpftrace -e '
kprobe:tcp_retransmit_skb
{
    @retransmits = count();
}'