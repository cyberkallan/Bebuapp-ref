# bebu admin panel — step-by-step guide

The admin panel is where you run the business: hosts, users, coins, prices,
gifts, payouts, sign-in options and the look of the app. This guide walks
through it in the order you will actually use it. Nothing here needs a
developer.

Open it at `https://<your-domain>/login` (the address you gave the installer).
Sign in with the admin e-mail and password created during installation. Lost
the password? On the server: `cd bebu/deploy && docker compose exec backend node scripts/create-admin.js you@example.com 'NewPassword'`.

---

## 1. First hour after installation

Do these once, top to bottom. Each is a page in the left menu.

| # | Where                                   | What to do                                                                                                                 |
| - | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 1 | **Setting → General**                   | Paste the Firebase *service account* JSON if the installer did not (it usually did). Fill **Zego App ID / App SignIn** from console.zegocloud.com — without them calls will not connect. Set **Support Email**, **Privacy Policy** and **About Us** links. Leave **Application Live** on. |
| 2 | **Setting → General → Rates**           | Coins per minute for **Private Audio / Video** (a user calls a specific host) and **Random Audio / Video** (Random match). Defaults 10/20 and 20/40. |
| 3 | **Setting → General → Admin Commission %** | Your cut of every call. `20` means the host keeps 80 % of the coins spent on them. |
| 4 | **Setting → Currency**                  | The currency shown on coin packs (₹ INR by default). Add more if you sell in several countries; mark one as default.       |
| 5 | **Coin Plan**                           | The packs users can buy: coins, price, Google Play *Product ID* (for in-app purchases), *Popular* badge, *Active* switch. Start with 3–5 packs. |
| 6 | **Setting → Payment**                   | Turn on the gateways you have keys for: **Razorpay** (India), **Stripe**, **Flutterwave**, **Google Play** in-app purchases. Only enabled gateways appear in the app. |
| 7 | **Setting → Withdrawal**                | Minimum coins a host must collect before requesting a payout, and coin → money conversion.                                  |
| 8 | **Payment Option**                      | How you pay hosts (UPI, bank transfer, PayPal…). Each option lists the details a host must fill in.                         |
| 9 | **Talk Topic**                          | Interests hosts pick and users browse (Friendship, Career, Late-night talk…). Starter topics are seeded; edit freely.       |
| 10 | **Identity Proof**                     | Documents a host may upload for verification (Aadhaar, PAN, passport…).                                                    |
| 11 | **Setting → Login & Rewards**          | Which sign-in buttons the app shows (Google, phone OTP, one-tap guest, e-mail), which one is the big hero button, the **welcome bonus** for a new account and the **daily streak coins**. See §5. |
| 12 | **Setting → Appearance**               | Dark / light default palette, accent colour, whether users may choose and whether onboarding asks them.                   |
| 13 | **FAQ**                                 | Questions shown in the app's Help screen.                                                                                 |

After this, open the app on a phone, sign in, buy a test pack (or give
yourself coins under **User → Edit**) and place a call to a host to check
everything end to end.

---

## 2. Dashboard

Top-line numbers for today and the last 30 days: registered users, hosts,
calls, coins bought, coins spent and your commission. The charts refresh on
load; the **Top hosts** and **Recent users** tables link into their profiles.

---

## 3. People

### Users (callers)

**User** lists every account. Search by name, phone or e-mail. Open a row to:

- see wallet balance, purchases, call history and who they talked to;
- **block / unblock** (the *Is Block* switch) — a blocked user cannot sign in;
- delete the account (irreversible; required for store compliance requests).

To test the app with a full wallet, sign in on a phone and buy a coin pack
through a gateway in test mode (Razorpay/Stripe test keys), or temporarily set
a plan's price to the minimum your gateway allows.

### Hosts ("listeners")

Hosts are the people users pay to talk to.

- **Listener → Real hosts**: everyone who applied through the app and was
  approved. Open a host to see earnings, ratings, call minutes, uploaded ID
  proofs, bank/UPI details and to **block** or **edit** the profile and rates.
- **Listener Request**: pending applications. Review the profile, photos and
  ID, then **Accept** or **Reject**.
- **Listener → Fake hosts**: profiles you create yourself to make the app feel
  alive on day one. They can take AI-powered chats (see §6) and never receive
  payouts. Each has a name, nickname, age, location, languages, interests, a
  self-introduction, its own private/random audio and video rates and, for AI,
  a *personality & backstory*, an opening line and extra rules.

Allow or stop new applications with **Setting → General → Allow to become host**.

---

## 4. Money

### Coin plans

**Coin Plan** is the shop. Each plan has coins, price, the Google Play
*Product ID* (for in-app purchases), a *Popular* badge and an *Active*
switch. The app shows plans in price order.
**Coin Plan History** lists every purchase with gateway, amount and status.

### Payouts

Hosts request payouts from the app once they pass the minimum in **Setting →
Withdrawal**. **Payout Request** shows them with the host's chosen payment
option and details. Pay them outside the panel (bank/UPI/PayPal), then mark
**Paid**, or **Reject** with a note — the coins return to the host.

### Gifts

**Gifts** is the virtual-gift catalog and its rules:

- **Gifting enabled** — the master switch. Off hides every gift button,
  bubble and sheet in the app.
- **Host share %** — of a gift's coins the host earns this share; the rest is
  yours. Example: 70 % → a 100-coin gift pays the host 70.
- **Show in chat / Show during calls** — where the gift button appears.
- **AI hosts say thank you** — fake hosts with AI reply to a gift.
- **"Get coins" nudge** — gifts the user cannot afford become a one-tap link to
  the wallet.
- **Catalog** — ten 3D gifts ship by default (rose 5 → rocket 5,000 coins).
  **Add gift** with your own PNG (transparent, ~512 px), name, tagline and
  price; **Edit**, **hide** (eye icon) or delete; the arrows set the order the
  app shows. Hide rather than delete a gift that has already been sent so old
  chat bubbles keep their picture.
- The header shows 7-day totals: gifts sent, coins spent, your platform coins.

### Coins & Rewards

Shortcut to **Setting → Login & Rewards** (§5): welcome bonus and daily streak.

---

## 5. Sign-in & rewards (Setting → Login & Rewards)

Everything the user sees before and right after signing in.

**Sign-in methods** — pick a preset (*Recommended*, *Phone only*, *Google
only*, *Phone + Google*, *Social*, *Everything*) or toggle each method and
choose the **hero button**. Phone OTP needs Firebase Phone auth with billing
enabled and your country in the SMS region policy (see `docs/go-live.md`
§2.4). The phone preview on the right updates live.

**Welcome bonus** — coins credited once when an account is created. `0`
disables it and hides the teaser.

**Daily streak reward** — a gift the user can claim once per day:

- **Enable daily rewards**, **Open automatically** (pop the sheet on Home once
  a day), **Reset streak on a missed day**.
- **Coins per day** — the schedule (default 10, 15, 20, 25, 30, 40, 60 over a
  7-day cycle). Add or remove days; the cycle loops after the last day.
- **Day boundary timezone** — when "tomorrow" starts (Asia/Kolkata by default).

Stats at the top show claims today, active streaks and coins given this week.

---

## 6. AI chat for fake hosts (Setting → AI Chat)

Fake hosts can answer messages automatically, in character, in the host's
language.

1. **Providers** — *Add provider*: pick OpenAI, OpenRouter, Groq or any
   OpenAI-compatible **Base URL**, paste the **API key** and choose the
   **Model**. The card shows *Providers ready*, *Replies today* and *Avg
   latency today*.
2. **Style** — **Default language** (English, Hindi, Malayalam, Tamil, Telugu,
   Kannada, or Manglish / Hinglish written in Latin letters), **Tone**, **Reply
   length**, **Emoji** and **Memory** (how many past messages the host
   remembers). Each fake host can override the language and add its own rules
   in **Listener → Fake hosts → edit**.
3. **When to reply** — **Reply when host is** online / offline / always,
   **Quiet hours** (*From* / *To* in the chosen **Timezone**) when hosts stay
   silent, and daily caps: **Max replies per user / day**, **Max replies total
   / day** (protects your API bill).
4. **Safety** — **Blocked topics**, **Extra rules for every host** and what to
   say **If asked "are you a bot?"**.
5. **Suggest calls during chat** — after **First nudge after** N user messages
   and **Then every** N messages the host invites the user to a paid call.
6. **Playground** — type as a user, pick a host and see the exact reply with
   its token cost before switching AI on.

Real hosts are never answered by AI. Gifts sent to an AI host get a thank-you
reply when **Gifts → AI hosts say thank you** is on.

---

## 7. Look & feel (Setting → Appearance, Avatar Studio)

- **Appearance**: default palette (**Dark** — deep charcoal, photo-first;
  **Light** — soft lavender-white), accent colour, **Let users choose** and
  **Ask during onboarding**. The phone preview shows the result live.
- **Avatar Studio**: the 3D avatar, backgrounds, pets, rides and accessories
  users unlock with coins. Toggle the whole feature, set which items are free
  and price the rest. Bundled items appear automatically; add your own WebP
  renders.

---

## 8. Content

- **FAQ** — Help screen questions and answers.
- **Talk Topic** — interest tags.
- **Identity Proof** — document types hosts can submit.
- **Setting → General** — privacy policy, terms and about-us links opened from
  the app (host them on your website).

---

## 9. Downloads

**Downloads** lists the release bundles stored on your server: the full
source code with your configuration, the marketplace package without any
keys, Android APK/AAB files and documentation. Click **Download**; the link
is private to signed-in admins and valid for 10 minutes. To publish a new
file, copy it into the backend container's `storage/downloads` folder:

```bash
docker cp bebu-1.9.0-arm64-v8a.apk bebu-backend:/app/storage/downloads/
```

An optional `manifest.json` in that folder sets titles and descriptions; a
`SHA256SUMS.txt` adds checksums.

---

## 10. Your account & safety

- **Profile** — change your name, photo and password.
- Add another admin from the server (no sign-up form is exposed):
  `docker compose exec backend node scripts/create-admin.js colleague@example.com 'Password'`.
- **Setting → General → Application Live** — turn off to show a maintenance
  message in the app while you work.
- **Demo Content** — off in production; it hides sample data.
- Back up regularly: `docker compose exec -T mongo mongodump --archive --db bebu > bebu-$(date +%F).archive`
  and copy the `bebu_backend-storage` volume (uploaded photos).

---

## 11. Everyday checklist

| Daily                              | Weekly                                   | Monthly                              |
| ---------------------------------- | ---------------------------------------- | ------------------------------------ |
| Approve **Listener Requests**      | Pay **Payout Requests**                  | Review rates and commission          |
| Glance at **Dashboard** anomalies  | Check **Gifts** 7-day stats              | Rotate AI budget, check token spend  |
| Answer support e-mail              | Refresh fake-host photos / personas      | Database backup off-server           |
