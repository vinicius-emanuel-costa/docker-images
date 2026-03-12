#!/bin/bash
# ============================================================
# Check SSL Expiry — Verifica validade de certificados SSL
# ============================================================
# Uso: check_ssl_expiry.sh <dominio> [porta] [dias_warning]
# Retorno: 0 = OK, 1 = WARNING, 2 = CRITICAL
# ============================================================

set -euo pipefail

DOMAIN="${1:-}"
PORT="${2:-443}"
WARNING_DAYS="${3:-30}"
CRITICAL_DAYS="${CRITICAL_DAYS:-7}"

if [ -z "$DOMAIN" ]; then
    echo "UNKNOWN: Uso: $0 <dominio> [porta] [dias_warning]"
    exit 3
fi

# ---- Obter data de expiracao ----
EXPIRY_DATE=$(echo | openssl s_client -servername "$DOMAIN" -connect "${DOMAIN}:${PORT}" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2)

if [ -z "$EXPIRY_DATE" ]; then
    echo "UNKNOWN: Nao foi possivel obter certificado de ${DOMAIN}:${PORT}"
    exit 3
fi

# ---- Calcular dias restantes ----
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s 2>/dev/null)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

# ---- Avaliar resultado ----
if [ "$DAYS_LEFT" -le 0 ]; then
    echo "CRITICAL: Certificado de ${DOMAIN} EXPIRADO (${EXPIRY_DATE})"
    exit 2
elif [ "$DAYS_LEFT" -le "$CRITICAL_DAYS" ]; then
    echo "CRITICAL: Certificado de ${DOMAIN} expira em ${DAYS_LEFT} dias (${EXPIRY_DATE})"
    exit 2
elif [ "$DAYS_LEFT" -le "$WARNING_DAYS" ]; then
    echo "WARNING: Certificado de ${DOMAIN} expira em ${DAYS_LEFT} dias (${EXPIRY_DATE})"
    exit 1
else
    echo "OK: Certificado de ${DOMAIN} valido por ${DAYS_LEFT} dias (${EXPIRY_DATE})"
    exit 0
fi
