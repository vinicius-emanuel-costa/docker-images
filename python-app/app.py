"""
Flask App — Health endpoint para demonstracao Docker.
"""

import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

START_TIME = datetime.now(timezone.utc)


@app.route("/")
def index():
    return jsonify({
        "service": "python-app",
        "status": "running",
        "hostname": socket.gethostname(),
    })


@app.route("/health")
def health():
    uptime = (datetime.now(timezone.utc) - START_TIME).total_seconds()
    return jsonify({
        "status": "healthy",
        "uptime_seconds": round(uptime, 2),
        "version": os.getenv("APP_VERSION", "1.0.0"),
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
