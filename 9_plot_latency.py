import matplotlib.pyplot as plt

# Experiment loads
load = [10, 50, 100,200,300]

# Latency values (ms)
p50 = [1.01,3.58,7.13,17.73,20.62]
p90 = [3.69, 37.74, 51.11,85.34,84.21]
p99 = [33.19, 80.46, 95.28,528.99,1020]

plt.figure()

plt.plot(load, p50, marker='o', label='P50')
plt.plot(load, p90, marker='o', label='P90')
plt.plot(load, p99, marker='o', label='P99')

plt.xlabel("Connections")
plt.ylabel("Latency (ms)")
plt.title("Latency vs Load in Kubernetes Microservice")

plt.legend()
plt.grid(True)

plt.savefig("latency_plot.png")
plt.show()
