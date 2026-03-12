#!/bin/bash
# ============================================================
# Entrypoint — Inicia node_exporter + zabbix-agent2
# ============================================================

set -euo pipefail

echo "[$(date)] Iniciando agente de monitoramento..."

# ---- Configurar Zabbix Agent ----
ZABBIX_SERVER="${ZABBIX_SERVER:-127.0.0.1}"
ZABBIX_HOSTNAME="${ZABBIX_HOSTNAME:-$(hostname)}"

cat > /etc/zabbix/zabbix_agent2.conf <<EOF
Server=${ZABBIX_SERVER}
ServerActive=${ZABBIX_SERVER}
Hostname=${ZABBIX_HOSTNAME}
LogFile=/tmp/zabbix_agent2.log
PidFile=/var/run/zabbix/zabbix_agent2.pid
Include=/scripts/custom-checks/*.conf
EOF

# ---- Iniciar node_exporter em background ----
echo "[$(date)] Iniciando node_exporter na porta 9100..."
node_exporter \
    --web.listen-address=":9100" \
    --collector.filesystem \
    --collector.cpu \
    --collector.meminfo \
    --collector.diskstats \
    --collector.netdev \
    --collector.loadavg &

NODE_EXPORTER_PID=$!

# ---- Iniciar Zabbix Agent ----
echo "[$(date)] Iniciando zabbix-agent2 na porta 10050..."
zabbix_agent2 -c /etc/zabbix/zabbix_agent2.conf &

ZABBIX_PID=$!

echo "[$(date)] Agentes iniciados (node_exporter: ${NODE_EXPORTER_PID}, zabbix: ${ZABBIX_PID})"

# ---- Trap para shutdown graceful ----
cleanup() {
    echo "[$(date)] Encerrando agentes..."
    kill "${NODE_EXPORTER_PID}" "${ZABBIX_PID}" 2>/dev/null || true
    wait
    echo "[$(date)] Encerrado."
    exit 0
}

trap cleanup SIGTERM SIGINT

# ---- Manter container rodando ----
wait
