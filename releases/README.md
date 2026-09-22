# Test builds

Signed Android release builds of the bebu app, produced from `talkin/app` in
this repository.

| File                             | Devices                               | Size  |
| -------------------------------- | ------------------------------------- | ----- |
| `bebu-1.6.3-arm64-v8a.apk`       | Practically every phone from ~2017 on | 93 MB |
| `bebu-1.6.3-armeabi-v7a.apk`     | Older 32-bit devices                  | 86 MB |

Checksums are in `SHA256SUMS.txt`; release notes shown on the website come from
`notes.json`.

## What this build is

`1.6.3` ships the new bebu logo: the pink B with a face profile and heart is the
launcher icon (adaptive icon on a deep-plum plate, iOS icon set regenerated),
the splash mark, the monochrome notification icon and the brand on the
website, download page and admin panel. No functional changes. Installs over
`1.6.2`.

`1.6.2` redesigns Random match: a layered proximity radar over a faint city
map with hosts drifting on the rings, a tappable black/white core that starts
the match, Audio / Video chips and a live-count pill — tuned for both the dark
and light themes. The match preview is a full-bleed portrait card (Online now
pill, rate, rating, calls, languages, topics, minutes your balance covers)
with a Skip action. The flat green online dot is replaced app-wide by a
presence badge (glow, breathing halo, amber for busy). Installs over `1.6.1`.

`1.6.1` fixes chat: messages typed while the socket was reconnecting were
shown as sent but never left the phone, Malayalam / emoji text was stripped to
nothing, and the first long-press on the mic only asked for permission and
never recorded. Messages are now queued and delivered, show clock → tick → blue
ticks (or *Not sent · tap to retry*), voice notes record on the first hold with
slide-to-cancel and a live level meter, and there are WhatsApp-style tones and
haptics (admin can turn both off; users can mute tones). Installs over `1.6.0`.

`1.6.0` adds Avatar Studio: a 3D look (avatar, scene, pet, ride, home, sky,
accessory) built on a tilting diorama stage, with free items equipped
instantly and premium items unlocked for coins; try-on, unlock celebration,
sound and haptics. My profile is rebuilt around it (3D hero or photo,
completeness checklist) and the layout crash that left the page broken is
fixed. Edit profile and Settings are themed and Edit profile no longer loses or
prematurely saves fields. The admin gets a Settings → Avatar Studio tab with an
on/off switch and catalog management. Installs over `1.5.x`.

`1.5.2` swaps the flat coin PNG for a vector 3D coin (edge, bevel, embossed
star, specular sweep, slow breathing + one eased turn per cycle) used across
the app, turns the wallet coin packs into full-width comparison rows with
coin piles, rebuilds the audio/video chooser sheet, the coin/payment history
screen and all confirmation dialogs on the design system. Installs over
`1.5.1`.

`1.5.1` fixes the Home deck call flow: the chosen host's card now stays on
screen (lift, 3D tilt, light sweep, accent ring, chime + haptics) under the
audio/video chooser instead of flying off and exposing the next host. Adds an
admin *Sound effects* toggle. Installs over `1.5.0`.

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
