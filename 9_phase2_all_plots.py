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
    runq_values = [9902, 223593, 1155551, 1188314, 390636, 314257, 182115, 144902, 123320, 109148, 112924, 101112, 77562, 32433, 6225, 779, 2490, 179]
    save_bar(runq_labels, runq_values, "Phase 2: Run-Queue Latency Distribution", "Scheduling Delay (us)", "Events", "results/phase2_run_queue_plot.png")

    # 2) TCP send latency
    tcp_labels = [
        "[0]", "[1]", "[2-4)", "[4-8)", "[8-16)", "[16-32)", "[32-64)",
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)",
        "[2K-4K)", "[4K-8K)", "[8K-16K)", "[16K-32K)", "[32K-64K)",
        "[64K-128K)",
    ]
    tcp_values = [2, 106, 965, 3590, 6438, 175133, 256250, 61845, 8503, 523, 285, 186, 122, 49, 7, 0, 29, 1]
    save_bar(tcp_labels, tcp_values, "Phase 2: TCP Send Latency Distribution", "Latency Bucket (us)", "Events", "results/phase2_tcp_send_plot.png")

    # 3) TCP retransmits by process
    retrans_labels = [
        "code", "kube-apiserver", "Xorg", "CodecWorker", "etcd", "python", "ksoftirqd/2",
        "ThreadPoolForeg", "chrome", "VideoFrameCompo", "ksoftirqd/6", "kubelet",
        "VizCompositorTh", "swapper/0", "swapper/7", "swapper/1", "stress",
    ]
    retrans_values = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 5, 10]
    save_bar(retrans_labels, retrans_values, "Phase 2: TCP Retransmits by Process", "Retransmits", "Process", "results/phase2_tcp_retransmit_plot.png", figsize=(12, 8), horizontal=True)

    # 4) Socket drops by process
    drop_labels = [
        "ThreadPoolServi", "swapper/7", "VizCompositorTh", "gfx", "runc:[2:INIT]", "rcu_sched",
        "swapper/0", "ThreadPoolForeg", "swapper/5", "WebRTC_W_and_N", "threaded-ml", "pulseaudio",
        "gnome-shel:cs0", "command-not-fou", "VideoFrameCompo", "minikube", "Realtime AudioW",
        "CodecWorker", "etcd", "redis-server", "systemd-resolve", "Xorg", "code", "avahi-daemon",
        "kworker/6:1", "AudioProcessing", "Compositor", "sudo", "Chrome_ChildIOT", "dockerd",
        "chrome", "kworker/5:0", "getent", "stress", "kube-controller", "Chrome_IOThread",
        "systemd-journal", "kube-apiserver", "kube-scheduler", "coredns", "kworker/u32:1",
        "calico-node", "kubelet", "ksoftirqd/3", "ksoftirqd/4", "ksoftirqd/6", "ksoftirqd/1",
        "ksoftirqd/0", "ksoftirqd/5", "ksoftirqd/2", "ksoftirqd/7", "kworker/u32:0",
        "kworker/u32:2", "python", "irq/81-rtw88_pc", "wrk",
    ]
    drop_values = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 9, 10, 12, 13, 16, 26, 32, 149, 179, 218, 230, 258, 463, 561, 580, 604, 665, 680, 700, 745, 988, 1074, 1075, 9701, 15277, 45256]
    save_bar(drop_labels, drop_values, "Phase 2: Socket Drops by Process", "Drops", "Process", "results/phase2_socket_drop_plot.png", figsize=(12, 10), horizontal=True)

    # 5) Redis RTT approximation
    redis_labels = [
        "[64-128)", "[128-256)", "[256-512)", "[512-1K)", "[1K-2K)", "[2K-4K)", "[4K-8K)",
        "[8K-16K)", "[16K-32K)", "[32K-64K)", "[64K-128K)", "[128K-256K)", "[256K-512K)",
        "[512K-1M)", "[1M-2M)", "[2M-4M)", "[4M-8M)", "[8M-16M)", "[16M-32M)",
    ]
    redis_values = [20172, 64594, 41849, 24645, 29875, 17637, 9007, 1459, 142, 4746, 335, 0, 0, 0, 3, 2, 7, 5, 2]
    save_bar(redis_labels, redis_values, "Phase 2: Redis Path RTT Approximation", "Latency Bucket (us)", "Events", "results/phase2_redis_rtt_plot.png")

    # 6) Latency vs Connections (Phase 2)
    connections = [10, 50, 100, 200, 300]

    p50 = [12.64, 126.02, 289.44, 578.39, 827.69]
    p75 = [40.37, 167.07, 298.41, 593.99, 875.95]
    p90 = [64.22, 176.96, 307.58, 607.79, 888.20]
    p99 = [76.55, 190.85, 359.75, 668.14, 926.63]

    save_line_multi(
        connections,
        [p50, p75, p90, p99],
        ["p50", "p75", "p90", "p99"],
        "Phase 2: Latency vs Connections",
        "Connections",
        "Latency (ms)",
        "results/phase2_latency_vs_connections.png"
    )

if __name__ == "__main__":
    main()
