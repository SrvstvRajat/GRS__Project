echo "[probe2] Starting TCP Send Latency probe..."
sudo bpftrace -e '
kprobe:tcp_sendmsg { @start[tid] = nsecs; }
kretprobe:tcp_sendmsg
/@start[tid]/
{
    $lat = (nsecs - @start[tid]) / 1000;
    @tcp_send_lat_us = hist($lat);
    delete(@start[tid]);
}'