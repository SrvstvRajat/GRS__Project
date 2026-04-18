import matplotlib.pyplot as plt


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


def save_line(x, y_list, labels, title, xlabel, ylabel, out_file, figsize=(12, 5)):
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


def main():
    # 1) Run queue latency
    runq_labels = [
        "[0]", "[1]", "[2-4)", "[4-8)", "[8-16)", "[16-32)", "[32-64)",
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)",
        "[2K-4K)", "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)",
        "[64K-128K)",
    ]
    runq_values = [26077, 430432, 1994612, 1982626, 487429, 384084, 219752, 127691, 92830, 65425, 51493, 30879, 11590, 2690, 378, 9, 12, 4170]
    save_bar(runq_labels, runq_values, "Phase 1: Run-Queue Latency Distribution", "Scheduling Delay (us)", "Events", "results/phase1_run_queue_plot.png")

    # 2) TCP send latency
    tcp_labels = [
        "[0]", "[1]", "[2-4)", "[4-8)", "[8-16)", "[16-32)", "[32-64)",
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)",
        "[2K-4K)", "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)",
        "[64K-128K)",
    ]
    tcp_values = [4, 91, 715, 1992, 15780, 157541, 204588, 83863, 11568, 494, 162, 96, 42, 7, 0, 0, 0, 23]
    save_bar(tcp_labels, tcp_values, "Phase 1: TCP Send Latency Distribution", "Latency Bucket (us)", "Events", "results/phase1_tcp_send_plot.png")

    # 3) TCP retransmits by process
    retrans_labels = [
        "dockerd", "Chrome_IOThread", "AudioOutputDevi", "alsa-source-USB", "VideoFrameCompo",
        "ksoftirqd/2", "kubelet", "ksoftirqd/0", "Compositor", "kube-apiserver",
        "avahi-daemon", "ThreadPoolForeg", "swapper/6", "chrome", "wrk", "CodecWorker",
        "etcd", "VizCompositorTh", "swapper/1", "swapper/4", "ksoftirqd/4", "Xorg",
        "desktopCaptureT", "swapper/5", "swapper/0", "swapper/2", "swapper/3",
        "swapper/7", "python",
    ]
    retrans_values = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 7, 16]
    save_bar(retrans_labels, retrans_values, "Phase 1: TCP Retransmits by Process", "Retransmits", "Process", "results/phase1_tcp_retransmit_plot.png", figsize=(12, 8), horizontal=True)

    # 4) Socket drops by process
    drop_labels = [
        "VideoFrameCompo", "systemd", "AudioProcessing", "systemd-resolve", "cups-browsed", "redis-server",
        "curl", "Xorg", "swapper/0", "swapper/6", "gfx", "code", "cron", "minikube",
        "desktopCaptureT", "swapper/3", "swapper/1", "swapper/7", "avahi-daemon", "swapper/5",
        "Compositor", "sudo", "getent", "CodecWorker", "VizCompositorTh", "Chrome_ChildIOT",
        "ThreadPoolSingl", "ThreadPoolServi", "etcd", "kube-controller", "Chrome_IOThread", "chrome",
        "ThreadPoolForeg", "kube-apiserver", "kube-scheduler", "coredns", "calico-node", "ksoftirqd/6",
        "ksoftirqd/0", "ksoftirqd/5", "ksoftirqd/2", "ksoftirqd/3", "ksoftirqd/1", "ksoftirqd/4",
        "kubelet", "kworker/u32:1", "kworker/u32:3", "ksoftirqd/7", "kworker/u32:2", "irq/81-rtw88_pc",
        "python", "wrk",
    ]
    drop_values = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 4, 4, 6, 6, 6, 7, 8, 9, 9, 10, 17, 24, 25, 41, 204, 222, 239, 286, 328, 344, 345, 374, 375, 389, 398, 480, 529, 653, 827, 1390, 15895, 28134, 33280]
    save_bar(drop_labels, drop_values, "Phase 1: Socket Drops by Process", "Drops", "Process", "results/phase1_socket_drop_plot.png", figsize=(12, 10), horizontal=True)

    # 5) Redis RTT approximation
    redis_labels = [
        "[32-64)", "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)", "[2K-4K)",
        "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)", "[64K-128K)", "[128K-256K)",
        "[256K-512K)", "[512K-1M)", "[1M-2M)", "[2M-4M)", "[4M-8M)", "[8M-16M)", "[16M-32M)",
    ]
    redis_values = [214, 37709, 80627, 52702, 11595, 4525, 1236, 300, 17, 0, 13, 5275, 0, 0, 0, 1, 1, 5, 7, 3]
    save_bar(redis_labels, redis_values, "Phase 1: Redis Path RTT Approximation", "Latency Bucket (us)", "Events", "results/phase1_redis_rtt_plot.png")

    # 6) Latency vs Connections
    connections = [10, 50, 100, 200, 300]
    p50 = [5.43, 125.67, 301.96, 607.18, 908.58]
    p75 = [57.17, 191.91, 306.15, 688.99, 989.64]
    p90 = [86.30, 194.33, 385.94, 695.47, 996.34]
    p99 = [91.34, 198.16, 394.38, 705.38, 1160.00]

    save_line(
        connections,
        [p50, p75, p90, p99],
        ["p50", "p75", "p90", "p99"],
        "Phase 1: Latency vs Connections",
        "Connections",
        "Latency (ms)",
        "results/phase1_latency_vs_connections.png"
    )

if __name__ == "__main__":
    main()