# Sign-in, onboarding and daily rewards

Three things the admin can shape from *Admin → Settings → Login & Rewards*:
which sign-in buttons the app shows (and which one is the hero), the welcome
bonus a new account gets, and the daily streak gift that brings people back.

## Sign-in methods (`setting.login`)

| Field                    | Values / default                          | Effect in the app                                                                          |
| ------------------------ | ----------------------------------------- | ------------------------------------------------------------------------------------------ |
| `google`                 | bool, `true`                              | *Continue with Google* (Firebase Google provider).                                         |
| `phone`                  | bool, `true`                              | *Continue with phone*: number → 6-digit SMS code, auto-fill on Android, 30 s resend timer.  |
| `quick`                  | bool, `true`                              | *Try it now*: anonymous Firebase account with a random display name, no form at all.      |
| `email`                  | bool, `false`                             | *Use email instead*: the classic email + password flow (register / forgot password).      |
| `primary`                | `google` \| `phone` \| `quick` \| `email`  | The big hero button. Must be an enabled method; the server snaps it to one if it isn't.    |
| `showWelcomeBonus`       | bool, `true`                              | Animated *"N free coins on your first sign-in"* teaser above the buttons.                  |
| `requireConsentCheckbox` | bool, `false`                             | `false` = implicit "By continuing you agree…" line; `true` = a checkbox that gates the CTA. |
| `headline`               | string ≤ 80 chars, `""`                   | Replaces the default headline ("Real people. Real talk.").                        |

Presets in the admin tab only write these flags:

| Preset         | google | phone | quick | email | primary |
| -------------- | :----: | :---: | :---: | :---: | :-----: |
| `recommended`  |   ✓    |   ✓   |   ✓   |       | google  |
| `phone`        |        |   ✓   |       |       | phone   |
| `google`       |   ✓    |       |       |       | google  |
| `phone_google` |   ✓    |   ✓   |       |       | google  |
| `social`       |   ✓    |       |   ✓   |       | google  |
| `all`          |   ✓    |   ✓   |   ✓   |   ✓   | google  |

Guard rails (`backend/util/loginRewards.js → normalizeLogin`): a document with
every method off is served as Google + phone, and `primary` is forced onto an
enabled method, so the app can never render a screen with no way in.

The app reads this **before login** from the public
`GET /api/user/setting/getAppConfiguration` (it now also returns `appearance`,
`welcomeCoins` and `dailyReward.{enabled,coins}`), caches it in `GetStorage`
(`loginConfig`, `rewardTeaser`) and renders the sign-in screen from the cache on
the next cold start, so the first frame already matches the admin's choice.

## Welcome bonus

`setting.dailyLoginBonusCoins` is, despite its name, a one-time signup bonus
granted by `user/login` when `signUp: true`. The tab exposes it as *Welcome
coins*. The sign-in screen teases it (`showWelcomeBonus`), the profile screen
reminds the user the coins unlock when they continue, and the first Home
visit opens the reward sheet with a *Welcome gift* banner on top of day 1 of
the streak (`DailyRewardController.markWelcomePending` → `consumeWelcome`).

## Daily streak reward (`setting.dailyReward`)

| Field               | Default                        | Meaning                                                                             |
| ------------------- | ------------------------------ | ----------------------------------------------------------------------------------- |
| `enabled`           | `true`                         | Turns the whole feature off (badge, sheet, endpoints answer `enabled:false`).       |
| `coins`             | `[10,15,20,25,30,40,60]`       | Reward for streak day 1…N (max 14 entries). The schedule loops after the last day.  |
| `resetStreakOnMiss` | `true`                         | Missing a calendar day sends the user back to day 1. `false` = streak never breaks. |
| `timezone`          | `Asia/Kolkata`                 | IANA zone that defines "a day" and the midnight countdown.                          |
| `autoOpen`          | `true`                         | Pop the sheet on Home automatically (once per day) when a claim is available.       |

Per-user progress lives on `User.dailyReward`
(`lastClaimDate` as `YYYY-MM-DD` in the configured zone, `streak`,
`bestStreak`, `totalClaims`, `totalCoins`).

### Endpoints

- `GET /api/user/dailyReward/status` (user token + secret key) →
  `{ enabled, canClaim, claimedToday, streak, day, coins, nextCoins, schedule, nextClaimAt, bestStreak, totalClaims, autoOpen, balance }`.
- `POST /api/user/dailyReward/claim` → same shape plus `claimed` (coins just
  granted) and the new `balance`. Idempotent per day: the update is a
  conditional `findOneAndUpdate` on `dailyReward.lastClaimDate != today`, so
  two taps or two devices can never double-grant. Writes a `History` row of
  type `9` (`HISTORY_TYPE.DAILY_REWARD`, counted as income in wallet history).
- `GET /api/admin/loginRewards` → `{ login, dailyReward, welcomeCoins, preset, options.{methods,presets}, stats }`
  where `stats` = users who claimed today, active streaks, longest streak,
  total coins given.
- `PATCH /api/admin/loginRewards` body `{ preset?, login?, dailyReward?, welcomeCoins? }`.
  Everything is normalised before saving and written through
  `updateSettingFile`, so `fetchAppSettingsData` and `getAppConfiguration`
  serve it immediately.

### Streak rules (`computeStatus`)

- Claimed today → `canClaim:false`, `streak` unchanged, countdown to next
  local midnight.
- Last claim was yesterday (or `resetStreakOnMiss:false`) → next claim is
  `streak + 1`.
- Otherwise → back to day 1.
- `day = ((streak − 1) mod len) + 1`, `coins = schedule[day − 1]`.

## App implementation

- `lib/utils/login_config.dart` — `LoginMethod`, `LoginConfig` (`hero`,
  `secondary`, `remember`/`current`), `RewardTeaser`.
- `lib/ui/user_flow/sign_in_screen/` — `SignInController` (steps
  `methods → phone → otp`, Google / anonymous / phone OTP end to end, email via
  the legacy `MainScreenController`) and `SignInScreen` (aurora background,
  logo + live-hosts pill, headline, value rows, bonus teaser, hero + secondary
  buttons, consent). Phone step: country picker + large numeric field; OTP
  step: six boxes, Android SMS auto-retrieval, resend countdown, inline errors.
  `EmailSignInScreen` is the themed email + password form. The old
  `MainScreen` remains at `/legacyLogin`.
- `lib/ui/user_flow/fill_profile_screen/` — first-run profile trimmed to what
  we need: display name (pre-filled, shuffle button), gender cards, 18+
  birthday with age chip. Photo and country are optional (country is
  pre-detected from the IP lookup on splash). Progress bar and the CTA label
  react as steps complete; the footer shows the welcome coins waiting.
- `lib/ui/user_flow/daily_reward/` — `DailyRewardController` (status, claim,
  once-per-day auto-open keyed on `dailyRewardAutoOpenedFor`, welcome handoff),
  `DailyRewardSheet` (3D coin stage with spark burst, 7-day streak strip,
  *Claim N coins* → balance count-up, countdown to the next gift, welcome
  banner), `GiftBadge` (hopping gift on the Home coin pill while a claim is
  available; tapping the pill opens the sheet instead of the wallet).
- Splash applies `LoginConfig.remember`, `RewardTeaser.remember` and
  `Appearance.applyServer` from `getAppConfiguration` before any screen is
  shown.
