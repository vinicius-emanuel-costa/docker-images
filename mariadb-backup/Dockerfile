# ============================================================
# MariaDB Backup — Alpine + cron + compressao + S3 upload
# ============================================================
# Base: Alpine (~15MB)
# Features: mariadb-client, gzip, aws-cli opcional, cron
# ============================================================

FROM alpine:3.20

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="MariaDB backup automatizado com cron, compressao e upload S3"

# Instalar dependencias
RUN apk add --no-cache \
    mariadb-client \
    gzip \
    aws-cli \
    bash \
    curl \
    tzdata

# Timezone (ajustar conforme necessidade)
ENV TZ=America/Sao_Paulo

# Criar usuario e diretorios
RUN addgroup -g 1001 -S backup && \
    adduser -u 1001 -S backup -G backup && \
    mkdir -p /backups /scripts && \
    chown -R backup:backup /backups

# Copiar scripts
COPY --chmod=755 backup.sh /scripts/backup.sh
COPY crontab /etc/crontabs/root

# Volume para backups
VOLUME ["/backups"]

# Health check — verifica se cron esta rodando
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
    CMD pgrep crond > /dev/null || exit 1

# Cron precisa rodar como root, mas o script de backup
# pode dropar privilegios se necessario
CMD ["crond", "-f", "-l", "2"]
