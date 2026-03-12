# ============================================================
# Monitoring Agent — node_exporter + zabbix-agent + custom checks
# ============================================================
# Base: Alpine (~25MB)
# Features: Prometheus node_exporter, Zabbix agent, scripts customizados
# ============================================================

FROM alpine:3.20

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="Agente de monitoramento com node_exporter, zabbix-agent e checks customizados"

# Instalar dependencias
RUN apk add --no-cache \
    prometheus-node-exporter \
    zabbix-agent2 \
    bash \
    curl \
    openssl \
    jq \
    smartmontools \
    lsblk \
    tzdata

ENV TZ=America/Sao_Paulo

# Criar usuario e diretorios
RUN addgroup -g 1001 -S monitoring && \
    adduser -u 1001 -S monitor -G monitoring && \
    mkdir -p /scripts/custom-checks /var/run/zabbix && \
    chown -R monitor:monitoring /var/run/zabbix

# Copiar scripts
COPY --chmod=755 entrypoint.sh /scripts/entrypoint.sh
COPY --chmod=755 custom-checks/ /scripts/custom-checks/

# Portas: node_exporter (9100) + zabbix-agent (10050)
EXPOSE 9100 10050

# Health check — verifica se node_exporter responde
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -sf http://localhost:9100/metrics > /dev/null || exit 1

ENTRYPOINT ["/scripts/entrypoint.sh"]
