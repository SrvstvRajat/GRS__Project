import matplotlib.pyplot as plt


def save_phase_comparison(x, y_series, labels, title, xlabel, ylabel, out_file, figsize=(12, 5)):
    plt.figure(figsize=figsize)

    for y, label in zip(y_series, labels):
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
    connections = [10, 50, 100, 200, 300]

    baseline_rps = [324, 320, 320, 314, 315]
    stress_rps = [360, 348, 353, 349, 350]
    recovery_rps = [326, 323, 324, 322, 322]

    save_phase_comparison(
        connections,
        [baseline_rps, stress_rps, recovery_rps],
        ["Baseline", "Stress", "Recovery"],
        "Throughput vs Connections Across Phases",
        "Connections",
        "Requests per Second (RPS)",
        "results/all_phases_throughput_vs_connections.png"
    )


if __name__ == "__main__":
    main()