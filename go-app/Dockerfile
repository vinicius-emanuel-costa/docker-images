# ============================================================
# Go App — Multi-stage com binary estatico + scratch
# ============================================================
# Stage 1: Build static binary
# Stage 2: scratch (0MB base) — imagem final ~8MB
# ============================================================

# ---- Stage 1: Builder ----
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache ca-certificates

WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY main.go ./

# Build estatico sem CGO
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /app main.go

# ---- Stage 2: Scratch (imagem minima) ----
FROM scratch

LABEL maintainer="Vinicius Costa <vinicius-costa14@github.com>"
LABEL version="1.0"
LABEL description="Go HTTP server — binary estatico em scratch, imagem ~8MB"

# Certificados SSL para requests HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Criar usuario non-root via /etc/passwd
COPY --from=builder /etc/passwd /etc/passwd

# Copiar binary
COPY --from=builder /app /app

EXPOSE 8080

# Health check nao disponivel em scratch (sem shell)
# Use Docker/orchestrator health checks externos

USER nobody

ENTRYPOINT ["/app"]
