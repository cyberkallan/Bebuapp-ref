#!/usr/bin/env bash
# One-shot local setup: env file, dependencies, infrastructure, schema, seed.
# Safe to re-run; every step is idempotent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

log() { printf '\n\033[1;35m▸ %s\033[0m\n' "$*"; }

command -v pnpm >/dev/null 2>&1 || { echo "pnpm is required (corepack enable && corepack prepare pnpm@latest --activate)"; exit 1; }

if [ ! -f .env ]; then
  log "Creating .env from .env.example"
  cp .env.example .env
fi

log "Installing dependencies"
pnpm install

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  log "Starting Postgres and Redis with Docker Compose"
  pnpm infra:up
  "$ROOT/infra/scripts/wait-for-services.sh"
else
  echo "Docker Compose not found. Make sure Postgres (5432) and Redis (6379) are running locally."
  "$ROOT/infra/scripts/wait-for-services.sh"
fi

log "Applying database migrations"
pnpm db:migrate:deploy

log "Seeding development data"
pnpm db:seed

log "Done. Start everything with: pnpm dev"
