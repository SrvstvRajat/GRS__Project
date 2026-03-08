#!/bin/bash

echo "Running TCP latency probe using bpftrace..."

sudo bpftrace -e '
kprobe:tcp_sendmsg
{
    @start[tid] = nsecs;
}

kretprobe:tcp_sendmsg
/@start[tid]/
{
    @lat = hist((nsecs - @start[tid]) / 1000);
    delete(@start[tid]);
}
'
