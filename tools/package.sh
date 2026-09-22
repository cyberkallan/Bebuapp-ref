#!/usr/bin/env bash
# Build the two distributable bundles of bebu.
#
#   tools/package.sh [--prod-env deploy.env] [--prod-sa firebase-service-account.json]
#
# Outputs in dist/:
#   bebu-production-<version>.zip   everything as deployed: source with our keys and
#                                   configuration, signed APKs + AAB, iOS config, docs.
#                                   For our own backups / server migration. PRIVATE.
#   bebu-codecanyon-<version>.zip   same product with every private key, credential,
#                                   keystore and environment-specific value removed,
#                                   plus INSTALL.md and the guided installer. Safe to
#                                   sell or hand to another developer.
#   SHA256SUMS.txt, manifest.json   for the admin Downloads page.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROD_ENV=""
PROD_SA=""
while [ $# -gt 0 ]; do
  case "$1" in
    --prod-env) PROD_ENV="$2"; shift 2 ;;
    --prod-sa) PROD_SA="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done

VERSION="$(grep -E '^version:' bebu/app/pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"
STAMP="$(date -u +%Y-%m-%d)"
DIST="$ROOT/dist"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$DIST"

say() { printf '\033[1m▸ %s\033[0m\n' "$*"; }

# rsync filters shared by both bundles: never ship build output or dependencies.
COMMON_EXCLUDES=(
  --exclude node_modules --exclude .next --exclude '.dart_tool' --exclude 'app/build'
  --exclude '.git' --exclude '*.log' --exclude '.DS_Store' --exclude 'ios/Pods'
  --exclude 'ios/.symlinks' --exclude 'ios/Flutter/ephemeral' --exclude '.idea'
  --exclude 'test/**/failures' --exclude 'deploy/.env.backup.*' --exclude '.gradle'
  --exclude 'android/local.properties' --exclude 'ios/Flutter/Generated.xcconfig'
  --exclude 'ios/Flutter/flutter_export_environment.sh' --exclude '.flutter-plugins*'
  --exclude '__pycache__' --exclude '.pytest_cache'
)

copy_common() { # $1 = destination root
  local dest="$1"
  mkdir -p "$dest"
  rsync -a "${COMMON_EXCLUDES[@]}" bebu/ "$dest/bebu/"
  rsync -a --exclude node_modules --exclude dist --exclude 'public/downloads' apps/landing/ "$dest/landing/"
  mkdir -p "$dest/docs"
  cp docs/admin-guide.md docs/ios-release.md docs/play-store.md docs/ai-chat.md docs/appearance.md \
     docs/avatar-studio.md docs/login-rewards.md "$dest/docs/"
  cp bebu/INSTALL.md "$dest/INSTALL.md"
  cp .github/workflows/ios-release.yml "$dest/bebu/.github-workflow-ios-release.yml"
  cp releases/notes.json "$dest/docs/release-notes.json"
}

# ── production bundle ────────────────────────────────────────────────────────
say "Production bundle"
P="$WORK/bebu-production-$VERSION"
copy_common "$P"
cp docs/go-live.md docs/deployment.md docs/architecture.md docs/development.md docs/security.md "$P/docs/"
mkdir -p "$P/releases"
cp releases/bebu-"$VERSION"-*.apk releases/bebu-"$VERSION".aab releases/SHA256SUMS.txt releases/README.md "$P/releases/"
[ -n "$PROD_ENV" ] && cp "$PROD_ENV" "$P/bebu/deploy/.env" && chmod 600 "$P/bebu/deploy/.env"
[ -n "$PROD_SA" ] && cp "$PROD_SA" "$P/bebu/deploy/firebase-service-account.json"
cp bebu/app/android/key.properties "$P/bebu/app/android/key.properties" 2>/dev/null || true
cat > "$P/README.md" <<EOF
# bebu $VERSION — production bundle ($STAMP)

PRIVATE. This archive contains live credentials: the Firebase service account,
the Android upload keystore and its passwords, the API secret and the
environment file of the production server. Store it encrypted and never share
it or upload it to a marketplace — use the *codecanyon* bundle for that.

| Path                                          | What                                                              |
| --------------------------------------------- | ----------------------------------------------------------------- |
| \`bebu/app\`                                    | Flutter app, package/bundle id \`in.bebuapp.app\`, Firebase project as configured (google-services.json + GoogleService-Info.plist) |
| \`bebu/app/android/bebu-release.jks\` + \`key.properties\` | Play upload key. Loss = you cannot update the app. Back up separately. |
| \`bebu/backend\`, \`bebu/admin\`                  | API and admin panel source                                        |
| \`bebu/deploy/.env\`                            | Live server configuration (secrets, Firebase web config, stack name) |
| \`bebu/deploy/firebase-service-account.json\`   | Firebase Admin credential used by the backend                     |
| \`releases/\`                                   | Signed APKs (arm64-v8a, armeabi-v7a), Play Store \`.aab\`, checksums |
| \`landing/\`                                    | Marketing site + APK download page (Vite)                         |
| \`docs/\`                                       | Admin guide, iOS + Play Store guides, feature docs, go-live notes  |
| \`INSTALL.md\`                                  | Fresh-server installation                                         |

## Migrate the server to a new machine

1. On the new server: install Docker, copy \`bebu/\` to \`/opt/bebuapp\`.
2. \`cd /opt/bebuapp/deploy\` — \`.env\` and \`firebase-service-account.json\` are already there. Edit \`DOMAIN\`/\`PUBLIC_URL\` if the address changes.
   Remove the \`COMPOSE_FILE\`/\`EDGE_NETWORK\` lines unless the new host also has a shared reverse proxy.
3. Old server: \`docker exec bebuapp-mongo mongodump --archive --db bebu > bebu.archive\` and
   \`docker run --rm -v bebuapp_backend-storage:/s alpine tar czf - -C /s . > storage.tgz\`; copy both over.
4. New server: \`docker compose up -d mongo\`, then
   \`docker exec -i bebuapp-mongo mongorestore --archive --drop < bebu.archive\`,
   \`docker compose create backend\`, \`docker run --rm -i -v bebuapp_backend-storage:/s alpine tar xzf - -C /s < storage.tgz\`,
   \`docker compose up -d --build\`.
5. Point DNS at the new IP. The app keeps working because \`SECRET_KEY\` and the domain are unchanged.

Rebuild the app against this server: see INSTALL.md §3.3 (\`API_BASE_URL\` / \`API_SECRET_KEY\` come from \`deploy/.env\`).
EOF

# ── marketplace bundle (no keys) ─────────────────────────────────────────────
say "Marketplace bundle (sanitised)"
C="$WORK/bebu-codecanyon-$VERSION"
copy_common "$C"

# 1. drop every credential file
rm -f "$C/bebu/deploy/.env" "$C/bebu/deploy/firebase-service-account.json"
rm -f "$C/bebu/app/android/key.properties" "$C"/bebu/app/android/*.jks "$C"/bebu/app/android/app/*.jks
rm -f "$C/bebu/app/android/app/google-services.json" "$C/bebu/app/ios/Runner/GoogleService-Info.plist"
rm -f "$C/bebu/backend/.env" "$C/bebu/admin/.env" "$C/bebu/admin/.env.local"
find "$C" -name '*.pem' -o -name '*.p12' -o -name '*.p8' -o -name '*.keystore' | xargs -r rm -f

# 2. placeholders the buyer replaces
cat > "$C/bebu/app/android/app/google-services.json.example" <<'EOF'
{
  "_comment": "Replace this file with google-services.json downloaded from Firebase console → Project settings → Your apps → Android (package in.bebuapp.app or your own).",
  "project_info": { "project_number": "000000000000", "project_id": "your-firebase-project", "storage_bucket": "your-firebase-project.appspot.com" },
  "client": [ { "client_info": { "mobilesdk_app_id": "1:000000000000:android:0000000000000000", "android_client_info": { "package_name": "in.bebuapp.app" } },
    "oauth_client": [], "api_key": [ { "current_key": "YOUR_ANDROID_API_KEY" } ],
    "services": { "appinvite_service": { "other_platform_oauth_client": [] } } } ],
  "configuration_version": "1"
}
EOF
cat > "$C/bebu/app/ios/Runner/GoogleService-Info.plist.example" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- Replace with GoogleService-Info.plist from Firebase console → Project settings → Your apps → iOS. -->
<plist version="1.0"><dict>
	<key>BUNDLE_ID</key><string>in.bebuapp.app</string>
	<key>PROJECT_ID</key><string>your-firebase-project</string>
	<key>GOOGLE_APP_ID</key><string>1:000000000000:ios:0000000000000000</string>
	<key>API_KEY</key><string>YOUR_IOS_API_KEY</string>
	<key>GCM_SENDER_ID</key><string>000000000000</string>
	<key>CLIENT_ID</key><string>000000000000-xxxx.apps.googleusercontent.com</string>
	<key>REVERSED_CLIENT_ID</key><string>com.googleusercontent.apps.000000000000-xxxx</string>
	<key>IS_ADS_ENABLED</key><false/><key>IS_ANALYTICS_ENABLED</key><false/><key>IS_APPINVITE_ENABLED</key><true/>
	<key>IS_GCM_ENABLED</key><true/><key>IS_SIGNIN_ENABLED</key><true/><key>PLIST_VERSION</key><string>1</string>
</dict></plist>
EOF

# 3. environment-specific values → placeholders (app defaults, docs, iOS URL scheme)
python3 - "$C" <<'PY'
import os, re, sys
root = sys.argv[1]
subs = [
    (r"defaultValue: 'https://[^']+/'", "defaultValue: 'https://api.yourapp.com/'"),
    (r"defaultValue: '[0-9a-f]{48}'", "defaultValue: 'CHANGE_ME_TO_SECRET_KEY_FROM_DEPLOY_ENV'"),
    (r"com\.googleusercontent\.apps\.\d+-[a-z0-9]+", "com.googleusercontent.apps.000000000000-xxxx"),
    (r"https://bebu\.145\.223\.79\.74\.sslip\.io", "https://api.yourapp.com"),
    (r"145\.223\.79\.74", "SERVER-IP"),
    (r"neocat-ceae7", "your-firebase-project"),
    (r"582954571557", "000000000000"),
    (r"api\.bebuapp\.in", "api.yourapp.com"),
    (r"ayushaura\.in", "yourapp.com"),
    (r"1:000000000000:ios:[0-9a-f]+", "1:000000000000:ios:0000000000000000"),
]
exts = {'.dart', '.md', '.plist', '.yml', '.yaml', '.js', '.mjs', '.jsx', '.json', '.html', '.ts', '.tsx', '.sh', '.example', '.txt', '.gradle', '.xml', '.kts'}
changed = 0
for dp, dn, fn in os.walk(root):
    for f in fn:
        p = os.path.join(dp, f)
        if os.path.splitext(f)[1] not in exts and not f.endswith('.env.example'):
            continue
        try:
            s = open(p, encoding='utf-8').read()
        except (UnicodeDecodeError, OSError):
            continue
        t = s
        for pat, rep in subs:
            t = re.sub(pat, rep, t)
        if t != s:
            open(p, 'w', encoding='utf-8').write(t); changed += 1
print(f"  placeholders applied in {changed} files")
PY

# 4. buyer-facing README + licence note
cat > "$C/README.md" <<EOF
# bebu $VERSION — voice & video calling platform with coin wallet

Complete source code of **bebu**: a 1-to-1 voice and video calling marketplace
where users buy coins and spend them per minute talking to hosts, send 3D
gifts, unlock avatar items and come back for daily rewards. Hosts apply in the
app, get verified by you, earn a share of every call and request payouts.

| Part           | Tech                                        | Folder          |
| -------------- | ------------------------------------------- | --------------- |
| Mobile app     | Flutter 3 (Android + iOS), Firebase Auth, ZegoCloud calls | \`bebu/app\`     |
| Backend API    | Node.js 22, Express 5, Socket.IO, MongoDB 7 | \`bebu/backend\` |
| Admin panel    | Next.js 15, MUI                             | \`bebu/admin\`   |
| Server stack   | Docker Compose + Caddy (automatic HTTPS) + guided \`install.sh\` | \`bebu/deploy\` |
| Landing page   | Vite static site with APK download page     | \`landing/\`     |

## Start here

1. **\`INSTALL.md\`** — server in one command, Firebase setup, building the app. Written for a first-time developer.
2. **\`docs/admin-guide.md\`** — every admin page, step by step.
3. **\`docs/play-store.md\`** and **\`docs/ios-release.md\`** — publishing.
4. Feature deep-dives: \`docs/ai-chat.md\`, \`docs/login-rewards.md\`, \`docs/appearance.md\`, \`docs/avatar-studio.md\`.

## What you must provide

This package intentionally contains **no keys**. You create your own (all
free to start): a Firebase project, a ZegoCloud project, a payment gateway
account, an Android signing key. \`install.sh\` asks for them.

Files you replace: \`bebu/app/android/app/google-services.json\` and
\`bebu/app/ios/Runner/GoogleService-Info.plist\` (\`.example\` versions show the
shape), \`bebu/app/android/key.properties\` (from \`key.properties.example\`).

## Features

- Sign-in: Google, phone OTP, one-tap guest, e-mail — admin chooses which and which is primary
- Welcome bonus and 7-day daily streak rewards, all coin values set in the admin panel
- Private and random 1-to-1 audio/video calls billed per minute, rates per host
- Real-time chat with photos, voice notes, WhatsApp-style tones and haptics
- 10 bundled 3D gifts with cinematic send animation; admin catalog, host share %, on/off
- Avatar Studio: 3D avatars, backgrounds, pets, rides unlockable with coins
- AI replies for showcase ("fake") hosts in English, Hindi, Malayalam, Tamil, Telugu, Kannada and Manglish/Hinglish
- Coin packs via Razorpay, Stripe, Flutterwave or Google Play Billing
- Host onboarding with ID verification, earnings, payout requests
- Dark and light themes with admin-set accent; landing page with APK download
- Admin: dashboard, users, hosts, coin plans, gifts, rewards, AI chat, appearance, payments, payouts, FAQ, downloads

## Requirements

Server: any Linux VPS with Docker (2 GB RAM). Build machine: Flutter 3.27+,
Android Studio / Xcode for iOS. Third-party services: Firebase, ZegoCloud, one
payment gateway.

## Support & licence

Sold under the marketplace licence you purchased it with; one licence per end
product. Third-party assets: gift and avatar renders are Microsoft Fluent
Emoji 3D (MIT); UI icons are Tabler Icons (MIT); fonts are Inter (OFL).
EOF

# 5. safety scan: fail loudly if anything secret-looking survived
say "Scanning marketplace bundle for secrets"
if grep -rIl -E "BEGIN (RSA |EC )?PRIVATE KEY|AIza[0-9A-Za-z_-]{30,}|sk_live_|rzp_live_|Teamlogs|neocat-ceae7|145\.223\.79\.74|de0c55bcc70dbbfdc7c728101da4a786076d95ebc4ab5934" "$C" --exclude-dir=node_modules | grep -v "package-lock.json" ; then
  echo "✖ secrets found in the marketplace bundle — aborting" >&2; exit 1
fi
for f in bebu/deploy/.env bebu/deploy/firebase-service-account.json bebu/app/android/key.properties bebu/app/android/bebu-release.jks bebu/app/android/app/google-services.json bebu/app/ios/Runner/GoogleService-Info.plist; do
  [ -e "$C/$f" ] && { echo "✖ $f must not be in the marketplace bundle" >&2; exit 1; }
done
echo "  clean"

# ── zip ──────────────────────────────────────────────────────────────────────
say "Zipping"
rm -f "$DIST/bebu-production-$VERSION.zip" "$DIST/bebu-codecanyon-$VERSION.zip"
(cd "$WORK" && zip -qr -9 "$DIST/bebu-production-$VERSION.zip" "bebu-production-$VERSION")
(cd "$WORK" && zip -qr -9 "$DIST/bebu-codecanyon-$VERSION.zip" "bebu-codecanyon-$VERSION")
cp releases/bebu-"$VERSION"-*.apk releases/bebu-"$VERSION".aab "$DIST/"
(cd "$DIST" && sha256sum *.zip *.apk *.aab > SHA256SUMS.txt)

cat > "$DIST/manifest.json" <<EOF
{
  "bebu-production-$VERSION.zip": {
    "title": "bebu $VERSION — production source (with keys)",
    "group": "Source code",
    "description": "Complete project as deployed: app, backend, admin, deploy/.env, Firebase service account, Android keystore, APK/AAB, docs. Private — for backup and server migration."
  },
  "bebu-codecanyon-$VERSION.zip": {
    "title": "bebu $VERSION — marketplace package (no keys)",
    "group": "Marketplace package",
    "description": "Same product with every credential removed, placeholder config files, guided install.sh and INSTALL.md. Safe to sell or hand to a developer."
  },
  "bebu-$VERSION.aab": {
    "title": "Android App Bundle $VERSION",
    "group": "Mobile builds",
    "description": "Upload this file in Google Play Console → Production → Create release."
  },
  "bebu-$VERSION-arm64-v8a.apk": {
    "title": "Android APK $VERSION (arm64-v8a)",
    "group": "Mobile builds",
    "description": "Signed APK for modern 64-bit phones — side-load or host on your website."
  },
  "bebu-$VERSION-armeabi-v7a.apk": {
    "title": "Android APK $VERSION (armeabi-v7a)",
    "group": "Mobile builds",
    "description": "Signed APK for older 32-bit phones."
  }
}
EOF
ls -la "$DIST"
say "Done → $DIST"
