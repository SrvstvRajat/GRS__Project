import matplotlib.pyplot as plt

# Run queue latency buckets (microseconds)
latency_buckets = [
    "[0]",
    "[1]",
    "[2-4)",
    "[4-8)",
    "[8-16)",
    "[16-32)",
    "[32-64)",
    "[64-128)",
    "[128-256)",
    "[256-512)",
    "[512-1K)",
    "[1K-2K)",
    "[2K-4K)"
]

# Counts from eBPF output
counts = [
    4789,
    127010,
    227327,
    166786,
    46105,
    6226,
    2001,
    689,
    199,
    121,
    120,
    75,
    14
]

plt.figure()

plt.bar(latency_buckets, counts)

plt.title("CPU Run Queue Latency Distribution (eBPF)")
plt.xlabel("Scheduling Delay (µs)")
plt.ylabel("Number of Events")

plt.xticks(rotation=45)

plt.tight_layout()
plt.show()