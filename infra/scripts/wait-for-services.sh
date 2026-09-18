#!/usr/bin/env bash
# Blocks until Postgres and Redis accept connections (or times out).
# Reads DATABASE_URL / REDIS_URL from the environment or the root .env file.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ -f "$ROOT/.env" ]; then
  # shellcheck disable=SC1091
  set -a; source "$ROOT/.env"; set +a
fi

DATABASE_URL="${DATABASE_URL:-postgresql://bebu:bebu@127.0.0.1:5432/bebu}"
REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379/0}"
TIMEOUT="${WAIT_TIMEOUT_SECONDS:-60}"

host_port() {
  # postgresql://user:pass@host:port/db?x=y -> "host port"
  local rest="${1#*://}"
  rest="${rest##*@}"
  rest="${rest%%/*}"
  rest="${rest%%\?*}"
  printf '%s %s\n' "${rest%%:*}" "${rest##*:}"
}

wait_for() {
  local name="$1" host="$2" port="$3" waited=0
  until (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; do
    if [ "$waited" -ge "$TIMEOUT" ]; then
      echo "timed out waiting for $name at $host:$port" >&2
      exit 1
    fi
    sleep 1; waited=$((waited + 1))
  done
  echo "$name is accepting connections at $host:$port"
}

read -r PG_HOST PG_PORT <<<"$(host_port "$DATABASE_URL")"
read -r REDIS_HOST REDIS_PORT <<<"$(host_port "$REDIS_URL")"

wait_for "postgres" "$PG_HOST" "$PG_PORT"
wait_for "redis" "$REDIS_HOST" "$REDIS_PORT"
