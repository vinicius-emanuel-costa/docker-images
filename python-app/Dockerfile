# ============================================================
# Python App — Multi-stage Flask production build
# ============================================================
# Stage 1: Build dependencies
# Stage 2: Slim runtime with gunicorn
# Final image ~60MB
# ============================================================

# ---- Stage 1: Builder ----
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Stage 2: Runtime ----
FROM python:3.12-slim AS runtime

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="Python Flask app com multi-stage build, non-root, gunicorn"

# Instalar apenas o necessario no runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Criar usuario non-root
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -d /app -s /sbin/nologin appuser

WORKDIR /app

# Copiar dependencias do builder
COPY --from=builder /install /usr/local

# Copiar codigo da aplicacao
COPY --chown=appuser:appgroup app.py .

# Porta da aplicacao
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Non-root
USER appuser

# Gunicorn em producao
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "2", "--timeout", "120", "app:app"]
