#!/bin/bash
# ============================================================
# Check Disk Health — Verifica SMART status dos discos
# ============================================================
# Retorno: 0 = OK, 1 = WARNING, 2 = CRITICAL
# ============================================================

set -euo pipefail

THRESHOLD_WARNING="${THRESHOLD_WARNING:-80}"
THRESHOLD_CRITICAL="${THRESHOLD_CRITICAL:-90}"
STATUS=0
OUTPUT=""

# ---- Verificar uso de disco ----
while IFS= read -r line; do
    usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')

    if [ "$usage" -ge "$THRESHOLD_CRITICAL" ]; then
        OUTPUT="${OUTPUT}CRITICAL: ${mount} em ${usage}%\n"
        STATUS=2
    elif [ "$usage" -ge "$THRESHOLD_WARNING" ]; then
        OUTPUT="${OUTPUT}WARNING: ${mount} em ${usage}%\n"
        [ "$STATUS" -lt 1 ] && STATUS=1
    fi
done < <(df -h --output=pcent,target | tail -n +2 | grep -v "tmpfs\|devtmpfs")

# ---- Verificar SMART (se disponivel) ----
if command -v smartctl &> /dev/null; then
    for disk in /dev/sd?; do
        if [ -b "$disk" ]; then
            smart_status=$(smartctl -H "$disk" 2>/dev/null | grep -i "result" | awk '{print $NF}' || echo "UNKNOWN")
            if [ "$smart_status" != "PASSED" ] && [ "$smart_status" != "UNKNOWN" ]; then
                OUTPUT="${OUTPUT}CRITICAL: SMART failed em ${disk}\n"
                STATUS=2
            fi
        fi
    done
fi

# ---- Resultado ----
if [ "$STATUS" -eq 0 ]; then
    echo "OK: Todos os discos saudaveis"
else
    echo -e "$OUTPUT"
fi

exit "$STATUS"
