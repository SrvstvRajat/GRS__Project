import matplotlib.pyplot as plt

def save_line_multi(x, y_list, labels, title, xlabel, ylabel, out_file, figsize=(12, 5)):
    plt.figure(figsize=figsize)

    for y, label in zip(y_list, labels):
        plt.plot(x, y, marker='o', label=label)

    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xticks(x)
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(out_file, dpi=300)
    plt.show()

def save_bar(labels, values, title, xlabel, ylabel, out_file, figsize=(12, 5), horizontal=False):
    plt.figure(figsize=figsize)
    if horizontal:
        items = sorted(zip(labels, values), key=lambda item: item[1])
        sorted_labels = [item[0] for item in items]
        sorted_values = [item[1] for item in items]
        plt.barh(sorted_labels, sorted_values, color="#2a9d8f")
    else:
        plt.bar(labels, values, color="#2a6f97")
        plt.xticks(rotation=45, ha="right")

    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.tight_layout()
    plt.savefig(out_file, dpi=300)
    plt.show()


def main():
    # 1) Run queue latency
    runq_labels = [
        "[0]", "[1]", "[2-4)", "[4-8)", "[8-16)", "[16-32)", "[32-64)",
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)",
        "[2K-4K)", "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)",
        "[64K-128K)",
    ]
    runq_values = [19982, 323188, 1654816, 1864017, 424252, 325066, 172219, 98675, 70745, 47561, 34502, 19719, 7132, 1592, 308, 11, 8, 4085]
    save_bar(runq_labels, runq_values, "Phase 3: Run-Queue Latency Distribution", "Scheduling Delay (us)", "Events", "results/phase3_run_queue_plot.png")

    # 2) TCP send latency
    tcp_labels = [
        "[0]", "[1]", "[2-4)", "[4-8)", "[8-16)", "[16-32)", "[32-64)",
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)",
        "[2K-4K)", "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)",
        "[64K-128K)",
    ]
    tcp_values = [7, 113, 626, 1053, 17320, 154508, 207429, 91412, 11008, 383, 138, 63, 27, 10, 1, 0, 0, 18]
    save_bar(tcp_labels, tcp_values, "Phase 3: TCP Send Latency Distribution", "Latency Bucket (us)", "Events", "results/phase3_tcp_send_plot.png")

    # 3) TCP retransmits by process
    retrans_labels = [
        "calico-node", "swapper/5", "swapper/0", "threaded-ml", "9_phase3_recove", "ksoftirqd/6",
        "ksoftirqd/0", "redis-server", "ksoftirqd/1", "wrk", "swapper/6", "gnome-shell", "code",
        "ksoftirqd/7", "avahi-daemon", "Compositor", "swapper/3", "swapper/4", "ThreadPoolForeg",
        "CodecWorker", "swapper/2", "swapper/1", "swapper/7", "python",
    ]
    retrans_values = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 4, 5, 6, 6, 6, 12]
    save_bar(retrans_labels, retrans_values, "Phase 3: TCP Retransmits by Process", "Retransmits", "Process", "results/phase3_tcp_retransmit_plot.png", figsize=(12, 8), horizontal=True)

    # 4) Socket drops by process
    drop_labels = [
        "systemd", "kworker/u32:0", "kworker/u33:2", "systemd-resolve", "curl", "systemd-journal", "gnome-shell",
        "redis-server", "threaded-ml", "swapper/6", "swapper/5", "swapper/0", "minikube", "swapper/3", "pulseaudio",
        "git-remote-http", "avahi-daemon", "swapper/1", "code", "sudo", "getent", "swapper/7", "CodecWorker",
        "ThreadPoolSingl", "PerfettoTrace", "etcd", "Compositor", "chrome", "Chrome_ChildIOT", "ThreadPoolForeg",
        "kube-controller", "Chrome_IOThread", "kube-apiserver", "kworker/u32:2", "kube-scheduler", "coredns", "calico-node",
        "ksoftirqd/1", "ksoftirqd/3", "ksoftirqd/0", "ksoftirqd/6", "ksoftirqd/4", "ksoftirqd/2", "ksoftirqd/5",
        "kubelet", "kworker/u32:3", "ksoftirqd/7", "kworker/u32:1", "irq/81-rtw88_pc", "python", "wrk",
    ]
    drop_values = [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 5, 6, 6, 6, 8, 9, 9, 11, 11, 13, 15, 25, 27, 36, 275, 275, 280, 290, 348, 384, 395, 397, 407, 410, 432, 447, 549, 635, 821, 2244, 18894, 31878, 32537]
    save_bar(drop_labels, drop_values, "Phase 3: Socket Drops by Process", "Drops", "Process", "results/phase3_socket_drop_plot.png", figsize=(12, 10), horizontal=True)

    # 5) Redis RTT approximation
    redis_labels = [
        "[32-64)", "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)", "[2K-4K)", "[4K-8K)",
        "[8K-16K)", "[16K-32K)", "[32K-64K)", "[64K-128K)", "[128K-256K)", "[256K-512K)", "[512K-1M)",
        "[1M-2M)", "[2M-4M)", "[4M-8M)", "[8M-16M)", "[16M-32M)",
    ]
    redis_values = [325, 36890, 81935, 56587, 11357, 3740, 848, 166, 18, 0, 12, 5292, 0, 0, 1, 3, 3, 14, 11, 10]
    save_bar(redis_labels, redis_values, "Phase 3: Redis Path RTT Approximation", "Latency Bucket (us)", "Events", "results/phase3_redis_rtt_plot.png")

    # 6) Latency vs Connections
    connections = [10, 50, 100, 200, 300]

    p50 = [5.48, 115.31, 300.92, 603.13, 902.63]
    p75 = [57.16, 191.28, 305.45, 610.15, 911.17]
    p90 = [86.29, 194.28, 385.67, 690.20, 990.60]
    p99 = [90.76, 198.93, 393.06, 705.21, 1110.00]

    save_line_multi(
        connections,
        [p50, p75, p90, p99],
        ["p50", "p75", "p90", "p99"],
        "Phase 3: Latency vs Connections",
        "Connections",
        "Latency (ms)",
        "results/phase3_latency_vs_connections.png"
    )

if __name__ == "__main__":
    main()
