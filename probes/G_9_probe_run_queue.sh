echo "[probe1] Starting Run-Queue Latency probe..."
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