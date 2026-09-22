#!/usr/bin/env bash
# bebu — guided server installer.
#
# Run this once on a fresh Linux server (Ubuntu 22.04/24.04, Debian 12) that
# has Docker installed:
#
#     cd bebu/deploy && ./install.sh
#
# It asks a handful of questions, writes .env, starts MongoDB + backend + admin
# panel + Caddy (automatic HTTPS), seeds starter content and creates your first
# admin account. Safe to re-run: existing answers are offered as defaults.
set -euo pipefail

cd "$(dirname "$0")"

# ── helpers ──────────────────────────────────────────────────────────────────
bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\n\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }
hr()   { printf '\n%s\n' "────────────────────────────────────────────────────────────────"; }

# ask VAR "Question" "default" [secret]
ask() {
  local var="$1" prompt="$2" def="${3:-}" secret="${4:-}" val
  if [ -n "$def" ]; then prompt="$prompt [$def]"; fi
  if [ -n "$secret" ]; then read -r -s -p "  $prompt: " val; echo; else read -r -p "  $prompt: " val; fi
  val="${val:-$def}"
  printf -v "$var" '%s' "$val"
}

yesno() { # yesno "Question" default(y|n)
  local ans def="${2:-n}"
  read -r -p "  $1 [$( [ "$def" = y ] && echo Y/n || echo y/N )]: " ans
  ans="${ans:-$def}"
  [[ "$ans" =~ ^[Yy] ]]
}

rand() { openssl rand -hex "${1:-24}" 2>/dev/null || head -c "${1:-24}" /dev/urandom | od -An -tx1 | tr -d ' \n'; }

# Read a value from an existing .env (used as default when re-running).
envget() { [ -f .env ] && grep -E "^$1=" .env | head -1 | cut -d= -f2- || true; }

# Values from a Firebase web config snippet pasted by the user.
extract() { echo "$1" | tr -d '\n' | grep -oE "$2[\"']?\s*[:=]\s*[\"'][^\"']+[\"']" | head -1 | sed -E "s/.*[\"']([^\"']+)[\"']$/\1/"; }

# ── 0. prerequisites ─────────────────────────────────────────────────────────
clear 2>/dev/null || true
bold "bebu installer"
echo "  Voice & video calling platform — backend, admin panel and database."
hr
bold "Checking this machine"
command -v docker >/dev/null 2>&1 || die "Docker is not installed. Install it first: https://docs.docker.com/engine/install/ (one line: curl -fsSL https://get.docker.com | sh)"
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 is missing (the 'docker compose' command). Update Docker or install the compose plugin."
docker info >/dev/null 2>&1 || die "Docker is installed but not running, or you need sudo. Try: sudo usermod -aG docker \$USER && newgrp docker"
ok "Docker $(docker version --format '{{.Server.Version}}') with Compose $(docker compose version --short)"
command -v openssl >/dev/null 2>&1 && ok "openssl available for secret generation" || warn "openssl missing; using /dev/urandom"

# ── 1. where does it run ─────────────────────────────────────────────────────
hr
bold "1/5  Address"
echo "  The phone app and the admin panel will talk to this address."
echo "  • A domain that already points at this server (DNS A record) → automatic HTTPS."
echo "  • Or the server's IP for a quick trial, e.g. http://203.0.113.10 (plain HTTP)."
ask DOMAIN "Domain or http://IP" "$(envget DOMAIN)"
[ -n "$DOMAIN" ] || die "An address is required."
DOMAIN="${DOMAIN%/}"
if [[ "$DOMAIN" =~ ^https?:// ]]; then
  PUBLIC_URL="$DOMAIN"
  [[ "$DOMAIN" =~ ^http:// ]] && warn "Plain HTTP: fine for testing, use a real domain before launch (Play/App Store require HTTPS)."
else
  PUBLIC_URL="https://$DOMAIN"
fi
ok "Public URL: $PUBLIC_URL"

EDGE_MODE=n
COMPOSE_FILE_VALUE=""
EDGE_NETWORK="$(envget EDGE_NETWORK)"
HTTP_BIND="$(envget HTTP_BIND)"; HTTP_BIND="${HTTP_BIND:-80}"
HTTPS_BIND="$(envget HTTPS_BIND)"; HTTPS_BIND="${HTTPS_BIND:-443}"
if yesno "Advanced: is another web server / reverse proxy already using ports 80 and 443 on this machine?" "$( [ -n "$EDGE_NETWORK" ] && echo y || echo n )"; then
  echo "  Edge mode: bebu will not open public ports. Your existing proxy must forward"
  echo "  $DOMAIN to the container '\${STACK_NAME}-edge' on port 80 over a shared Docker network."
  ask EDGE_NETWORK "Docker network name of that proxy (docker network ls)" "${EDGE_NETWORK:-proxy_default}"
  docker network inspect "$EDGE_NETWORK" >/dev/null 2>&1 || die "Docker network '$EDGE_NETWORK' does not exist."
  EDGE_MODE=y
  COMPOSE_FILE_VALUE="docker-compose.yml:docker-compose.edge.yml"
fi

# ── 2. Firebase ──────────────────────────────────────────────────────────────
hr
bold "2/5  Firebase (sign-in, push notifications)"
echo "  You need one Firebase project (https://console.firebase.google.com) with:"
echo "    a) a Web app → its config snippet (apiKey, authDomain, …)"
echo "    b) Project settings → Service accounts → Generate new private key (a .json file)"
echo "    c) Authentication → Sign-in method: enable Google, Phone, Anonymous (and Email/Password for the admin panel)"
echo
echo "  Paste the Web app config now (the whole 'const firebaseConfig = {...}' block is fine),"
echo "  then press Enter on an empty line. Leave empty to type the values one by one."
SNIPPET=""
while IFS= read -r line; do [ -z "$line" ] && break; SNIPPET+="$line"$'\n'; done
FIREBASE_API_KEY="$(extract "$SNIPPET" apiKey)"
FIREBASE_AUTH_DOMAIN="$(extract "$SNIPPET" authDomain)"
FIREBASE_PROJECT_ID="$(extract "$SNIPPET" projectId)"
FIREBASE_STORAGE_BUCKET="$(extract "$SNIPPET" storageBucket)"
FIREBASE_MESSAGING_SENDER_ID="$(extract "$SNIPPET" messagingSenderId)"
FIREBASE_APP_ID="$(extract "$SNIPPET" appId)"
FIREBASE_MEASUREMENT_ID="$(extract "$SNIPPET" measurementId)"
ask FIREBASE_API_KEY "apiKey" "${FIREBASE_API_KEY:-$(envget FIREBASE_API_KEY)}"
ask FIREBASE_AUTH_DOMAIN "authDomain" "${FIREBASE_AUTH_DOMAIN:-$(envget FIREBASE_AUTH_DOMAIN)}"
ask FIREBASE_PROJECT_ID "projectId" "${FIREBASE_PROJECT_ID:-$(envget FIREBASE_PROJECT_ID)}"
ask FIREBASE_STORAGE_BUCKET "storageBucket" "${FIREBASE_STORAGE_BUCKET:-$(envget FIREBASE_STORAGE_BUCKET)}"
ask FIREBASE_MESSAGING_SENDER_ID "messagingSenderId" "${FIREBASE_MESSAGING_SENDER_ID:-$(envget FIREBASE_MESSAGING_SENDER_ID)}"
ask FIREBASE_APP_ID "appId" "${FIREBASE_APP_ID:-$(envget FIREBASE_APP_ID)}"
ask FIREBASE_MEASUREMENT_ID "measurementId (optional)" "${FIREBASE_MEASUREMENT_ID:-$(envget FIREBASE_MEASUREMENT_ID)}"
[ -n "$FIREBASE_API_KEY" ] && [ -n "$FIREBASE_PROJECT_ID" ] || die "apiKey and projectId are required for the admin panel sign-in."

echo
SA_DEFAULT=""
[ -s firebase-service-account.json ] && grep -q private_key firebase-service-account.json && SA_DEFAULT="firebase-service-account.json"
ask SA_PATH "Path to the service-account .json you downloaded" "$SA_DEFAULT"
[ -n "$SA_PATH" ] || die "The service account is required: the backend verifies logins and sends push notifications with it."
[ -f "$SA_PATH" ] || die "File not found: $SA_PATH"
grep -q '"private_key"' "$SA_PATH" || die "$SA_PATH does not look like a Firebase service-account key."
SA_PROJECT="$(grep -oE '"project_id"\s*:\s*"[^"]+"' "$SA_PATH" | sed -E 's/.*"([^"]+)"$/\1/')"
[ "$SA_PROJECT" = "$FIREBASE_PROJECT_ID" ] || warn "Service account project ($SA_PROJECT) differs from projectId ($FIREBASE_PROJECT_ID). Both must be the same Firebase project."
[ "$SA_PATH" = "firebase-service-account.json" ] || cp "$SA_PATH" firebase-service-account.json
chmod 600 firebase-service-account.json
ok "Service account stored at deploy/firebase-service-account.json"

# ── 3. calls ─────────────────────────────────────────────────────────────────
hr
bold "3/5  Voice & video (ZegoCloud)"
echo "  Free account at https://console.zegocloud.com → create a project → AppID and ServerSecret."
echo "  You can also fill these later in Admin → Settings."
ask ZEGO_APP_ID "Zego AppID (optional)" "$(envget ZEGO_APP_ID)"
ask ZEGO_APP_SIGN "Zego ServerSecret / AppSign (optional)" "$(envget ZEGO_APP_SIGN)" secret

# ── 4. admin ─────────────────────────────────────────────────────────────────
hr
bold "4/5  Your admin account"
ask ADMIN_EMAIL "Admin e-mail" "$(envget INSTALL_ADMIN_EMAIL)"
[[ "$ADMIN_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]] || die "That does not look like an e-mail address."
while :; do
  ask ADMIN_PASSWORD "Admin password (min 8 characters)" "" secret
  [ "${#ADMIN_PASSWORD}" -ge 8 ] && break
  warn "Too short."
done
ask PROJECT_NAME "Brand name shown in the admin panel" "$(envget PROJECT_NAME)"; PROJECT_NAME="${PROJECT_NAME:-bebu}"

# ── 5. write .env ────────────────────────────────────────────────────────────
hr
bold "5/5  Writing configuration"
SECRET_KEY="$(envget SECRET_KEY)"; SECRET_KEY="${SECRET_KEY:-$(rand 24)}"
NEXTAUTH_SECRET="$(envget NEXTAUTH_SECRET)"; NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-$(rand 32)}"
ADMIN_PASSWORD_KEY="$(envget ADMIN_PASSWORD_KEY)"; ADMIN_PASSWORD_KEY="${ADMIN_PASSWORD_KEY:-$(rand 24)}"
STACK_NAME="$(envget STACK_NAME)"; STACK_NAME="${STACK_NAME:-bebu}"
MONGO_DB="$(envget MONGO_DB)"; MONGO_DB="${MONGO_DB:-bebu}"
ENVATO_PERSONAL_TOKEN="$(envget ENVATO_PERSONAL_TOKEN)"
ENVATO_ITEM_ID="$(envget ENVATO_ITEM_ID)"

[ -f .env ] && cp .env ".env.backup.$(date +%Y%m%d%H%M%S)" && ok "Previous .env backed up"
{
  echo "# Generated by install.sh on $(date -u +%Y-%m-%dT%H:%MZ). Keep private."
  echo "DOMAIN=$DOMAIN"
  echo "PUBLIC_URL=$PUBLIC_URL"
  echo "SECRET_KEY=$SECRET_KEY"
  echo "NEXTAUTH_SECRET=$NEXTAUTH_SECRET"
  echo "ADMIN_PASSWORD_KEY=$ADMIN_PASSWORD_KEY"
  echo "FIREBASE_API_KEY=$FIREBASE_API_KEY"
  echo "FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN"
  echo "FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID"
  echo "FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET"
  echo "FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID"
  echo "FIREBASE_APP_ID=$FIREBASE_APP_ID"
  echo "FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID"
  echo "ZEGO_APP_ID=$ZEGO_APP_ID"
  echo "ZEGO_APP_SIGN=$ZEGO_APP_SIGN"
  echo "PROJECT_NAME=$PROJECT_NAME"
  echo "STACK_NAME=$STACK_NAME"
  echo "MONGO_DB=$MONGO_DB"
  echo "ENVATO_PERSONAL_TOKEN=$ENVATO_PERSONAL_TOKEN"
  echo "ENVATO_ITEM_ID=$ENVATO_ITEM_ID"
  echo "HTTP_BIND=$HTTP_BIND"
  echo "HTTPS_BIND=$HTTPS_BIND"
  echo "INSTALL_ADMIN_EMAIL=$ADMIN_EMAIL"
  if [ "$EDGE_MODE" = y ]; then
    echo "COMPOSE_FILE=$COMPOSE_FILE_VALUE"
    echo "EDGE_NETWORK=$EDGE_NETWORK"
  fi
} > .env
chmod 600 .env
ok ".env written"

# ── build & start ────────────────────────────────────────────────────────────
hr
bold "Building and starting (first time takes 3–6 minutes)"
docker compose up -d --build

echo
printf '  Waiting for the backend to be healthy'
for _ in $(seq 1 60); do
  state="$(docker inspect --format '{{.State.Health.Status}}' "${STACK_NAME}-backend" 2>/dev/null || echo starting)"
  if [ "$state" = healthy ]; then echo; ok "Backend healthy"; break; fi
  if [ "$state" = unhealthy ]; then echo; docker compose logs --tail 40 backend; die "Backend failed to start. The log above usually says why (most often the Firebase service account)."; fi
  printf '.'; sleep 5
done
[ "$state" = healthy ] || { echo; docker compose logs --tail 40 backend; die "Backend did not become healthy in time."; }

bold "Seeding starter content (topics, coin plans, FAQs, currencies)"
docker compose exec -T mongo mongosh --quiet "$MONGO_DB" < seed/seed.js | sed 's/^/  /'

bold "Creating the admin account"
docker compose exec -T backend node scripts/create-admin.js "$ADMIN_EMAIL" "$ADMIN_PASSWORD" "Admin" | sed 's/^/  /'

# ── done ─────────────────────────────────────────────────────────────────────
hr
bold "Done."
echo
echo "  Admin panel   $PUBLIC_URL/login"
echo "  Sign in as    $ADMIN_EMAIL"
echo "  API           $PUBLIC_URL/api"
echo
bold "Next: build the mobile app against this server"
echo "  cd ../app"
echo "  flutter build apk --release --split-per-abi \\"
echo "      --dart-define=API_BASE_URL=$PUBLIC_URL/ \\"
echo "      --dart-define=API_SECRET_KEY=$SECRET_KEY"
echo "  (put your Firebase google-services.json in android/app/ first — see docs/INSTALL.md)"
echo
[ "$EDGE_MODE" = y ] && echo "  Edge mode: point your reverse proxy for $DOMAIN at ${STACK_NAME}-edge:80 on network $EDGE_NETWORK." && echo
echo "  Useful commands (run in this folder):"
echo "    docker compose ps                      status"
echo "    docker compose logs -f backend         live backend log"
echo "    docker compose up -d --build           rebuild after changing code"
echo "    docker compose exec backend node scripts/create-admin.js you@example.com 'NewPass'   add/reset an admin"
echo
