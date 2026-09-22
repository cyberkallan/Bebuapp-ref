# iOS: building, testing (TestFlight) and shipping bebu to the App Store

**There is no iOS build file (.ipa) in the bundles yet, and there cannot be
one until you have an Apple Developer account.** Apple only lets iOS apps be
compiled and signed on macOS, and only with a certificate issued to a paid
Apple Developer Program member. Android could be built and signed on our
Linux build server; iOS cannot. The iOS *project* is complete and ready
(`bebu/app/ios/`, also in `bebu-app-flutter-1.8.0.zip` on Admin →
Downloads); what remains is a Mac (real or rented) plus your Apple account.

## The shortest path to a phone (no Mac): Codemagic + TestFlight

1. **Apple Developer Program** — enroll at developer.apple.com ($99/year).
   Enrolling as *Elevanza Ltd* (organisation) needs a D-U-N-S number and
   takes a few days; enrolling as an individual is instant. You can transfer
   the app later.
2. **App Store Connect** (appstoreconnect.apple.com):
   - *Certificates, Identifiers & Profiles → Identifiers → +* → App ID
     `in.bebuapp.app`, tick **Push Notifications**.
   - *My Apps → +* → New App: iOS, name **bebu**, bundle ID `in.bebuapp.app`,
     SKU `bebu`.
   - *Users and Access → Integrations → App Store Connect API → +* → role
     **App Manager**. Download the `.p8` key once; note Key ID and Issuer ID.
3. **Codemagic** (codemagic.io, free 500 min/month): sign up with GitHub and
   add the `Bebuapp-ref` repository (the repo must contain this project — see
   the GitHub note in the chat). Codemagic reads `codemagic.yaml` from the
   repo root.
   - *Teams → Integrations → App Store Connect* → upload the `.p8`, Key ID,
     Issuer ID; name it **`bebu_asc`**. Codemagic now creates and stores the
     signing certificate and provisioning profile automatically.
   - *App settings → Environment variables*, group **`bebu_app`**:
     `API_BASE_URL = https://bebu.145.223.79.74.sslip.io/` and
     `API_SECRET_KEY = <SECRET_KEY from bebu/deploy/.env>` (secure).
4. **Start build** → workflow *bebu iOS → TestFlight*. About 20 minutes. The
   `.ipa` appears as a build artifact and is pushed to TestFlight.
5. **Test on iPhones**: in App Store Connect → *TestFlight* the build shows
   up after Apple processes it (5–30 min). Create an *Internal Testing* group
   "bebu testers" and add up to 100 Apple IDs; each tester installs the
   **TestFlight** app from the App Store and gets the build by e-mail
   invitation. Internal testers need no review; *External* testers (up to
   10,000, via a public link) need a one-time light review.
6. **Publish**: App Store Connect → the app → *+ Version* 1.8.0 → pick the
   TestFlight build, fill the listing (§4 below) → *Submit for Review*.

Prefer GitHub Actions instead of Codemagic? `.github/workflows/ios-release.yml`
does the same on GitHub's macOS runners but you must create the certificate
and profile yourself (§3).

## Also possible

- **Your own / a borrowed Mac** with Xcode: §2 below. A free Apple ID can
  install on *your own* iPhone by cable for 7 days at a time — fine for a
  first look, not for testers.
- **Rented Mac in the cloud** (MacinCloud, Scaleway, MacStadium, from ~$30/mo)
  and follow §2 over remote desktop.

What is already prepared in `bebu/app/ios/`:

| Item                          | Value / state                                                                 |
| ----------------------------- | ----------------------------------------------------------------------------- |
| Bundle identifier             | `in.bebuapp.app` (all targets)                                                |
| Display name                  | bebu                                                                          |
| `GoogleService-Info.plist`    | Real config for Firebase project `neocat-ceae7`, iOS app `1:582954571557:ios:…` |
| Google sign-in URL scheme     | `com.googleusercontent.apps.582954571557-…` (from the plist's REVERSED_CLIENT_ID) |
| Permission texts              | Camera, microphone, photo library — App Review requires them                  |
| Background modes              | audio, voip, remote-notification (calls keep running when the screen locks)   |
| Export compliance             | `ITSAppUsesNonExemptEncryption = false` (skips the encryption questionnaire)  |
| Deployment target             | iOS 16.6                                                                      |
| Development team              | *empty* — Xcode fills it when you select your team                            |

## 1. Apple accounts (once) — details

1. **Apple Developer Program** ($99/year) at developer.apple.com — enroll as
   Elevanza Ltd (organisation) so the store shows the company name.
2. **App Store Connect** → *My Apps* → **+ New App**: platform iOS, name
   *bebu*, bundle ID `in.bebuapp.app` (register it first under *Certificates,
   Identifiers & Profiles → Identifiers* with capabilities **Push
   Notifications** and **Sign in with Apple** if you enable it later).
3. **Push notifications key**: *Keys → +*, tick Apple Push Notifications
   service (APNs), download the `.p8`. Upload it in Firebase console →
   Project settings → Cloud Messaging → *Apple app configuration*.

## 2. Build on a Mac (Xcode)

```bash
cd bebu/app
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace          # select your Team under Signing & Capabilities once
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.bebuapp.in/ \
  --dart-define=API_SECRET_KEY=<SECRET_KEY from deploy/.env> \
  --export-method app-store
```

Output: `build/ios/ipa/bebu.ipa`. Upload with **Transporter** (Mac App Store)
or `xcrun altool --upload-app -f build/ios/ipa/bebu.ipa -t ios -u APPLE_ID -p APP_SPECIFIC_PASSWORD`.

## 3. Build in GitHub Actions (manual certificates)

Add these repository secrets (*Settings → Secrets and variables → Actions*):

| Secret                         | What                                                                               |
| ------------------------------ | ---------------------------------------------------------------------------------- |
| `IOS_CERTIFICATE_P12_BASE64`   | Your *Apple Distribution* certificate exported as .p12, base64-encoded             |
| `IOS_CERTIFICATE_PASSWORD`     | Password of that .p12                                                              |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile for `in.bebuapp.app`, base64-encoded            |
| `APPLE_TEAM_ID`                | 10-character team id                                                               |
| `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64` | App Store Connect API key (Users and Access → Integrations) for the upload step |
| `API_BASE_URL`, `API_SECRET_KEY` | Same values as the Android build                                                 |

Then *Actions → iOS release → Run workflow*. It builds the `.ipa`, uploads it
to TestFlight and attaches the file to the run as an artifact. Certificate
and profile creation without a Mac: use *Certificates, Identifiers &
Profiles* in the browser plus `openssl` to produce the CSR and the .p12.

## 4. App Store listing checklist

- Screenshots: 6.7" (1290×2796) and 6.5" (1284×2778) iPhone sets — take them
  from the simulator or a device; the marketing screens under
  `apps/landing/public/screens/` are a starting point.
- App privacy: the app collects contact info (phone/e-mail), user content
  (photos, messages), identifiers, purchases and usage data → declare them.
- **In-app purchases**: coin packs sold inside the iOS app must go through
  Apple IAP. Create the products in App Store Connect with the same product
  IDs as in Admin → Coin Plan; the app's `in_app_purchase` integration reads
  them.
- Age rating 17+ (unrestricted web access / user-generated content with
  chat). Provide a demo host account for the reviewer in *App Review
  Information*.
- Version and build number come from `pubspec.yaml`
  (`version: 1.8.0+17` → 1.8.0 (17)); bump the `+N` for every upload.
