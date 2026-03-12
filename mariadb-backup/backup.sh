#!/bin/bash
# ============================================================
# MariaDB Backup Script
# Compressao gzip + retencao + upload S3 opcional
# ============================================================

set -euo pipefail

# ---- Configuracao via variaveis de ambiente ----
DB_HOST="${DB_HOST:-mariadb}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAMES="${DB_NAMES:-}"          # vazio = todas as databases
BACKUP_DIR="${BACKUP_DIR:-/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
S3_BUCKET="${S3_BUCKET:-}"        # vazio = sem upload S3
S3_PREFIX="${S3_PREFIX:-backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "[$(date)] Iniciando backup..."

# ---- Funcao de backup ----
backup_database() {
    local db_name="$1"
    local backup_file="${BACKUP_DIR}/${db_name}_${TIMESTAMP}.sql.gz"

    echo "[$(date)] Backup: ${db_name}..."

    mariadb-dump \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --user="${DB_USER}" \
        --password="${DB_PASSWORD}" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        "${db_name}" | gzip > "${backup_file}"

    local size
    size=$(du -h "${backup_file}" | cut -f1)
    echo "[$(date)] Concluido: ${backup_file} (${size})"

    # Upload S3 (se configurado)
    if [ -n "${S3_BUCKET}" ]; then
        echo "[$(date)] Upload S3: s3://${S3_BUCKET}/${S3_PREFIX}/"
        aws s3 cp "${backup_file}" "s3://${S3_BUCKET}/${S3_PREFIX}/" --quiet
        echo "[$(date)] Upload concluido."
    fi
}

# ---- Listar databases ou usar lista definida ----
if [ -n "${DB_NAMES}" ]; then
    IFS=',' read -ra DATABASES <<< "${DB_NAMES}"
else
    DATABASES=$(mariadb \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --user="${DB_USER}" \
        --password="${DB_PASSWORD}" \
        -e "SHOW DATABASES;" -s --skip-column-names \
        | grep -Ev "^(information_schema|performance_schema|mysql|sys)$")
fi

# ---- Executar backups ----
for db in ${DATABASES[@]}; do
    backup_database "${db}"
done

# ---- Limpeza de backups antigos ----
echo "[$(date)] Removendo backups com mais de ${RETENTION_DAYS} dias..."
find "${BACKUP_DIR}" -name "*.sql.gz" -mtime +"${RETENTION_DAYS}" -delete

echo "[$(date)] Backup finalizado com sucesso."
