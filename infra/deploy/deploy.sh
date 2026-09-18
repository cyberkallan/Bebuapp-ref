#!/usr/bin/env bash
# One-command deployment for a single VPS (Ubuntu/Debian with Docker Engine).
#
#   infra/deploy/deploy.sh up       build images, run migrations, start stack
#   infra/deploy/deploy.sh seed     create the first super admin (idempotent)
#   infra/deploy/deploy.sh status   container health + recent logs
#   infra/deploy/deploy.sh logs     follow all logs
#   infra/deploy/deploy.sh down     stop the stack (data volumes are kept)
#   infra/deploy/deploy.sh update   git pull + rebuild + rolling restart
set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
ENV_FILE="$HERE/.env"
COMPOSE=(docker compose -f "$HERE/docker-compose.yml" --env-file "$ENV_FILE")
# Edge mode (shared reverse proxy on the host) adds the override file.
if [[ -f "$ENV_FILE" ]] && grep -qE '^EDGE_NETWORK=.+' "$ENV_FILE"; then
  COMPOSE+=(-f "$HERE/docker-compose.edge.yml")
fi

log() { printf '\033[1;35m[bebu]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[bebu]\033[0m %s\n' "$*" >&2; exit 1; }

require_docker() {
  command -v docker >/dev/null || die "Docker is not installed. See docs/deployment.md."
  docker compose version >/dev/null 2>&1 || die "Docker Compose v2 plugin is missing."
}

random_secret() { openssl rand -base64 48 | tr -d '/+=\n' | cut -c1-"${1:-48}"; }

# Read one KEY=value line from .env without sourcing it (values may contain
# `$`, which compose escapes as `$$`).
env_get() { sed -n "s|^${1}=||p" "$ENV_FILE" | head -n1; }

# Fill empty secrets in .env so a fresh server can boot without manual edits.
ensure_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    cp "$HERE/.env.example" "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    log "Created $ENV_FILE from .env.example — edit DOMAIN and ACME_EMAIL before continuing."
  fi
  local key
  for key in POSTGRES_PASSWORD REDIS_PASSWORD DEV_AUTH_SECRET; do
    if grep -qE "^${key}=\s*$" "$ENV_FILE"; then
      sed -i "s|^${key}=.*|${key}=$(random_secret 48)|" "$ENV_FILE"
      log "Generated ${key}"
    fi
  done
  if grep -qE '^ADMIN_BASIC_AUTH_HASH=\s*$' "$ENV_FILE" && grep -qE '^ADMIN_GUARD=basic-auth' "$ENV_FILE"; then
    local pw hash
    pw="$(random_secret 20)"
    # bcrypt hashes contain `$`; compose .env files need it doubled.
    hash="$(docker run --rm caddy:2-alpine caddy hash-password --plaintext "$pw" | sed 's/\$/$$/g')"
    sed -i "s|^ADMIN_BASIC_AUTH_HASH=.*|ADMIN_BASIC_AUTH_HASH=${hash}|" "$ENV_FILE"
    log "Generated /admin basic-auth password (user from ADMIN_BASIC_AUTH_USER): ${pw}"
    log "Store it now; it is not written anywhere else."
  fi
  DOMAIN="$(env_get DOMAIN)"
  ACME_EMAIL="$(env_get ACME_EMAIL)"
  ADMIN_BASE_PATH="$(env_get ADMIN_BASE_PATH)"
  [[ -n "$DOMAIN" && "$DOMAIN" != "example.com" ]] || die "Set DOMAIN in $ENV_FILE"
  [[ -n "$ACME_EMAIL" && "$ACME_EMAIL" != "you@example.com" ]] || die "Set ACME_EMAIL in $ENV_FILE"
}

cmd_up() {
  require_docker; ensure_env
  log "Building images and starting the stack for https://${DOMAIN}"
  "${COMPOSE[@]}" up -d --build --remove-orphans
  cmd_status
  log "Landing:  https://${DOMAIN}"
  log "API:      https://${DOMAIN}/health"
  log "Console:  https://${DOMAIN}${ADMIN_BASE_PATH:-/admin}"
  if grep -qE '^EDGE_NETWORK=.+' "$ENV_FILE"; then
    log "Edge mode: point the host reverse proxy for ${DOMAIN} at http://bebu-edge:80"
  fi
}

cmd_seed() {
  require_docker; ensure_env
  log "Seeding baseline data (tenant + super admin)"
  "${COMPOSE[@]}" run --rm migrate node_modules/.bin/tsx prisma/seed.ts
}

cmd_status() {
  "${COMPOSE[@]}" ps
}

cmd_logs() { "${COMPOSE[@]}" logs -f --tail=200 "$@"; }
cmd_down() { "${COMPOSE[@]}" down; }

cmd_update() {
  require_docker; ensure_env
  (cd "$ROOT" && git pull --ff-only)
  "${COMPOSE[@]}" build
  "${COMPOSE[@]}" up -d --remove-orphans
  cmd_status
}

case "${1:-}" in
  up) cmd_up ;;
  seed) cmd_seed ;;
  status) cmd_status ;;
  logs) shift; cmd_logs "$@" ;;
  down) cmd_down ;;
  update) cmd_update ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
