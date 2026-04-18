from flask import Flask, jsonify
import redis
import os
import time
import socket

app = Flask(__name__)

REDIS_HOST = os.environ.get("REDIS_HOST", "redis.default.svc.cluster.local")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, socket_connect_timeout=2)

@app.route("/")
def index():
    start = time.time()

    # SET + GET on every request — forces real cross-node TCP call
    key = f"req:{socket.gethostname()}:{int(start * 1000)}"
    r.set(key, "hit", ex=10)
    val = r.get(key)

    # Also increment a global counter
    count = r.incr("request_count")

    latency_ms = (time.time() - start) * 1000

    return jsonify({
        "status": "ok",
        "redis_host": REDIS_HOST,
        "request_count": count,
        "redis_latency_ms": round(latency_ms, 3),
        "value": val.decode() if val else None
    })

@app.route("/health")
def health():
    try:
        r.ping()
        return jsonify({"status": "ok", "redis": "reachable"})
    except Exception as e:
        return jsonify({"status": "error", "redis": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)