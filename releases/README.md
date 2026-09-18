# Test builds

Signed Android release builds of the bebu user app, produced from this
repository for hands-on testing. These are **not** store builds: they are signed
with a throwaway test key, allow plain-HTTP so they can talk to a development
API on your LAN, and contain only the foundation-stage screens.

| File                                      | Devices                                  | Size  |
| ----------------------------------------- | ---------------------------------------- | ----- |
| `bebu-0.1.1-foundation-arm64-v8a.apk`     | Practically every phone from ~2016 on    | 18 MB |
| `bebu-0.1.1-foundation-armeabi-v7a.apk`   | Older 32-bit devices                     | 16 MB |

Checksums are in `SHA256SUMS.txt`.

## Installing

1. Download the arm64 APK to the phone (or `adb install <file>.apk`).
2. Allow "install from unknown sources" for your browser/file manager when
   Android asks; the app is not from the Play Store.
3. Open **bebu**.

## First launch

These test builds have **no server address built in** (the compile-time default
is the Android emulator's host alias, which a real phone cannot reach). On a
phone the app therefore opens on a **Choose a server** screen. Tap **Set server
address**, enter the URL of a running bebu API (see below), and the app
connects and remembers the address. `0.1.0` lacked this screen and appeared to
load forever on a real device; `0.1.1` fixes that.

## What you can test in this build

- The app boots, asks for a server address on first launch, shows a clear
  connection error (with a "Change server address" action) if the API cannot be
  reached, and offers the same action from the loading screen after 2 seconds.
- Once connected it loads the tenant's public configuration
  (`GET /api/v1/tenant/config`): name, brand colours, currency, feature flags.
  The theme, app bar title and avatar come from that response, so changing the
  tenant's branding in the database and tapping the server icon → "Save and
  reconnect" re-skins the app without a rebuild.
- The server address is remembered across restarts; "Reset to default" clears
  it.

Sign-in, caller discovery, calling, wallet and purchases are later stages and
are not in this build.

## Pointing the app at an API

The phone must be able to reach the API over the network. Any of these work:

- **A hosted API** (staging VPS, or a temporary tunnel URL such as
  `https://<something>.trycloudflare.com` provided for a test session): enter
  the `https://` URL as-is.
- **Your computer on the same Wi‑Fi:**

```bash
# on your computer, in this repository
./infra/scripts/bootstrap.sh     # once
pnpm dev:api                     # listens on 0.0.0.0:4180
```

Find your computer's LAN IP (`ipconfig` / `ip addr`), make sure the phone is
on the same Wi-Fi and port 4180 is allowed through the firewall, then in the
app tap **Change server address** and enter `http://<your-ip>:4180`.

## Rebuilding

```bash
cd apps/mobile
flutter build apk --release --split-per-abi --dart-define=TENANT_KEY=bebu
```

Signing uses `apps/mobile/android/key.properties`; see
`apps/mobile/README.md` → Release signing.
