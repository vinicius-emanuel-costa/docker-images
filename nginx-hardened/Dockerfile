# ============================================================
# Nginx Hardened — Production-ready with security headers
# ============================================================
# Base: Alpine (minimal ~7MB)
# Features: non-root, security headers, gzip, rate limiting
# ============================================================

FROM nginx:1.27-alpine AS base

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="Nginx hardened com headers de seguranca, non-root, Alpine minimal"

# Remover configs default
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Criar usuario non-root e ajustar permissoes
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup && \
    mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/run && \
    chown -R appuser:appgroup /var/cache/nginx /var/run /etc/nginx/conf.d

# Copiar configs
COPY nginx.conf /etc/nginx/nginx.conf

# Criar pagina padrao minima
RUN echo '<!DOCTYPE html><html><head><title>OK</title></head><body>OK</body></html>' \
    > /usr/share/nginx/html/index.html && \
    chown appuser:appgroup /usr/share/nginx/html/index.html

# Expor porta nao-privilegiada
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

# Rodar como non-root
USER appuser

# Nginx em foreground
CMD ["nginx", "-g", "daemon off;"]
