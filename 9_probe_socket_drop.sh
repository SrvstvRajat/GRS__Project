echo "[probe4] Starting Socket Drop Detection probe..."
sudo bpftrace -e '
tracepoint:skb:kfree_skb
{
    @dropped_packets = count();
    @drop_by_comm[comm] = count();
}'
