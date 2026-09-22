# Project history

Chronological record of how bebu was built. Pair this with
[`AI-GUIDE.md`](AI-GUIDE.md) (how to change the code) and
[`admin-guide.md`](admin-guide.md) (how to operate it).

Dates are 2026-09-18 → 2026-09-22 unless noted. The product started as a
Talkin / CodeCanyon-style reference and was upgraded in place, then fully
rebranded to **bebu by Elevanza Ltd**.

## Origin

The user asked for a production-grade multi-tenant SaaS for 1-to-1 voice and
video calling with coin billing (bebuapp.in), using a **reference application
rather than a greenfield rewrite**.

Two trees were created:

1. **`apps/` + `packages/` + `infra/`** — a NestJS / Prisma / Postgres
   “platform foundation” (tenant isolation, ledger, call state machine).
   Architecture docs describe this stack. **It is not what users run.**
2. **`bebu/` (first named `talkin/`)** — the reference app, edited and
   upgraded until it became the shipping product. Flutter + Express/Mongo +
   Next.js admin. **This is the product.**

APKs in `releases/` and the VPS (`bebu.145.223.79.74.sslip.io`) are always
built from `bebu/`.

The GitHub repo `cyberkallan/Bebuapp-ref` originally held three vendor zips
(`talkin.zip`, `admin.zip`, `Documentation.zip`). This git history replaces
those uploads with the full working tree.

## Version timeline (shipping app)

| Version | What shipped |
| ------- | ------------ |
| 1.1.0 | First bebu-branded APK from the Talkin-based app. Landing + download page. Docs for deploy and first admin. |
| 1.2.0 | Dark, photo-first UI: home, explore, profile. Card deck, floating nav. |
| 1.3.0 | Same language on random match, chat list, personal chat, splash, onboarding. |
| 1.3.1 | Header alignment, animated coin pill, ringing call buttons, lighter grids. |
| 1.4.0 | Dark/light engine (`Appearance` + `BebuTheme`). Admin appearance: default theme, user choice, accent, motion, corners, glow, SFX, haptics. Themed profile + call history. Onboarding theme step. |
| 1.5.0 | Wallet redesign: talk-time framing, pack ribbons, sticky checkout, coin-burst purchase celebration. |
| 1.5.1 | Host-card “choose call” stay-on-screen animation (tilt, sweep, chime). |
| 1.5.2 | Vector 3D coin painter, wallet rows, themed chooser / history / dialogs. |
| 1.6.0 | **Avatar Studio**: 3D diorama, categories, rarity, coin unlocks, presets. Admin catalog CRUD. Profile rebuilt around the stage. |
| 1.6.1 | Chat delivery fixed (queue, pending/failed, retry). Voice notes (permission, slide-to-cancel, amplitude). WhatsApp-style chat tones + haptics (admin + user). |
| 1.6.2 | Random match radar (discs, map, orbiting avatars) + match preview. Presence badge. |
| 1.6.3 | New B-mark logo across app, admin, landing. |
| 1.7.0 | Admin-configurable login (Google / phone / guest / email). Daily streak rewards. Sign-in + 20-second profile setup redesign. |
| 1.7.1 | Random match rebuilt again as a photo-first mystery card (no radar). |
| 1.7.2 | Switched to bebu’s own Firebase (`neocat-ceae7`, `in.bebuapp.app`). Google / phone / guest live. |
| 1.8.0 | **Gifts**: 10 bundled 3D gifts, cinematic send, host celebration, admin catalog + master switch + host share. Full rebrand of leftover Talkin copy in admin. |
| 1.9.0 | **Earn coins**: profile completion (25), invite friends (20 + 40% of first pack), avatar unlock bonus (4–10). RewardBlast overlay. Bio on edit profile. |
| 2.0.0 (in progress) | **bebu Pro**: time-limited coin passes, daily free-match cap, golden tick, Style Studio (12 4K wallpapers, fonts, chat themes, call templates), Pro-only gifts / avatar items. Backend done; Flutter screens exist; admin UI + surface wiring still open. See AI-GUIDE “bebu Pro”. |

## Feature notes a new AI will hit

### Auth and Firebase

- Providers are **admin flags**, not hardcoded. Public config is fetched
  before login (`getAppConfiguration`).
- Phone OTP: Firebase must have Phone provider on, billing on, and an SMS
  region policy. An empty allowlist or `BILLING_NOT_ENABLED` looks like
  “this sign-in method is not enabled” in the app.
- Welcome bonus (`dailyLoginBonusCoins` / login settings) is granted on first
  register. Referral code is accepted on the same authenticate call.

### Calls and matching

- Media: **Zego**, not Agora, in the shipping app (the Nest scaffold mentions
  Agora; ignore that).
- Private vs random rates are separate settings.
- Random match: `retrieveAvailableListener` + `Randomcall` + sockets.
  Fake hosts can be returned when no real host is free (AI replies cover
  their chat).
- From 2.0, free users consume `user.randomMatch` (date + count) against
  `premium.features.freeRandomMatchesPerDay`. Response code `MATCH_LIMIT`.

### Chat

- Socket.IO is a **single** connection (`SocketService`) with an offline
  queue. Optimistic UI uses local ids until the server ack.
- Message types include text, image, audio, call events, **gifts**.
- Host-side list can show `showBadge` for Pro users.

### Economy

Admin owns every coin number:

- Call rates, welcome bonus, daily streak schedule, profile / referral /
  avatar-bonus rewards, gift prices + host share, avatar item prices,
  Pro pass prices, Style Studio item prices, coin plans.

Wallet history is the `History` collection. Income vs spend is decided in
`history.controller.js` (`isIncome`) — new credit types must be added there
or they show as debits.

### AI fake hosts

Admin → Settings → AI Chat. Personas per host, multi-language / Manglish
replies. Provider keys never leave the server (`aiChat` stripped from the
app settings payload).

### Avatar Studio

Fluent Emoji 3D-based catalog, seeded from a manifest. Slots: avatar,
background, pet, vehicle, home, sky, accessory. `includedInPro` (new) lets
Pro users unlock without paying.

### Gifts

Bundled renders in `backend/assets/gifts`. `tier: "standard" | "pro"`.
Master switch hides every gift surface in the app when off.

### Appearance

Admin sets default theme, whether users may choose, accent id, corner
style, motion, glow, live rings, coin animation, SFX, chat sounds, haptics.
`Appearance.applyServer` on splash; `Get.forceAppUpdate()` rebuilds tokens.

### Downloads / CodeCanyon

Admin → Downloads lists zips and signed binaries. Two bundles:

- Production (this project’s migration notes).
- Marketplace (no keys, `install.sh` first-run wizard).

iOS: there is **no committed IPA**. `docs/ios-release.md` + `codemagic.yaml`
+ `.github` workflow describe TestFlight without a local Mac.

## Folder rename (`talkin/` → `bebu/`)

Commit `966ed46`. Compose and Caddy are `STACK_NAME`-driven. iOS bundle
became `in.bebuapp.app`. Vendor secrets and an Envato token were removed
from source. A `talkin/` tree may still exist as a leftover — do not develop
there.

## Production operations (current VPS)

- Compose stack behind a shared Caddy, `STACK_NAME=bebuapp`.
- Mongo data in the `bebu-mongo` volume.
- Release artifacts copied into the backend container
  `/app/storage/downloads`.
- QA admin accounts were created and deleted during automated checks; do
  not assume `qa-rw@bebuapp.in` still exists.

## Decisions already made (do not re-litigate)

- Stack for the shipping app: Flutter + Express/Mongo + Next admin. Not
  Nest, not a rewrite.
- State in the app: GetX + GetStorage. Not Riverpod / Bloc unless asked.
- UI primitives: custom `BebuTheme` + a few shared widgets. Not a second
  component library in Flutter. Admin already uses Vuexy — do not add
  another admin kit.
- Wallpapers: Unsplash License photos, 2160×3840 + 540px thumbs.
- Fonts: Google Fonts at runtime (`google_fonts`), not bundled TTF.
- Pro is **coin-funded time passes**, not store subscriptions (can add
  later). Admin can grant/revoke.
- Free users get a **daily match cap**; Pro is unlimited matching. Call
  per-minute billing stays.

## Open work at time of this file

bebu Pro 2.0.0 — backend APIs and Flutter Pro / Style Studio screens are
in the tree. Remaining: apply looks in chat + call, match-limit upsell,
Pro gift/avatar locks, profile/wallet entries, admin Premium UI, 2.0.0
build and docs. Details in `AI-GUIDE.md` → “bebu Pro — current status”.
