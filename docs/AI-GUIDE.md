# AI / new-engineer guide to this repository

Read this file first. It is the map of what this repo actually is, what is
shipping, what is leftover, and how to change it without rebuilding from
scratch. Product history lives in [`PROJECT_HISTORY.md`](PROJECT_HISTORY.md).
Admin how-to lives in [`admin-guide.md`](admin-guide.md).

## What this repo is (and is not)

**bebu** (bebuapp.in, Elevanza Ltd) is a 1-to-1 voice/video calling app with
coin billing. Users pay coins per minute to talk to **hosts** (called
"listeners" in the backend). There is also chat, gifts, Avatar Studio,
rewards, and (in progress) **bebu Pro**.

The product that is live and what every feature request should edit is:

```
bebu/
  app/        Flutter user + host app (GetX). Package / bundle: in.bebuapp.app
  backend/    Express + MongoDB + Socket.IO
  admin/      Next.js 15 admin panel
  deploy/     install.sh + Docker Compose + Caddy
```

Everything else at the repo root is **not the shipping product**:

| Path | What it is | Touch it? |
| ---- | ---------- | --------- |
| `apps/`, `packages/`, `infra/` | Early NestJS + Prisma + Flutter shell scaffold (never productized) | No, unless asked to revive it |
| `talkin/` | Leftover copy of the vendor reference after the `talkin/` → `bebu/` rename | Do not add features here |
| `releases/` | Signed APKs / AAB + checksums published from Admin → Downloads | Rebuild when shipping a version |
| `docs/` | Human + AI documentation | Yes, keep in sync with features |
| `tools/` | `package.sh` builds production + CodeCanyon zips | Yes, when cutting a release |
| `codemagic.yaml` | iOS TestFlight CI (no local Mac) | Yes, for iOS |

**Never rebuild from scratch.** The user (and CodeCanyon buyers) expect
edits on top of `bebu/`. The Flutter package name is still `talk_in` in Dart
imports (`package:talk_in/...`) even though the product name is bebu. Do not
mass-rename that import prefix unless asked — it is every file in the app.

## Brand rules

- Product name: **bebu**. Company: **Elevanza Ltd**.
- No Talkin / vendor watermarks, login artwork, Envato tokens, or their
  Firebase project.
- Firebase project: `neocat-ceae7`. Android package and iOS bundle:
  `in.bebuapp.app`.
- Live staging (as of 2026-09-22): `https://bebu.145.223.79.74.sslip.io`
  — API under `/api`, admin at `/login`, Socket.IO on the same host.

## How a request usually maps to files

A typical "add X, admin can turn it off, coins from wallet" feature touches
all three layers. Mirror an existing feature (gifts, rewards, avatar, daily
reward) rather than inventing a new pattern.

```
setting.model.js          admin-tunable flags + defaults
user.model.js             per-user state
types/constant.js         HISTORY_TYPE (next unused integer)
util/<feature>.js         normalize settings, grant/debit, seed catalog
controllers/user/…        app API
controllers/admin/…       admin API
routes/user|admin/…       wire under /api/user/<x> and /api/admin/<x>
index.js                  static /<assets> + seed on boot
admin/src/views/…         settings tab or CRUD page + menu
app/lib/ui/user_flow/…    GetX model + api + controller + view
app/lib/utils/database.dart or a small cache (Appearance, Pro, LoginConfig)
docs/ + releases/notes.json
```

Coin movements must be **atomic** (`findOneAndUpdate` with `$inc` and a
`coins: { $gte: price }` guard), write a `History` row, and usually an FCM
`Notification`. See `util/rewards.js` `credit()` and `util/premium.js`
`activatePass()`.

## Backend map (`bebu/backend`)

- Entry: `index.js` — Express, Socket.IO (`socket.js`), static `/storage`,
  `/gifts`, `/avatar-studio`, `/premium`, settings bootstrap.
- Settings singleton: Mongo `Setting` document, cached as `global.settingJSON`,
  rewritten to `setting.js` by `global.updateSettingFile`. Defaults in
  `setting.js` are first-boot only. **Secrets do not belong in `setting.js`.**
- Auth:
  - App: `x-auth-token: Bearer <Firebase ID token>`, `x-auth-uid`, header
    `key` = `SECRET_KEY`.
  - Admin: Firebase email/password + `Admin` collection + same `key`.
- Roles: `User` (caller) and `Listener` (host). A user can become a host
  (`isListener`, `listenerId`).
- Realtime: `socket.js` — chat, call signalling, random-call queue
  (`Randomcall` model), presence. Flutter: `lib/socket/`.
- Media: Zego Express Engine. Rates: `setting.audioCallRate*`,
  `videoCallRate*` (private vs random).
- Payments: coin plans (`coinplan`) via Play / Stripe / Razorpay /
  Flutterwave flags in settings.

### Important user APIs

| Prefix | Purpose |
| ------ | ------- |
| `/api/user/authenticateOrRegisterUser` | Login / register (accepts referral code) |
| `/api/user/getUserProfile` | Profile + `premiumStatus` + `activeStyle` |
| `/api/user/setting` | Public `getAppConfiguration` (pre-login) and authenticated settings |
| `/api/user/rewards` | Earn-coins hub, profile claim, apply referral |
| `/api/user/dailyReward` | Streak status + claim |
| `/api/user/premium` | Pro status, buy pass, badge, Style Studio, unlock, apply |
| `/api/user/gift` | List + send gifts |
| `/api/user/avatar` | Avatar Studio catalog, unlock, equip |
| `/api/user/listener` | Host list + **random match** (`retrieveAvailableListener`) |

Admin mirrors live under `/api/admin/…` (`loginRewards`, `premium`, `gift`,
`avatarStudio`, downloads, users, hosts, coin plans, …).

### History types (`types/constant.js`)

```
1 LOGIN_BONUS  2 COIN_PLAN_PURCHASE  3 PRIVATE_AUDIO  4 PRIVATE_VIDEO
5 RANDOM_AUDIO 6 RANDOM_VIDEO        7 WITHDRAWAL     8 AVATAR_UNLOCK
9 DAILY_REWARD 10 GIFT              11 PROFILE_REWARD 12 REFERRAL_REWARD
13 AVATAR_BONUS 14 PREMIUM_PASS     15 STYLE_UNLOCK
```

Add the next integer; update admin history label maps
(`admin/src/views/apps/user/view/user-right/history/constants.js` and the
two `getTransactionTypeName` copies) plus the Flutter wallet labels.

## Flutter map (`bebu/app`)

- State: **GetX**. Persist: **GetStorage** via `lib/utils/database.dart`.
- Theme: `lib/utils/app_theme.dart` (`BebuTheme`) + `lib/utils/appearance.dart`.
  Admin appearance (accent, dark/light, motion, haptics, SFX) is applied at
  splash. Style Studio fonts go through `BebuTheme.configureFont`.
- Routes: `lib/routes/app_routes.dart` + `app_pages.dart`.
- User vs host: `lib/ui/user_flow/` and `lib/ui/host_flow/`.
- SFX / haptics: `lib/custom/motion/sfx.dart` (respects admin + user toggles).
- Images from the API: prefix `Api.baseUrl` (see `listenerImageUrl` /
  `Pro.assetUrl`). Paths are like `premium/wallpapers/love_bokeh.jpg`.
- Build flags: `--dart-define=API_BASE_URL=…` and `API_SECRET_KEY=…`.
- Version: `pubspec.yaml` `version: X.Y.Z+build`. Latest shipped APK is
  **1.9.0+18**. Pro work is unreleased (target 2.0.0).

### App caches that survive a restart

| Storage key / helper | What |
| -------------------- | ---- |
| `Appearance` | Admin theme + user dark/light choice |
| `LoginConfig` / `RewardTeaser` | Pre-login buttons and bonus teaser |
| `Pro` (`lib/utils/pro.dart`) | Pro config, entitlement, applied style |
| `Database.*` | Login user, coins, settings model |

`Pro.init()` and `Appearance.init()` run in `main.dart` after `GetStorage.init()`.

## Admin map (`bebu/admin`)

Vuexy-based Next.js 15. Settings tabs are composed in
`src/views/settings/`. Feature pages (Gifts, Downloads, Coin plans, Hosts,
Users) have their own `src/views/<name>/`. Redux slices live in
`src/redux-store/slices/`.

When adding a tab: settings index + menu item + API slice + controller.

## Deploy

```
cd bebu/deploy && ./install.sh
```

Writes `.env`, brings up mongo + backend + admin + Caddy, seeds, creates
the first admin. Marketplace buyers use the same script (no production
keys). Production secrets live only on the VPS `.env` and
`firebase-service-account.json` — never commit them.

`STACK_NAME` prefixes container names (`bebuapp-*` on the current VPS).

Edge Caddy (`deploy/Caddyfile`) must route `/api`, `/socket.io`, `/storage`,
`/gifts`, `/avatar-studio`, `/premium` to the backend. If a new static
folder is added, add the route or images 404 at the edge.

## Conventions that have bitten people

1. **Edit `bebu/`, not `talkin/` or `apps/`.**
2. Random match had **no daily cap** until Pro. The cap is
   `premium.features.freeRandomMatchesPerDay` (default 5). Pro users skip it.
   Per-minute call coins still apply.
3. `setting.js` on disk is a cache of Mongo. After changing the schema,
   existing production docs need the new nested object (defaults apply via
   `normalize*` helpers — always go through those, never read raw settings).
4. Flutter `User` constructor fields must be listed in the constructor
   **and** `fromJson`. Forgetting one causes `undefined_named_parameter`.
5. Golden-image / widget tests that drive `BebuTheme` should set
   `Appearance.rebuildOnChange = false` to avoid `Get.forceAppUpdate`.
6. Phone OTP needs Firebase billing + SMS region policy (India allowlist).
   `operation-not-allowed` is usually a provider or region-policy issue, not
   app code.
7. Do not put production `SECRET_KEY`, Zego sign, payment secrets, or
   service-account JSON in git. Client `google-services.json` /
   `GoogleService-Info.plist` are already in the app (restricted Firebase
   keys).

## bebu Pro — current status (read before continuing)

**Backend: done and committed.** Schema, APIs, seed catalog, gates.

- Settings: `setting.premium` (enabled, name, tagline, passes, features,
  `showBadgeToHosts`).
- User: `premium`, `style`, `unlockedStyles`, `randomMatch`.
- Catalog: `PremiumItem` seeded from
  `backend/assets/premium/manifest.json` + 12 Unsplash 4K wallpapers under
  `backend/assets/premium/wallpapers/`.
- User API: `GET/POST /api/user/premium/{status,buy,badge,studio,unlock,apply}`.
- Admin API: `GET/PATCH /api/admin/premium` + item CRUD + grant/revoke.
- Gates already in: random-match daily cap, gift `tier: "pro"`, avatar
  `includedInPro`, profile exposes `premiumStatus` + `activeStyle`,
  listener chat list / user profile expose `showBadge`.

**Flutter: models, Pro cache, paywall, Style Studio screens — in the tree,
not wired through every surface yet.**

Done:

- `lib/ui/user_flow/premium/` — models, API, `PremiumController`,
  `ProScreen`, `StyleStudioScreen`, `ProBlast` / `GoldenTick` / upsell sheet.
- `lib/utils/pro.dart` — process-wide cache; splash / main / profile write it.
- Routes: `/pro`, `/styleStudio`.
- `BebuTheme.configureFont` + gold tokens.
- `style/style_looks.dart` — `ChatLook`, `CallLook`, canvas/backdrop painters.

Still to do (continue here, do not start over):

1. Apply `ChatLook.current()` in personal chat (user + host).
2. Apply `CallLook.current()` in `VoiceCallView1` / video call (keep controls).
3. Random match: quota pill + `MATCH_LIMIT` → `ProUpsellSheet`.
4. Gift sheet: lock `tier == pro` gifts when `!Pro.isActive`.
5. Avatar Studio: show included-in-Pro price / unlock via Pro.
6. Profile + wallet entry points (Pro crest / Style Studio).
7. Wallet history labels for types 14 and 15.
8. Admin: Settings → Premium tab, Premium items page, user grant/revoke,
   gift `tier` and avatar `includedInPro` fields, menu.
9. Docs (`docs/premium.md`), `releases/notes.json`, version `2.0.0+19`,
   APK/AAB, VPS download folder.

Catalog intent (admin can edit later):

- 12 wallpapers (love / friendship / romantic). **3 free with Pro**
  (`love_bokeh`, `romance_sunset`, `friends_sunset`); others cost coins.
- 8 Google Fonts. **3 free** (Quicksand, Playfair Display, Dancing Script).
- 6 chat themes. **3 free** (Midnight Rose, Ocean Breeze, Golden Hour).
- 6 call templates. **3 free** (Classic Glass, Neon Pulse, Sunset Glow).

## How to run locally

Backend + admin (needs Docker): `cd bebu/deploy && ./install.sh`.

Flutter (after a backend exists):

```bash
cd bebu/app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://YOUR_HOST/ \
  --dart-define=API_SECRET_KEY=YOUR_SECRET
```

Admin: Next.js 15, `cd bebu/admin && pnpm i && pnpm dev` (or the compose
service). It talks to the same `SECRET_KEY`.

## Tests that already exist

- Flutter widget / golden shots under `bebu/app/test/` (rewards blast, etc.).
- Backend smoke scripts used on the VPS (rewards, gifts) — recreate the
  pattern rather than adding a second test framework.
- `flutter analyze` should stay clean of **errors** in files you touch.

## Release / CodeCanyon

`tools/package.sh` builds:

- Production zip (with this project's wiring notes).
- Marketplace zip (no keys, installer-first).
- Flutter source zip, APKs, AAB.

Admin → Downloads serves files from the backend `storage/downloads` volume
with signed URLs. After a release, copy artifacts there (see recent
`releases/README.md`).
