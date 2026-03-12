# Docker Images — Dockerfiles Otimizados para Producao

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Alpine](https://img.shields.io/badge/Alpine-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

Colecao de Dockerfiles otimizados para producao, demonstrando boas praticas de seguranca, performance e imagens minimas.

---

## Imagens Disponiveis

| Imagem | Base | Tamanho Estimado | Descricao |
|--------|------|:----------------:|-----------|
| **nginx-hardened** | `nginx:1.27-alpine` | ~25 MB | Nginx com headers de seguranca, gzip, rate limiting, non-root |
| **python-app** | `python:3.12-slim` | ~60 MB | Flask + Gunicorn, multi-stage build, non-root |
| **node-app** | `node:22-alpine` | ~50 MB | Express.js, multi-stage com `npm ci`, non-root |
| **go-app** | `scratch` | ~8 MB | Binary estatico Go, imagem minima sem OS |
| **mariadb-backup** | `alpine:3.20` | ~15 MB | Backup automatizado com cron, compressao, upload S3 |
| **monitoring-agent** | `alpine:3.20` | ~25 MB | node_exporter + zabbix-agent + checks customizados |

---

## Boas Praticas Aplicadas

- **Multi-stage builds** — Separacao entre build e runtime, reduzindo tamanho final
- **Usuarios non-root** — Todas as imagens rodam com usuario sem privilegios (`USER`)
- **HEALTHCHECK** — Verificacao de saude nativa do Docker em cada container
- **Imagens minimas** — Alpine, slim, scratch (Go) — sem pacotes desnecessarios
- **Sem secrets na imagem** — Credenciais via variaveis de ambiente, nunca hardcoded
- **Read-only filesystem** — Containers com filesystem somente leitura onde possivel
- **Labels padronizados** — Maintainer, versao, descricao em cada imagem
- **.dockerignore** — Em cada diretorio, evitando copiar arquivos desnecessarios
- **Compressao e cache** — Gzip no Nginx, layer caching otimizado nos Dockerfiles
- **Security headers** — CSP, HSTS, X-Frame-Options no Nginx

---

## Como Buildar e Testar

### Buildar todas as imagens

```bash
docker compose build
```

### Subir todos os containers

```bash
docker compose up -d
```

### Testar endpoints de saude

```bash
# Nginx
curl http://localhost:8080/health

# Python
curl http://localhost:8000/health

# Node.js
curl http://localhost:3000/health

# Go
curl http://localhost:8081/health

# Monitoring (metricas Prometheus)
curl http://localhost:9100/metrics
```

### Buildar uma imagem individual

```bash
docker build -t nginx-hardened ./nginx-hardened
docker build -t python-app ./python-app
docker build -t node-app ./node-app
docker build -t go-app ./go-app
docker build -t mariadb-backup ./mariadb-backup
docker build -t monitoring-agent ./monitoring-agent
```

### Verificar tamanho das imagens

```bash
docker images | grep -E "nginx-hardened|python-app|node-app|go-app|mariadb-backup|monitoring-agent"
```

### Parar e remover

```bash
docker compose down -v
```

---

## Estrutura do Projeto

```
docker-images/
├── docker-compose.yml          # Orquestracao para teste local
├── nginx-hardened/
│   ├── Dockerfile              # Nginx Alpine com security headers
│   ├── nginx.conf              # Config de producao
│   └── .dockerignore
├── python-app/
│   ├── Dockerfile              # Multi-stage Flask + Gunicorn
│   ├── requirements.txt
│   ├── app.py
│   └── .dockerignore
├── node-app/
│   ├── Dockerfile              # Multi-stage Express + Alpine
│   ├── package.json
│   ├── src/server.js
│   └── .dockerignore
├── go-app/
│   ├── Dockerfile              # Multi-stage Go + scratch (~8MB)
│   ├── main.go
│   ├── go.mod
│   └── .dockerignore
├── mariadb-backup/
│   ├── Dockerfile              # Alpine + cron + backup automatizado
│   ├── backup.sh
│   ├── crontab
│   └── .dockerignore
└── monitoring-agent/
    ├── Dockerfile              # node_exporter + zabbix-agent
    ├── entrypoint.sh
    ├── custom-checks/
    │   ├── check_disk_health.sh
    │   └── check_ssl_expiry.sh
    └── .dockerignore
```

---

## Licenca

MIT
