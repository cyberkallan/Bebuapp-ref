# bebu — installation guide

bebu is a 1-to-1 voice & video calling platform with coin-based billing:
a Flutter app (Android + iOS), a Node.js backend, MongoDB and a Next.js admin
panel. This guide takes a fresh server and a fresh Firebase project to a
working app in about an hour, without touching the code.

```
bebu/
├── app/        Flutter mobile app (users and hosts)
├── backend/    Node.js API + Socket.IO + MongoDB models
├── admin/      Next.js admin panel
├── deploy/     Docker Compose stack + install.sh (start here)
└── INSTALL.md  this file
```

## 0. What you need

| Item                       | Why                                              | Cost                         |
| -------------------------- | ------------------------------------------------ | ---------------------------- |
| A Linux server             | Runs the backend, database and admin panel       | ~$6/month (2 GB RAM is enough to start) |
| A domain name              | `api.yourapp.com` → the server's IP              | ~$10/year                    |
| Firebase project           | Sign-in (Google, phone OTP, guest) and push       | Free; phone SMS needs billing |
| ZegoCloud account          | Voice & video call infrastructure                | Free tier (10,000 min/month) |
| A payment gateway          | Selling coin packs: Razorpay, Stripe, Flutterwave or Google Play | Per-transaction fees |
| Flutter SDK on your computer | Building the Android/iOS app                   | Free                         |

Tested with Ubuntu 22.04 / 24.04 and Debian 12, Docker 24+, Flutter 3.27+.

## 1. Server: one command

1. Create the server and point your domain's **A record** at its IP.
2. Install Docker: `curl -fsSL https://get.docker.com | sh`
3. Copy the `bebu` folder to the server (e.g. `scp -r bebu root@SERVER:/opt/`),
   or `git clone` your repository there.
4. Run the installer:

```bash
cd /opt/bebu/deploy
./install.sh
```

It asks for:

- **Address** — `api.yourapp.com` (automatic HTTPS) or `http://SERVER-IP` for a trial.
- **Firebase web config** — paste the `firebaseConfig` block from Firebase
  console → Project settings → *Your apps* → Web app (*Add app* if none).
- **Firebase service account** — the `.json` from Project settings → Service
  accounts → *Generate new private key*. Upload it to the server first
  (`scp key.json root@SERVER:/opt/bebu/deploy/`) and give its path.
- **ZegoCloud AppID / ServerSecret** — optional now, editable later in the panel.
- **Your admin e-mail and password.**

Then it builds the containers (3–6 minutes), seeds starter content and prints
your admin URL. Re-running `./install.sh` keeps existing values as defaults.

### Firebase: enable sign-in methods

In Firebase console → **Authentication → Sign-in method** enable:

- **Email/Password** — the admin panel signs in with it.
- **Google** — "Continue with Google" in the app.
- **Phone** — OTP sign-in. Add your country under **Settings → SMS region
  policy** (*Allow only* your countries) and link a billing account for real
  SMS; test numbers under *Phone numbers for testing* work without it.
- **Anonymous** — one-tap guest accounts.

Add your domain (`api.yourapp.com`) under **Authentication → Settings →
Authorized domains**.

## 2. Admin panel: first settings

Open `https://api.yourapp.com/login`, sign in, then follow **§1 of
`docs/admin-guide.md`** (Zego keys, rates, coin plans, payment gateways,
payout options, topics). Ten minutes.

## 3. The mobile app

### 3.1 Register the Android app in Firebase

Firebase console → Project settings → *Your apps* → **Add app → Android**:

- Package name: `in.bebuapp.app` — or your own; if you change it, also change
  `applicationId` in `app/android/app/build.gradle`.
- Download **google-services.json** into `app/android/app/`.
- Add your signing key's **SHA-1 and SHA-256** (needed for Google sign-in and
  phone OTP). Get them with `keytool -list -v -keystore your.jks`.

### 3.2 Create a signing key (once)

```bash
cd app/android
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
cp key.properties.example key.properties   # then fill storeFile/passwords/alias
```

Keep `release.jks` and `key.properties` private and backed up: the Play Store
identifies your app by this key forever.

### 3.3 Build

```bash
cd app
flutter pub get
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=https://api.yourapp.com/ \
  --dart-define=API_SECRET_KEY=<SECRET_KEY from deploy/.env>
```

`API_BASE_URL` must end with `/`. APKs land in
`build/app/outputs/flutter-apk/`. For the Play Store build an app bundle
instead: `flutter build appbundle --release` with the same `--dart-define`s →
`build/app/outputs/bundle/release/app-release.aab`.

Alternatively hard-code the two values as the defaults in
`app/lib/utils/api.dart` and build without `--dart-define`.

### 3.4 iOS

See `docs/ios-release.md`: register the iOS app in Firebase (bundle id
`in.bebuapp.app`), put `GoogleService-Info.plist` in `app/ios/Runner/`, then
`flutter build ipa` on a Mac or in the included GitHub Actions workflow.

## 4. Going live checklist

- [ ] Real domain with HTTPS (the installer's Caddy does this automatically).
- [ ] Firebase phone auth: billing linked, SMS region policy set.
- [ ] Play Console: upload the `.aab`, link the app to Firebase (**Play
      Integrity**) so OTP works silently; see `docs/play-store.md`.
- [ ] Payment gateway switched from test to live keys in **Settings → Payment**.
- [ ] Privacy policy and terms pages published; links set in **Settings → General**.
- [ ] Backups: `docker compose exec -T mongo mongodump --archive --db bebu > backup.archive`.

## 5. Day-to-day server commands

Run from `deploy/`:

| Task                              | Command                                                                     |
| --------------------------------- | --------------------------------------------------------------------------- |
| Status                            | `docker compose ps`                                                         |
| Backend log                       | `docker compose logs -f backend`                                            |
| Update after changing code        | `docker compose up -d --build`                                              |
| Add / reset an admin              | `docker compose exec backend node scripts/create-admin.js me@x.com 'Pass'`   |
| Database shell                    | `docker compose exec mongo mongosh bebu`                                    |
| Publish a file on Admin → Downloads | `docker cp file.zip bebu-backend:/app/storage/downloads/`                  |

## 6. Behind an existing reverse proxy (advanced)

If ports 80/443 on the server already belong to another web server (nginx,
Traefik, another Caddy), answer **yes** to the installer's *advanced* question
and give the Docker network of that proxy. bebu then exposes no public ports;
forward your domain to the container `bebu-edge:80` on that network. In Caddy
that is:

```
api.yourapp.com {
	reverse_proxy bebu-edge:80
}
```

## 7. Troubleshooting

| Symptom                                                    | Fix                                                                                              |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Backend restarts, log says *No Firebase service account*   | Put the service-account JSON at `deploy/firebase-service-account.json`, `docker compose restart backend`. |
| Admin login: *Authentication failed on server*             | The admin's Firebase user and the Admin record are out of sync: re-run `create-admin.js`.       |
| Admin login: *auth/invalid-api-key*                        | Firebase web config in `.env` is wrong → fix and `docker compose up -d --build admin`.           |
| App: *This sign-in method is not enabled yet* on phone OTP | Firebase → Authentication → Settings → SMS region policy: add your country.                     |
| App: *BILLING_NOT_ENABLED* on phone OTP                    | Link a billing account to the Firebase project (Blaze plan).                                    |
| Calls connect but no audio/video                           | Zego App ID / App Sign missing or wrong in **Settings → General**.                              |
| HTTPS certificate not issued                               | DNS A record not pointing at this server yet, or port 80/443 blocked by a firewall.             |
| `Bind for 0.0.0.0:80 failed`                               | Another web server owns the port: use edge mode (§6) or change `HTTP_BIND`/`HTTPS_BIND` in `.env`. |

Everything the panel can do is described in `docs/admin-guide.md`.
