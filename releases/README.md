# Test builds

Signed Android release builds of the bebu user app, produced from this
repository for hands-on testing. These are **not** store builds: they are signed
with a throwaway test key, allow plain-HTTP so they can talk to a development
API on your LAN, and contain only the foundation-stage screens.

| File                                      | Devices                                  | Size  |
| ----------------------------------------- | ---------------------------------------- | ----- |
| `bebu-0.1.0-foundation-arm64-v8a.apk`     | Practically every phone from ~2016 on    | 18 MB |
| `bebu-0.1.0-foundation-armeabi-v7a.apk`   | Older 32-bit devices                     | 16 MB |

Checksums are in `SHA256SUMS.txt`.

## Installing

1. Download the arm64 APK to the phone (or `adb install <file>.apk`).
2. Allow "install from unknown sources" for your browser/file manager when
   Android asks; the app is not from the Play Store.
3. Open **bebu**.

## What you can test in this build

- The app boots, shows a connection error until it can reach an API, and lets
  you set the server address from the error screen.
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

The phone must be able to reach the API over the network. For a local test:

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
