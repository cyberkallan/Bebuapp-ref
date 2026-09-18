# Test builds

Signed Android release builds of the bebu user app, produced from this
repository for hands-on testing. These are **not** store builds: they are signed
with a throwaway test key, allow plain-HTTP so they can talk to a development
API on your LAN, and contain only the foundation-stage screens.

| File                                      | Devices                                  | Size  |
| ----------------------------------------- | ---------------------------------------- | ----- |
| `bebu-0.1.2-foundation-arm64-v8a.apk`     | Practically every phone from ~2016 on    | 18 MB |
| `bebu-0.1.2-foundation-armeabi-v7a.apk`   | Older 32-bit devices                     | 16 MB |

Checksums are in `SHA256SUMS.txt`.

## Installing

1. Download the arm64 APK to the phone (or `adb install <file>.apk`).
2. Allow "install from unknown sources" for your browser/file manager when
   Android asks; the app is not from the Play Store.
3. Open **bebu**.

## First launch

`0.1.2` is built against the staging server
(`https://145.223.79.74.sslip.io`), so it connects on first open with nothing
to configure. You can still point it elsewhere: tap the server icon in the app
bar (or **Change server address** on the loading/error screen), enter another
URL, and the app remembers it.

History: `0.1.0` had only the Android emulator's host alias built in (which a
real phone cannot reach) and appeared to load forever; `0.1.1` added the
**Choose a server** screen; `0.1.2` ships with the staging address.

## What you can test in this build

- The app boots straight into the staging tenant, shows a clear connection
  error (with a "Change server address" action) if the API cannot be reached,
  and offers the same action from the loading screen after 2 seconds.
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

- **A hosted API** (the staging VPS above, or any other deployment of
  `infra/deploy`): enter the `https://` URL as-is.
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
flutter build apk --release --split-per-abi \
  --dart-define=TENANT_KEY=bebu \
  --dart-define=API_BASE_URL=https://145.223.79.74.sslip.io
```

Swap `API_BASE_URL` for the production domain when the API moves.

Signing uses `apps/mobile/android/key.properties`; see
`apps/mobile/README.md` → Release signing.
