# ============================================================
# Node.js App — Multi-stage Express production build
# ============================================================
# Stage 1: Install deps with npm ci (reproducible)
# Stage 2: Alpine runtime (~50MB)
# ============================================================

# ---- Stage 1: Builder ----
FROM node:22-alpine AS builder

WORKDIR /build

COPY package.json package-lock.json* ./

RUN npm ci --only=production && \
    npm cache clean --force

# ---- Stage 2: Runtime ----
FROM node:22-alpine AS runtime

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="Node.js Express app com multi-stage, Alpine, non-root"

# Instalar apenas curl para healthcheck
RUN apk add --no-cache curl

# Criar usuario non-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copiar node_modules do builder
COPY --from=builder --chown=appuser:appgroup /build/node_modules ./node_modules
COPY --chown=appuser:appgroup package.json ./
COPY --chown=appuser:appgroup src/ ./src/

# Variavel de ambiente para producao
ENV NODE_ENV=production

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Non-root
USER appuser

CMD ["node", "src/server.js"]
