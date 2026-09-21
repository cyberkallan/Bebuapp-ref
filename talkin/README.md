# bebu app stack (`talkin/`)

The shipping bebu product: a Flutter app, an Express + MongoDB backend and a
Next.js admin panel, adapted from the Talkin reference package and rebranded.
This is what the test APKs in `/releases` are built from and what runs on the
VPS today.

| Folder     | What it is                                             | Runs as                     |
| ---------- | ------------------------------------------------------ | --------------------------- |
| `app/`     | Flutter user + caller ("host") app                     | Android APK                 |
| `backend/` | REST + Socket.IO API, ZegoCloud tokens, payments, chat | `talkin-backend` container  |
| `admin/`   | Admin panel (Next.js 15)                               | `talkin-admin` container    |
| `deploy/`  | Docker Compose, Caddy edge, `.env` template, DB seed   | `talkin-mongo`, `talkin-edge` |

Live staging: `https://bebu.145.223.79.74.sslip.io` (API under `/api`, admin
at `/login`).

## How the pieces talk

```
phone ──HTTPS──▶ shared Caddy (VPS :443) ──▶ talkin-edge ──▶ talkin-backend :5000  (/api, /storage, /socket.io)
                                                     └──▶ talkin-admin   :5001  (everything else)
browser ─┘                                                 talkin-backend ──▶ talkin-mongo
```

Authentication is Firebase on every surface:

- App: Firebase Auth (quick/anonymous, Google, email) → ID token sent as
  `x-auth-token: Bearer …` plus `x-auth-uid`; every request also carries the
  shared `key` header (`SECRET_KEY`).
- Admin: Firebase email/password sign-in → ID token + `x-admin-uid`; the
  backend also checks an `Admin` document.
- Backend verifies tokens with the Firebase service account stored in the
  `Setting` document (initially copied from `backend/setting.js`).

The bundled Firebase project (`talk-in-98cd8`) is the vendor's demo project
and still accepts sign-ins. Replace it with bebu's own project before launch:
put the new `google-services.json` in `app/android/app/`, update the web
config in `deploy/.env`, and paste the new service-account JSON in the admin
Settings page.

## Deploying the backend + admin

Requirements on the host: Docker with Compose, and a public reverse proxy that
terminates TLS (the VPS uses a shared Caddy; the site block is in
`infra/deploy/vps/` style: proxy the hostname to `talkin-edge:80`).

```bash
# on the server
rsync -az --exclude node_modules --exclude .next talkin/ root@HOST:/opt/talkin/
cd /opt/talkin/deploy
cp .env.example .env            # fill DOMAIN, SECRET_KEY, NEXTAUTH_SECRET, Firebase web config
docker compose up -d --build
docker compose exec -T mongo mongosh --quiet talkin < seed/seed.js   # topics, coin plans, FAQs, currencies
```

`EDGE_NETWORK` must be the Docker network of the public proxy so it can reach
`talkin-edge`. Container names are fixed (`talkin-*`) because other projects
on the shared network also have services called `admin`/`backend`.

The admin panel bakes `NEXT_PUBLIC_*` values in at build time; change them in
`.env` and rebuild with `docker compose up -d --build admin`.

### First admin account

Admin registration normally validates an Envato purchase code online. The
compose file sets `ENVATO_PURCHASE_CHECK=off` so a self-hosted deployment can
register and sign in without it. Create the first admin either from the
panel's **Register** page (needs the Firebase service-account JSON) or with
the API:

1. Create a Firebase email/password user (Firebase console, or
   `accounts:signUp` REST call with the web API key).
2. `POST /api/admin/initiateAdminRegistration` with header `key: SECRET_KEY`
   and body `{ email, password, uid, code, privateKey }` where `privateKey`
   is the service-account JSON object.

## Building the app

```bash
cd talkin/app
flutter pub get
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=https://bebu.145.223.79.74.sslip.io/ \
  --dart-define=API_SECRET_KEY=<SECRET_KEY>
```

Both defines default to the staging server, so a plain
`flutter build apk --release --split-per-abi` works too. Release signing reads
`app/android/key.properties` (git-ignored) pointing at a `.jks`; without it the
build is signed with the debug key. Keep the release keystore safe — it is the
only key that can update installed builds.

Toolchain used for `1.1.0`–`1.4.0`: Flutter 3.32.8, Android SDK 35, NDK 28, JDK 17.

### What changed from the reference package

- Branding: app name, launcher/adaptive icon, splash and in-app strings.
- `lib/utils/api.dart` reads the base URL and secret from `--dart-define`.
- `minSdk` 23 (required by current plugins), version `1.4.0+6`, release signing
  from `key.properties`.
- Backend: corrected the service-account `project_id` so ID tokens verify;
  `ENVATO_PURCHASE_CHECK` switch; Dockerfile with health check.
- Admin: configuration from environment instead of hand-edited constants; a
  missing import and two API URL joins fixed.

### UI redesign (`1.2.0`)

The user-facing discovery flow was rebuilt on a dark, photo-first design while
keeping the original controllers, APIs and call/chat entry points untouched:

- `lib/utils/app_theme.dart` — `BebuTheme` tokens (colours, Inter type,
  radii, motion) plus shared widgets: `GlassIconButton`, `BebuChip`,
  `StatusPill`, `SegmentedPill`, `FadeSlideIn`, `PressScale`.
- `lib/custom/listeners/listener_actions.dart` — single place that opens
  chat, the call chooser (`TalkNowButtonBottomSheet`) and profiles with the
  exact argument lists the legacy screens used.
- Home (`home_screen/`) — swipeable card deck (`ListenerDeck`): drag left to
  skip, right to call; For You / Live feeds; coin pill; pull to refresh.
- Explore (`listener_screen/`) — two-column photo grid, Live/Language/Topics
  chips (the Language and Topics sheets are the existing ones), shimmer,
  empty states, pagination.
- Profile (`profile_detail_screen/`) — hero card, media strip with rates,
  stats, About Me, More Info, reviews, floating Chat / Talk now bar.
- Bottom bar — floating frosted pill with a sliding active indicator. The
  Calls tab keeps its light theme and a reserved slot under the bar.

### Second pass (`1.3.0`)

- Random match (`random_call_screen/`) — radar of live callers orbiting a
  glowing core (`_Radar`, `CustomPainter` rings + sweep while searching),
  Audio/Video segmented toggle replacing the old dialog, gradient match
  button. `RandomMatchView` shows the matched caller with rings, intro,
  topics, rate and the same Call / Say hello actions.
- Chat list (`chat_screen/`) — search field, glass rows with presence dot,
  typed previews (photo / voice / call), relative time, unread badge,
  shimmer and empty state. Pagination unchanged.
- Personal chat (`personal_chat_screen/`) — `personal_chat_dark_widgets.dart`
  holds the header (back, presence, call, profile), day dividers, text and
  call bubbles, the call-permission card and the frosted composer (photo,
  long-press mic with a recording pill, gradient send). Photo and voice-note
  bubbles reuse the original widgets; the reversed list + pagination scroll
  logic is untouched.
- Splash and onboarding — animated logo with expanding rings and a loading
  bar; onboarding pages with parallax art, animated dots, Skip and a single
  primary action. Android `launch_background` is now `#0E0E10` so there is no
  white flash before Flutter draws.
- Theme additions: `AuroraBackground`, `GradientButton`, `GhostButton`,
  `GlassCard`, `BebuAvatar`.

### Polish pass (`1.3.1`)

- Home header — avatar, `SegmentedPill`, coin pill and bell share one 42dp
  height (`_HomeHeader.controlHeight`); the pill thumb is inset 3px with a
  border and shadow so it no longer reads taller than its neighbours. Back
  cards in `ListenerDeck` scale from their top edge and peek a fixed 12dp per
  depth (`_peek`), and the deck has 30dp of top padding, so cards never touch
  the header on any screen size.
- `custom/motion/coin_pill.dart` — `CoinPill` / `AnimatedCoin`: one repeating
  4.2s controller drives a 3D Y-axis flip of the coin (first 18% of the loop),
  a breathing amber glow, a skewed glossy sweep across the pill (42–62%), and a
  `TweenAnimationBuilder` count-up with a small bounce when the balance
  changes. Used on Home and the random-match header.
- `custom/motion/ringing_call_button.dart` — `RingingCallButton`: when
  `ringing` is true the handset wiggles ±14° for 0.9s then rests (2.4s
  cadence) and two rings expand outwards. Explore tiles ring green for live
  callers; the deck's main action rings pink. Static otherwise, controller
  stopped, wrapped in a `RepaintBoundary`.
- Performance — `GlassIconButton.blur` lets callers skip `BackdropFilter`
  (a saveLayer per button); Explore tiles no longer blur. `ListenerPhoto.cacheWidth`
  passes `memCacheWidth` so grid photos decode at ~220dp × DPR and deck photos
  at screen width instead of full upload size. Grid tiles and back cards sit
  in `RepaintBoundary`s so the ring/flip animations only repaint themselves.

### Themes and admin UI control (`1.4.0`)

- `utils/app_theme.dart` — `BebuTheme` colours are now getters over a
  `BebuPalette` (dark / light) and a `BebuAccent`; radii scale with the admin
  corner style and durations collapse when motion is reduced. `onPhoto*`
  constants keep text over photos light in both themes.
- `utils/appearance.dart` — `Appearance` merges the admin config
  (`setting.appearance`, cached locally), the user's saved pick and platform
  brightness, then `BebuTheme.configure(...)` + `Get.forceAppUpdate()`.
  `Utils.onChangeStatusBar` flips icon brightness for the light theme.
- `custom/theme_picker.dart` — System / Dark / Light cards with mini previews,
  used on My profile (when the admin allows) and as an optional last
  onboarding step.
- My profile (`my_profile_screen`) rebuilt: hero with gradient ring and edit
  chip, wallet card (`CoinPill`, recharged / spent, history), appearance
  section, four quick actions, host promo, grouped links, version footer.
- Calls tab (`calling_screen`) rebuilt: `CustomScrollView` with header, filter
  chips (all / missed / incoming / outgoing with counts), day headers,
  `CallHistoryRow` (presence avatar, direction + duration, coins, time,
  `RingingCallButton` ringing while the host is online), shimmer, empty state
  with an Explore shortcut, pagination spinner. Every tab is themed now, so the
  nav bar floats over all of them.
- Backend `appearance.controller.js` + `/api/admin/appearance`, admin
  *Settings → Appearance* tab with a live phone preview. See
  `docs/appearance.md`.

### Choosing a host on the Home deck (`1.5.1`)

- `home_screen/widget/listener_deck.dart` — Call (button or right swipe) no
  longer flies the card away. `_choose()` keeps the host as `_focused`, snaps
  the drag back to centre and runs `_focus` (720 ms): spring lift + scale,
  perspective `rotateX`/`rotateY` tilt that returns to flat, `_ChosenOverlay`
  (diagonal light sweep across the photo and `_ChosenRingPainter`: a sweep
  gradient highlight running one lap around the border, then a steady accent
  frame with inner glow), pink halo via `_ListenerCard.glow`. Back cards
  recede (scale/offset/opacity) and the action row dims. The chooser opens at
  380 ms with a lighter barrier; `ListenerActions.openTalkNow` is now
  awaitable, and when the sheet closes the card settles (`_focus.reverse()`).
  Only Skip (left swipe / ✕) calls `dismissListener`.
- `custom/motion/sfx.dart` — `Sfx.select()` = medium haptic + a 0.45 s
  two-note chime (`assets/audio/select.mp3`, synthesised with ffmpeg) through a
  single low-latency `audioplayers` player that mixes with other audio;
  `Sfx.tick()` = selection haptic. All no-ops when `BebuTheme.soundEffects`
  is off, and failures are logged, never thrown.
- Appearance gains `soundEffects` (backend defaults/normalize, admin Effects
  toggle, `AppearanceConfig` + `BebuTheme.soundEffects`).

### My wallet and purchase celebration (`1.5.0`)

- `my_wallet_screen/view` — `AuroraBackground` + `ListView` under a
  `WalletHeaderBar`; `Scaffold.extendBody` so content scrolls under the docked
  `WalletCheckoutBar` (gradient fade, CTA mirrors the selected pack, trust
  strip). Pull to refresh reloads packs and recent activity.
- `WalletBalanceCard` — amber/violet hero with the looping `AnimatedCoin`, a
  `TweenAnimationBuilder` count-up from `previousCoin` to the new balance,
  and a talk-time chip (`coins ~/ audioCallRatePrivate`) that turns into a
  "Running low" nudge under three minutes. "Coins never expire" trust line.
- `CoinPlanGrid` / `CoinPlanCard` — `Wrap` grid (2 columns, 3 on wide
  screens). Tap selects (haptic), the popular pack is pre-selected on load
  (`selectedCoinPlan` falls back to best value, then first). Ribbons: *Most
  popular* (`isPopular`) and *Best value* (lowest price per coin), `SAVE x%`
  against the worst price-per-coin anchor (`MyWalletController.savingsPercent`,
  hidden under 5%). Selected card gets a gradient border, glow and tinted fill.
- `PaymentOptionBottomSheet` — order summary (coins, ≈ minutes, price), one
  `PaymentOptionTile` per enabled gateway with a one-line explainer, a single
  enabled gateway is pre-selected (`openPaymentSheet`), `Pay ₹x` is disabled
  until a method is picked, and a "charged once, no subscription" line.
  `onClickPayNow` and the gateway services are unchanged.
- `WalletRecentActivity` — last six `CoinHistory` rows via the existing
  `CoinHistoryApi` (`startPagination` reset to 0 first): icon + colour per
  `HISTORY_TYPE`, receiver name for calls, relative time, `+`/`−` amount.
  Shimmer while loading, friendly empty card, *See all* → coin history.
- `MyWalletController.onPurchaseSucceeded()` — one success path for Razorpay,
  Stripe, Flutterwave and in-app purchase: refresh plans + balance, notify
  Home/Random controllers if registered, close the sheet, then open
  `CoinPurchaseScreen` with `coins`, `balance`, `previousBalance` and the
  receipt fields. (IAP used to `Get.close(2)` past the wallet; it now returns
  to it.)
- `coin_purchase_screen` — celebration: `PurchaseHero` (coin drops in with
  `elasticOut`, `PulseRings` behind it, green check, `+N coins` count-up,
  heavy haptic), `PurchaseBalanceCard` (old → new balance roll, ≈ minutes),
  `PurchaseReceipt` (amount, gateway, copyable transaction ID, date),
  *Start talking now* (`Get.until` bottom bar → Explore) and *Back to wallet*.
  Two `CoinBurst` layers fire at 260 ms and 1.1 s.
- `custom/motion/coin_burst.dart` — `CoinBurst` is one `CustomPainter` for
  ~70 particles (gold discs that squash to fake a flip + accent-coloured
  confetti; gravity, sway, spin, fade) inside a `RepaintBoundary` +
  `IgnorePointer`; `PulseRings` draws expanding rings. Both are static when
  the admin sets reduced motion.

### AI replies for fake hosts (backend + admin)

Fake hosts answer user messages with an LLM, in the language and personality
the admin assigns. Full plan, provider table and runbook: `docs/ai-chat.md`.

- Backend: `util/aiChat/` (language presets, OpenAI-compatible provider chain
  with failover + cooldown, reply pipeline), `models/listenerAiProfile`,
  `models/aiUsage`, `Setting.aiChat`, admin routes under `/api/admin/aiChat`.
  `socket.js` triggers a reply after a user's text/photo/voice message to a
  fake host. Provider keys are stripped from every app-facing settings
  endpoint.
- Admin: **Settings → AI Chat** (providers, language, behaviour, limits, call
  nudges, safety, playground, usage) and the robot action on the **Fake**
  listeners tab (per-host language, tone, persona, opening line, bulk assign).
- Free providers only: Groq (primary, fastest), Gemini (best Indic quality),
  Cerebras/OpenRouter/Mistral as backups, or any self-hosted OpenAI-compatible
  endpoint. Keys are created by the admin in the panel; no code changes.
- The app is unchanged: replies arrive as normal `messageDispatched` events
  and FCM pushes.
