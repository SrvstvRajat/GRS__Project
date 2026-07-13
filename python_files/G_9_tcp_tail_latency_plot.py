import matplotlib.pyplot as plt

# Buckets directly from bpftrace output
latency_buckets = [
    "[1]",
    "[2-4)",
    "[4-8)",
    "[8-16)",
    "[16-32)",
    "[32-64)",
    "[64-128)"
]

counts = [1, 0, 69, 1134, 3899, 2993, 426]

plt.figure()

plt.bar(latency_buckets, counts)

plt.title("TCP Kernel Latency Distribution (eBPF)")
plt.xlabel("Latency Bucket (µs)")
plt.ylabel("Number of Events")

plt.tight_layout()
plt.show()