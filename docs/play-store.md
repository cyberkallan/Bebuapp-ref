# Google Play: uploading bebu

Everything Play Console needs is in the release bundle:

| File                                   | Use                                                              |
| -------------------------------------- | ---------------------------------------------------------------- |
| `bebu-1.8.0.aab`                       | **Upload this** — Play Console → Production (or Internal testing) → Create release |
| `bebu-1.8.0-arm64-v8a.apk`, `…-armeabi-v7a.apk` | Side-loading / your website; not accepted by Play          |
| `SHA256SUMS.txt`                       | Integrity check for the files above                              |
| `app/android/bebu-release.jks` + `key.properties` | The upload key the bundle is signed with (production package only) |

Package name `in.bebuapp.app`, version 1.8.0 (versionCode 17). The `.aab`
contains all three ABIs; Play generates per-device APKs itself.

## 1. Create the app (once)

1. play.google.com/console → **Create app** → name *bebu*, default language,
   *App*, *Free* (coins are in-app products).
2. **Play App Signing** is on by default: Google keeps the final signing key,
   you upload with `bebu-release.jks`. Keep that keystore safe; if you lose it
   request an upload-key reset in Console.
3. **Set up your app** checklist: privacy policy URL (bebuapp.in/privacy),
   app access (provide a demo host login for reviewers), ads (no), content
   rating questionnaire (social / user-generated content → 17+/Mature),
   target audience (18+), news app (no), data safety (see §3), government
   app (no), financial features (no).

## 2. First release

1. **Testing → Internal testing → Create new release** → upload `bebu-1.8.0.aab`.
2. Release notes: paste from `releases/notes.json` (the *Gifts* and *Login*
   items).
3. Add testers (e-mail list), roll out, install from the opt-in link and
   check sign-in, a call and a coin purchase.
4. Promote the same release to **Production** when happy.

## 3. Data safety form

Declare: **Personal info** (name, e-mail, phone), **Photos**, **Messages**
(chat), **Audio** (calls, voice notes — not stored beyond delivery), **App
activity**, **Device IDs** (push token), **Purchases**. All *collected*, some
*shared* with Firebase (auth, push) and ZegoCloud (call media). Data is
encrypted in transit; users can request deletion (Profile → Delete account).

## 4. In-app purchases

Coin packs bought inside the Android app must use Google Play Billing:

1. **Monetise → Products → In-app products → Create product** for each pack.
   Product ID exactly as in Admin → Coin Plan (e.g. `coins_500`), price in
   your currency.
2. Turn on **Admin → Settings → Payment → Enable Google Play**.
3. Play Billing only works on builds installed from Play (internal testing is
   enough) with a licence-tester account — add yours under **Setup → Licence
   testing**.

## 5. Firebase ↔ Play link (silent phone OTP)

Firebase console → Project settings → Integrations → **Google Play → Link**.
Then Play Console → **Setup → App integrity** confirms *Play Integrity API*
linked. Phone OTP stops showing a reCAPTCHA page and verifies silently.
Also make sure the **App signing key certificate** SHA-256 shown in Play
Console (Setup → App signing) is added to the Firebase Android app — Google
re-signs the bundle with that key.

## 6. Updating

Bump `version:` in `app/pubspec.yaml` (`1.8.1+18` — the number after `+` must
grow), build again, upload the new `.aab` to a new release. Users update
through Play; side-loaded APKs must be re-downloaded.
