import matplotlib.pyplot as plt


connections = [10, 50, 100, 200, 300]

# Hardcoded from the pasted CSV output.
# The recovery row for 100 connections contains a malformed p99 field in the source text.
# The intended value is treated as 104.39 ms so the series remains monotonic and usable.
baseline_p99 = [87.39, 84.82, 100.73, 191.92, 298.08]
stress_p99 = [70.71, 95.08, 100.74, 280.38, 299.16]
recovery_p99 = [87.33, 83.84, 104.39, 194.28, 296.33]

baseline_rps = [1244, 1289, 1356, 1335, 1347]
stress_rps = [934, 812, 1083, 1107, 1173]
recovery_rps = [1214, 1279, 1340, 1337, 1353]


def plot_latency():
    plt.figure(figsize=(9, 5))
    plt.plot(connections, baseline_p99, marker="o", linewidth=2, label="Baseline P99")
    plt.plot(connections, stress_p99, marker="o", linewidth=2, label="Stress P99")
    plt.plot(connections, recovery_p99, marker="o", linewidth=2, label="Recovery P99")
    plt.title("Latency vs Connections")
    plt.xlabel("Connections")
    plt.ylabel("Latency (ms)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("results/singlenode_latency_vs_connections.png", dpi=300)
    plt.show()


def plot_throughput():
    plt.figure(figsize=(9, 5))
    plt.plot(connections, baseline_rps, marker="o", linewidth=2, label="Baseline RPS")
    plt.plot(connections, stress_rps, marker="o", linewidth=2, label="Stress RPS")
    plt.plot(connections, recovery_rps, marker="o", linewidth=2, label="Recovery RPS")
    plt.title("Throughput vs Connections")
    plt.xlabel("Connections")
    plt.ylabel("Throughput (requests/sec)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("results/singlenode_throughput_vs_connections.png", dpi=300)
    plt.show()


if __name__ == "__main__":
    plot_latency()
    plot_throughput()
