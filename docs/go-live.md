# Go-live guide: connecting Firebase, calls, notifications, payments

Written for a first-time setup. Every step says **where to click**, **what to
copy**, and **where it goes**. Steps marked **YOU** need your accounts (Google,
Zego, Razorpay, domain). Steps marked **DEV** are done in this repo / on the
server once you send the values.

## 0. Where we are today

| Piece                         | Status now                                                      | Needs                                  |
| ----------------------------- | --------------------------------------------------------------- | -------------------------------------- |
| Backend + admin on VPS        | Live at `https://bebu.145.223.79.74.sslip.io`                   | Your domain (`api.bebuapp.in`)         |
| Landing + APK download        | Live at `https://ayushaura.in`                                  | Move to `bebuapp.in` when DNS is ready |
| AI host replies               | Connected                                                       | –                                      |
| Firebase (login, OTP, push)   | **Done** — project `neocat-ceae7`, app + server + admin switched  | –                                      |
| Android package name          | **Done** — `in.bebuapp.app` since 1.7.2                          | –                                      |
| Voice/video calls (Zego)      | Vendor's demo App ID                                            | Your own Zego project                  |
| Payments                      | Test keys / placeholders                                        | Razorpay live keys, Play billing later |
| Privacy / Terms pages         | Placeholder text                                                | Real pages on bebuapp.in               |

Google login and phone OTP fail today **only** because the app is signed with
our key but registered in a Firebase project we don't control. Steps 1–2 fix
that.

## 1. Package name and domain (decide now)

- Package name: **`in.bebuapp.app`**. Use this exact string whenever a console
  asks for "Android package name". Testers must uninstall the old build once.
- Domains: `bebuapp.in` = website + downloads (stays on Hostinger),
  **`api.bebuapp.in`** = backend + admin panel (the VPS).

Nothing to click here; just use these values below.

## 2. Firebase (≈30 minutes) — YOU

Firebase gives us login (Google, phone OTP, guest, email), push notifications
and admin sign-in. One project covers all of it.

### 2.1 Create the project

1. Open <https://console.firebase.google.com> → **Add project**.
2. Name: `bebu` → Continue. Google Analytics: **Disable** (you can add later) →
   **Create project**.

### 2.2 Register the Android app

1. On the project home click the **Android** icon (Add app).
2. Package name: `in.bebuapp.app`. Nickname: `bebu`.
3. **Debug signing certificate SHA-1** – paste the release SHA-1 below.
4. **Register app** → **Download google-services.json**. Keep it, you'll send it
   to me. Click Next / Next / Continue to console (skip the Gradle steps, they
   are already done in the repo).
5. Add the second fingerprint: **Project settings (gear) → General → Your apps
   → bebu (Android) → Add fingerprint** → paste the SHA-256 → Save. Then
   **download google-services.json again** (it now includes the OAuth client
   Google Sign-In needs).

Release keystore fingerprints (the key every bebu build is signed with):

```
SHA-1   8A:14:7E:45:FF:6C:6C:24:36:05:3A:5C:07:F7:E6:92:44:C7:E2:5B
SHA-256 27:FC:6D:74:BA:A9:68:6F:1E:74:1F:D4:4B:41:34:E3:7F:0A:BC:B1:72:2E:7A:26:A3:98:C3:F2:16:66:19:DB
```

### 2.3 Turn on the sign-in methods

**Build → Authentication → Get started → Sign-in method** tab:

| Provider           | Click                                             | Note                                                                                  |
| ------------------ | ------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Google             | Enable → pick a **support email** → Save          | Public-facing name: `bebu`.                                                           |
| Phone              | Enable → Save                                     | See 2.4 for SMS billing and free test numbers.                                        |
| Anonymous          | Enable → Save                                     | This is the one-tap **Try it now** guest login.                                       |
| Email/Password     | Enable (only the first toggle) → Save             | Only needed if you turn on email login in Admin → Settings → Login & Rewards.        |

Then **Authentication → Settings → Authorized domains → Add domain** →
`bebuapp.in` and `api.bebuapp.in`.

### 2.4 Phone OTP: billing and test numbers

- Firebase sends real SMS only on the **Blaze (pay-as-you-go)** plan. Bottom-left
  of the console → **Upgrade** → add a card. Cost is roughly ₹1–2 per OTP in
  India; there is no monthly fee.
- For free testing: **Authentication → Sign-in method → Phone → Phone numbers
  for testing** → add e.g. `+91 99999 99999` with code `123456`. These numbers
  never send SMS and always accept that code.
- Production OTP on Android uses Play Integrity. It works before the Play
  Store listing exists (falls back to a reCAPTCHA page) and becomes silent once
  the app is linked to Play Console (step 7).

### 2.5 Service account (lets the server send push notifications and verify logins)

**Project settings (gear) → Service accounts → Generate new private key →
Generate key.** A JSON file downloads. **Treat it like a password**: send it to
me privately, never post it publicly. It goes into *Admin → Settings → General
→ Firebase private key* (I will paste it for you).

### 2.6 Web app config (admin panel sign-in)

**Project settings → General → Your apps → Add app → Web (`</>`)** → nickname
`bebu admin` → Register. Copy the `firebaseConfig` block (apiKey, authDomain,
projectId, storageBucket, messagingSenderId, appId). Send it to me.

### 2.7 Google Sign-In consent screen (one-time, needed for real users)

1. Open <https://console.cloud.google.com> → select project **bebu** (Firebase
   created it) → **APIs & Services → OAuth consent screen**.
2. User type **External** → Create. App name `bebu`, support email, app logo
   (optional), **Application home page** `https://bebuapp.in`, **Privacy policy**
   `https://bebuapp.in/privacy`, **Terms** `https://bebuapp.in/terms`, developer
   contact email → Save.
3. Click **Publish app** so anyone (not only test users) can sign in.

Push notifications need nothing extra: **Firebase Cloud Messaging API (V1)** is
on by default for new projects.

**Send me:** `google-services.json` (from 2.2 step 5), the service-account JSON
(2.5), the web `firebaseConfig` (2.6).

## 3. Voice & video calls — Zego (≈10 minutes) — YOU

1. <https://console.zegocloud.com> → Sign up (email or Google) → **Create
   project** → use case **Voice & Video Call** → name `bebu` → **Flutter**.
2. On the project page copy **AppID** (a number) and **AppSign** (64-character
   string; click the eye icon to reveal).
3. Paste them in **Admin panel → Settings → General → Zego App ID / Zego App
   Sign** → Save. (Or send them to me.)

Free tier is 10,000 minutes/month, then pay as you go. Nothing else to enable.

## 4. Domain DNS (≈10 minutes, then wait up to an hour) — YOU

In Hostinger **hPanel → Domains → bebuapp.in → DNS / Name servers**:

| Type | Name  | Points to          | TTL   |
| ---- | ----- | ------------------ | ----- |
| A    | `api` | `145.223.79.74`    | 14400 |

Leave `@` and `www` as they are (they will serve the website from Hostinger).
Tell me when it's added. **DEV**: I switch the VPS to `api.bebuapp.in`
(automatic HTTPS), rebuild the admin panel and the app with the new address.

## 5. Payments — YOU (can be done after launch testing)

**Razorpay (UPI, cards, wallets in India)**

1. <https://dashboard.razorpay.com> → Sign up → complete **KYC** (PAN, bank
   account, business details, website `https://bebuapp.in` with privacy, terms
   and refund pages — see step 6).
2. Until KYC is approved use **Test mode** keys: **Account & Settings → API
   Keys → Generate Test Key**. After approval switch to **Live mode** and
   generate the live key.
3. Paste **Key ID** and **Key Secret** in **Admin → Settings → Payment →
   Razorpay** → Save. Turn **off** Stripe and Flutterwave there unless you
   plan to use them.

**Google Play billing** (in-app coin packs) needs the Play Console account
from step 7 and one product per coin pack; we set it up after the first Play
upload.

## 6. Legal pages — DEV (say the word and I generate them)

Google (OAuth consent + Play Store), Razorpay and Apple all require public
pages: `/privacy`, `/terms`, `/refund`, plus a support email
(`support@bebuapp.in` — create it in Hostinger → Emails). I can draft all
three for an 18+ calling app with coin purchases; you review the wording.

## 7. Google Play Console — YOU (for public release)

1. <https://play.google.com/console> → pay the one-time **$25** → create
   developer account (identity verification takes 1–3 days).
2. **Create app** → name `bebu`, app, free → fill **App content**: privacy
   policy URL, ads (no), target audience **18+**, data safety (I'll give you
   the answers), content rating questionnaire.
3. **Release → Testing → Internal testing → Create release** → upload the
   `.aab` I build → add your testers' emails.
4. **Setup → App integrity → Play app signing**: choose **Use existing key**
   and upload the export I'll prepare, so Play signs with the same key.
5. Link Play to Firebase: Firebase **Project settings → Integrations → Google
   Play → Link** (makes phone OTP silent, enables Play billing verification).

## 8. What I do when you send the values — DEV

1. Change the app package to `in.bebuapp.app`, drop in `google-services.json`.
2. Put the service-account JSON into the backend (admin Settings → General) so
   push notifications and token checks use your project; set the web config in
   the admin panel `.env`; re-create the `admin@bebuapp.in` login in your
   Firebase project (you keep the same password).
3. Save Zego App ID/Sign; point the VPS at `api.bebuapp.in`; rebuild backend
   and admin.
4. Build APK + AAB, then test on a device: Google login, OTP with a test
   number, guest login, a push notification, an audio and a video call, a coin
   purchase in Razorpay test mode.
5. Move the website to `bebuapp.in`, add the legal pages, update the download
   page.

## Checklist of things to send

- [ ] `google-services.json` (downloaded **after** adding both fingerprints)
- [ ] Firebase service-account JSON (private — send directly, not in a public place)
- [ ] Firebase web `firebaseConfig` (6 values)
- [ ] Zego **AppID** and **AppSign**
- [ ] "DNS record added" for `api.bebuapp.in`
- [ ] Razorpay Key ID + Secret (test now, live after KYC)
- [ ] Support email address you want shown in the app and on the site
- [ ] Later: Play Console developer account created
