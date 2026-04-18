echo "[probe5] Starting Redis Inter-node RTT probe..."
sudo bpftrace -e '
kprobe:tcp_sendmsg
/comm == "redis-cli"/
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