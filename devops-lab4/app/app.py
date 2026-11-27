"""Demo service used by every part of Lab 4."""
import os
import random
import threading

import requests
from flask import Flask, jsonify

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")
COLOR = os.getenv("APP_COLOR", "blue")
ERROR_RATE = float(os.getenv("ERROR_RATE", "0"))  # fault injection for canary demo

_lock = threading.Lock()
_stats = {"requests": 0, "errors": 0}


def _count(error=False):
    with _lock:
        _stats["requests"] += 1
        if error:
            _stats["errors"] += 1


def get_secret(name, default=None):
    """Fetch a secret from Vault (KV v2) if configured, else env var, else default."""
    addr, token = os.getenv("VAULT_ADDR"), os.getenv("VAULT_TOKEN")
    path = os.getenv("VAULT_SECRET_PATH", "secret/data/devops-lab4")
    if addr and token:
        try:
            r = requests.get(f"{addr}/v1/{path}", headers={"X-Vault-Token": token}, timeout=3)
            r.raise_for_status()
            value = r.json()["data"]["data"].get(name)
            if value is not None:
                return value, "vault"
        except (requests.RequestException, KeyError, ValueError):
            pass
    if os.getenv(name) is not None:
        return os.getenv(name), "env"
    return default, "none"


@app.route("/")
def index():
    if random.random() < ERROR_RATE:
        _count(error=True)
        return jsonify(error="injected failure", version=VERSION), 500
    _count()
    return jsonify(message="Hello from DevOps Lab 4", version=VERSION, color=COLOR)


@app.route("/health")
def health():
    return jsonify(status="ok", version=VERSION)


@app.route("/add/<int:a>/<int:b>")
def add(a, b):
    return jsonify(result=a + b)


@app.route("/secret-check")
def secret_check():
    """Proves a secret was loaded WITHOUT ever returning its value."""
    value, source = get_secret("DB_PASSWORD")
    return jsonify(loaded=value is not None, source=source,
                   masked="*" * 8 if value else None)


@app.route("/metrics")
def metrics():
    with _lock:
        body = (f"app_requests_total {_stats['requests']}\n"
                f"app_errors_total {_stats['errors']}\n")
    return body, 200, {"Content-Type": "text/plain"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
