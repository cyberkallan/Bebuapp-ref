# AI chat for fake hosts

Fake hosts (listeners with `isFake: true`) reply to user messages automatically, in the
language and personality the admin assigns. This document is the plan and the reference
for how it works, what it costs (nothing, on free tiers) and how to operate it.

## Goals

- A user who messages a Kerala fake host gets a natural Manglish reply within a few
  seconds, as if a real person typed it.
- Admin picks the language per host (Manglish, Malayalam, English, Hindi, Hinglish,
  Tamil, Tanglish, Telugu, Tenglish, Kannada, Kanglish, Marathi, Bengali, Gujarati,
  Punjabi, Arabic, Spanish, French) and a personality.
- Zero AI bill: only free-tier providers, with automatic failover when one is
  rate-limited, and daily caps so we never go over quota.
- Nothing in the mobile app changes. Replies arrive through the same
  `messageDispatched` socket event and FCM push the app already handles.

## Free providers (verified Sept 2026)

All of these are OpenAI-compatible, so one client covers them. The admin can add any
number in priority order; the first healthy one answers.

| Provider | Free tier | Best for | Key |
| --- | --- | --- | --- |
| Groq | No card. 30 req/min. ~1,000 req/day on `llama-3.3-70b-versatile`, ~14,400/day on `llama-3.1-8b-instant` | Speed (sub-second), primary | console.groq.com/keys |
| Google Gemini | No card. Daily quota per model, `gemini-2.5-flash-lite` is the generous one; check AI Studio | Best Malayalam/Tamil/Kannada quality, backup | aistudio.google.com/apikey |
| Cerebras | No card. ~30 req/min, ~1M tokens/day | Very fast backup | cloud.cerebras.ai |
| OpenRouter | No card. 20 req/min, 50 req/day (1,000/day after a one-time $10 top-up) | Last resort, many `:free` models | openrouter.ai/keys |
| Mistral | Free experiment tier (~1B tokens/month) | Backup | console.mistral.ai |
| Custom / Ollama | Anything OpenAI-compatible you host | Truly unlimited if you run it | – |

Recommended chain: **Groq → Gemini → Cerebras**. Quotas are per account, so one key per
provider is enough; more keys do not add quota.

Free tiers are not guaranteed and change over time. The admin panel shows today's usage,
per-provider failures and cooldowns so you notice before users do.

## How a reply happens

1. User sends a message to a fake host. `socket.js` stores it and relays it as before.
2. If `senderRole=user` and `receiverRole=listener`, the socket calls
   `aiChat.onIncomingMessage(...)` without waiting for it.
3. The service checks, in order: global switch on; the receiver is a fake, unblocked
   host; the host's AI profile is not disabled; host is online if "reply only while
   online" is set; not inside quiet hours; per-user and global daily caps not hit.
4. If a reply is already being typed for that conversation, the new message is queued
   and answered once afterwards with fresh context (no reply spam).
5. Last N messages of the conversation are loaded (photos and voice notes become
   `[sent a photo]` / `[sent a voice note]`) and turned into a chat transcript.
6. A system prompt is built from: host name/age/intro/location/talk topics, the
   admin-written persona, the language style guide, tone, length and emoji rules,
   safety rules, blocked topics, custom rules, call-nudge instruction (only on the
   configured cadence) and basic facts about the user.
7. Providers are tried in order. A 429/5xx/timeout puts that provider in a 60 s
   cooldown and the next one is used. If all fail, the language's fallback line is
   sent (if enabled).
8. A human-feeling delay: random `typingDelayMin..Max` seconds plus a little per
   character, capped at 25 s. Long replies can be split into two bubbles.
9. The reply is stored as a `Chat` from the host, `ChatTopic.chatId` is updated, the
   `messageDispatched` event is emitted to both rooms, and an FCM push is sent to the
   user with the same payload shape the app already understands.
10. Usage counters (`AiUsage`) and a 7-day reply log (`AiReplyLog`) are updated.

## Data model

- `Setting.aiChat` — global configuration (see fields in `models/setting.model.js`).
  Provider API keys live here and are removed from every app-facing settings
  endpoint (`fetchAppSettingsData`, `retrieveAppSettingsData`).
- `ListenerAiProfile` — per host: `enabled`, `language`, `tone`, `persona`,
  `interests`, `openingLine`, `callNudge` (inherit/on/off), `extraRules`, counters.
  Separate collection so nothing leaks into listener payloads sent to the app.
- `AiUsage` — one row per day+provider+model: replies, failures, tokens, latency.
- `AiReplyLog` — recent replies for the admin log, TTL 7 days.

## Admin API (`/api/admin/aiChat`, admin JWT + secret key)

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/config` | Config (keys masked), languages, tones, provider presets, cooldowns |
| PATCH | `/config` | Update any subset. Masked/empty key keeps the stored one; `clearKey: true` removes it |
| POST | `/testProvider` | One tiny completion to verify key + model |
| POST | `/playground` | Generate a reply for a host/persona without touching real chats |
| GET | `/usage?days=14` | Today's totals, per-day and per-provider breakdown, top hosts, recent log |
| GET/PATCH | `/listenerProfile?listenerId=` | Read/upsert a host persona |
| POST | `/assignLanguage` | Bulk set language (and enable) for many hosts |

## Admin panel

- **Settings → AI Chat**: master switch, overview cards (replies today, hosts with AI,
  providers ready, latency), provider chain editor with test button and "get a free
  key" links, default language/tone/identity/length/emoji, typing delay slider, memory,
  two-bubble split, online-only, daily caps, quiet hours, call-nudge cadence, blocked
  topics, custom rules, fallback toggle, model parameters, a live **Playground** that
  shows which provider answered and the exact prompt, and a **Usage** panel.
- **Listeners → Fake tab**: new "AI Chat" column (language chip, reply count), robot
  action opening the **AI persona** dialog (language, tone, personality with templates,
  interests, call nudge, opening line, extra rules), and bulk "Assign AI language" for
  selected rows.

## Operating it

1. Create a free Groq key and a free Gemini key (no card).
2. Settings → AI Chat → add Groq, paste key, Test connection. Add Gemini the same way.
3. Set default language (Manglish for the Kerala hosts), tone, and turn the switch on.
4. Listeners → Fake → select the Kerala hosts → Assign AI language → Manglish. Open a
   few personas and write a short backstory each; the Playground shows the result.
5. Watch the Usage panel for the first day. If Groq shows 429 failures, lower
   "Max replies total / day" or add Cerebras as a third provider.

## Safety defaults baked into every prompt

No phone numbers, socials or moving off-app; never ask for money or recharges directly;
PG-13 only; caring, helpline-oriented response to distress; blocked topics are steered
away from; admin decides whether hosts stay in character or answer honestly when asked
if they are a bot.

## Not in this slice

- Voice-note or image generation by hosts (text only).
- Proactive "good morning" messages / re-engagement pings from hosts.
- Per-host provider or model selection (global chain only).
- Multi-instance coordination of the in-memory cooldown and in-flight sets (single
  backend instance today; move to Redis if the backend is scaled out).
