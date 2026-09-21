# Test builds

Signed Android release builds of the bebu app, produced from `talkin/app` in
this repository.

| File                             | Devices                               | Size  |
| -------------------------------- | ------------------------------------- | ----- |
| `bebu-1.5.0-arm64-v8a.apk`       | Practically every phone from ~2017 on | 92 MB |
| `bebu-1.5.0-armeabi-v7a.apk`     | Older 32-bit devices                  | 85 MB |

Checksums are in `SHA256SUMS.txt`; release notes shown on the website come from
`notes.json`.

## What this build is

`1.5.0` rebuilds My wallet: balance hero framed as talk time, coin-pack grid
with Most popular / Best value / Save % cues, docked checkout button, themed
payment sheet, recent activity, and a coin-burst celebration screen after
every successful purchase. Installs over `1.4.0`.

`1.4.0` adds a light theme with a System / Dark / Light picker on My profile
and in onboarding, rebuilds My profile and the Calls tab on the design system,
and puts the look under admin control (default theme, user choice, accent,
corners, motion, effects). Installs over `1.3.x`.

`1.3.1` polishes the Home header (aligned For You / Live pill, animated coin
balance), adds ringing call buttons for live callers on Explore and the deck,
and makes the Explore grid cheaper to render. Installs over `1.3.0`.

`1.3.0` completes the dark redesign: random match radar, chat list, one-to-one
chat, welcome splash and first-run onboarding. It installs over `1.1.0`/`1.2.0`
(same package and signing key).

`1.2.0` added the dark, photo-first UI: a swipeable caller deck on Home, an
Explore photo grid with filters, richer caller profiles and a floating
navigation bar.

`1.1.0` was the first full bebu app built on the proven Talkin engine: quick login,
caller discovery, voice and video calls (ZegoCloud), chat, coins, purchases and
the caller ("host") flow. It talks to bebu's own backend at
`https://bebu.145.223.79.74.sslip.io` (see `talkin/deploy`).

Earlier `0.1.x` builds were the ground-up foundation app and are superseded;
uninstall them before installing this one (different package and signing key).

## Installing

1. Download the arm64 APK to the phone, or `adb install <file>.apk`.
2. Allow "install from unknown sources" when Android asks.
3. Open **bebu**, accept the privacy policy and tap **Quick login**.

Requires Android 6.0 (API 23) or newer.

## Rebuilding

```bash
cd talkin/app
flutter pub get
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=https://bebu.145.223.79.74.sslip.io/ \
  --dart-define=API_SECRET_KEY=<SECRET_KEY from talkin/deploy/.env>
```

Both defines have defaults matching the staging server, so plain
`flutter build apk --release --split-per-abi` also works. Release signing uses
`talkin/app/android/key.properties` (git-ignored); without it the build falls
back to the debug key.
