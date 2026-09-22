const mongoose = require("mongoose");

const settingSchema = new mongoose.Schema(
  {
    userPrivacyPolicyUrl: { type: String, default: "PRIVACY POLICY LINK" },
    listenerPrivacyPolicyUrl: { type: String, default: "PRIVACY POLICY LINK" },
    aboutUsUrl: { type: String, default: "ABOUT US LINK" },

    isGooglePlayEnabled: { type: Boolean, default: false },

    isStripeEnabled: { type: Boolean, default: false },
    stripePublicKey: { type: String, default: "STRIPE PUBLISHABLE KEY" },
    stripeSecretKey: { type: String, default: "STRIPE SECRET KEY" },

    isRazorpayEnabled: { type: Boolean, default: false },
    razorpayKeyId: { type: String, default: "RAZOR PAY ID" },
    razorpayKeySecret: { type: String, default: "RAZOR SECRET KEY" },

    isFlutterwaveEnabled: { type: Boolean, default: false },
    flutterwavePublicKey: { type: String, default: "FLUTTER WAVE ID" },

    zegoAppId: { type: String, default: "ZEGO APP ID" },
    zegoAppSignIn: { type: String, default: "ZEGO APP SIGN IN" },

    dailyLoginBonusCoins: { type: Number, default: 0 },
    isDemoContentEnabled: { type: Boolean, default: false },

    isApplicationLive: { type: Boolean, default: true },

    helpdeskEmail: { type: String, default: "" },

    currency: {
      name: { type: String, default: "" },
      symbol: { type: String, default: "" },
      countryCode: { type: String, default: "" },
      currencyCode: { type: String, default: "" },
      isDefault: { type: Boolean, default: false },
    }, //default currency

    privateKey: { type: Object, default: {} }, //firebase.json handle notification

    allowBecomeHostOption: { type: Boolean, default: false }, //to control whether an option for users to become a host is available in the app

    adminCommissionPercent: { type: Number, default: 0 }, // in %
    minimumCoinsForConversion: { type: Number, default: 0 }, //minimum coin requried for convert coin to default currency i.e., 1000 coin = 1 $
    minimumCoinsForPayout: { type: Number, default: 0 }, //minimum coins to request payout for listener

    videoCallRatePrivate: { type: Number, default: 0 },
    audioCallRatePrivate: { type: Number, default: 0 },
    videoCallRateRandom: { type: Number, default: 0 },
    audioCallRateRandom: { type: Number, default: 0 },

    // App look & feel, controlled from the admin panel and applied by the
    // mobile app at launch (see docs/appearance.md).
    appearance: {
      defaultTheme: { type: String, default: "dark" }, // dark | light | system
      allowUserThemeChoice: { type: Boolean, default: true },
      askThemeOnOnboarding: { type: Boolean, default: true },
      accent: { type: String, default: "pink" }, // pink | violet | coral | ocean | mint | sunset
      ambientGlow: { type: Boolean, default: true },
      motion: { type: String, default: "full" }, // full | reduced
      cornerStyle: { type: String, default: "rounded" }, // rounded | soft | sharp
      liveRings: { type: Boolean, default: true },
      coinAnimation: { type: Boolean, default: true },
      soundEffects: { type: Boolean, default: true },
      chatSounds: { type: Boolean, default: true }, // WhatsApp-style sent / received / recording tones in chat
      haptics: { type: Boolean, default: true }, // vibration feedback on taps, sends, unlocks
    },

    // Sign-in methods offered by the app and which one is the hero button.
    // Presets in the admin panel just write these flags (see docs/login-rewards.md).
    login: {
      quick: { type: Boolean, default: true }, // anonymous one-tap login
      google: { type: Boolean, default: true },
      phone: { type: Boolean, default: true }, // Firebase phone OTP
      email: { type: Boolean, default: false }, // email + password
      primary: { type: String, default: "google" }, // google | phone | quick | email
      showWelcomeBonus: { type: Boolean, default: true }, // "Get X free coins" teaser on the sign-in screen
      requireConsentCheckbox: { type: Boolean, default: false }, // false = implicit "By continuing you agree"
      headline: { type: String, default: "" }, // optional override for the sign-in headline
    },

    // Virtual gifts users send hosts from chat or during a call (see docs/gifts.md).
    // Hidden everywhere in the app when enabled is false.
    gift: {
      enabled: { type: Boolean, default: true },
      hostSharePercent: { type: Number, default: 70 }, // % of the gift's coins credited to the host; the rest is platform revenue
      showInChat: { type: Boolean, default: true },
      showInCall: { type: Boolean, default: true },
      aiThankYou: { type: Boolean, default: true }, // AI-powered fake hosts reply to a gift
      minBalanceHint: { type: Boolean, default: true }, // show "top up" nudge on gifts the user can't afford yet
    },

    // Daily streak reward: claimed once per calendar day (timezone below).
    // coins[i] is the reward on streak day i+1; the schedule loops after the last day.
    dailyReward: {
      enabled: { type: Boolean, default: true },
      coins: { type: [Number], default: [10, 15, 20, 25, 30, 40, 60] },
      resetStreakOnMiss: { type: Boolean, default: true },
      timezone: { type: String, default: "Asia/Kolkata" },
      autoOpen: { type: Boolean, default: true }, // pop the reward sheet automatically on home when claimable
    },

    // Extra coin rewards (see docs/rewards.md). All amounts admin-controlled;
    // a disabled block hides its card in the app's Earn coins screen.
    rewards: {
      profile: {
        enabled: { type: Boolean, default: true },
        coins: { type: Number, default: 25 }, // once, when name + photo + gender + age + bio are filled
      },
      referral: {
        enabled: { type: Boolean, default: true },
        inviterCoins: { type: Number, default: 20 }, // when an invited user signs up with the code
        inviteeCoins: { type: Number, default: 0 }, // optional bonus for the new user who enters a code
        purchaseSharePercent: { type: Number, default: 40 }, // % of an invited user's purchased coins credited to the inviter
        firstPurchaseOnly: { type: Boolean, default: true },
        codeWindowDays: { type: Number, default: 7 }, // a new user may enter a code this long after signing up
      },
      avatarBonus: {
        enabled: { type: Boolean, default: true },
        percent: { type: Number, default: 5 }, // bonus = clamp(round(price * percent / 100), minCoins, maxCoins)
        minCoins: { type: Number, default: 4 },
        maxCoins: { type: Number, default: 10 },
      },
    },

    // bebu Pro: time-limited passes bought with coins (see docs/premium.md).
    // When enabled is false nothing Pro-related is shown anywhere in the app.
    premium: {
      enabled: { type: Boolean, default: true },
      name: { type: String, default: "bebu Pro" },
      tagline: { type: String, default: "Unlimited matching, golden tick, exclusive looks." },
      passes: {
        type: [
          {
            key: { type: String, default: "" }, // stable id: week, month, year, lifetime
            name: { type: String, default: "" },
            days: { type: Number, default: 7 }, // 0 = lifetime
            coins: { type: Number, default: 0 },
            badge: { type: String, default: "" }, // "Best value", "Popular"
            isActive: { type: Boolean, default: true },
          },
        ],
        default: [
          { key: "week", name: "1 week pass", days: 7, coins: 499, badge: "", isActive: true },
          { key: "month", name: "1 month pass", days: 30, coins: 1499, badge: "Popular", isActive: true },
          { key: "year", name: "1 year pass", days: 365, coins: 9999, badge: "Best value", isActive: true },
        ],
      },
      features: {
        unlimitedRandomMatch: { type: Boolean, default: true },
        freeRandomMatchesPerDay: { type: Number, default: 5 }, // cap for non-Pro users; 0 = no cap for anyone
        goldenTick: { type: Boolean, default: true }, // Pro users may show the golden verified tick
        proAvatarItems: { type: Boolean, default: true }, // avatar items flagged includedInPro unlock free for Pro
        proGifts: { type: Boolean, default: true }, // gifts flagged tier "pro" can only be sent by Pro users
        styleStudio: { type: Boolean, default: true }, // fonts, wallpapers, chat themes, call templates
        freeStyleItems: { type: Boolean, default: true }, // items flagged includedInPro cost 0 for Pro users
      },
      showBadgeToHosts: { type: Boolean, default: true }, // hosts see the tick on Pro users in chat / calls
    },

    // Avatar Studio: 3D avatar + scene items users unlock with coins.
    // When disabled the app falls back to photo upload + 3 male / 3 female presets.
    avatarStudio: {
      enabled: { type: Boolean, default: true },
      allowPhotoUpload: { type: Boolean, default: true },
    },

    // AI auto-replies for fake hosts. Provider API keys live here and are
    // stripped from every app-facing settings response.
    aiChat: {
      enabled: { type: Boolean, default: false },
      providers: {
        type: [
          {
            preset: { type: String, default: "groq" }, // groq | gemini | openrouter | cerebras | mistral | custom
            label: { type: String, default: "" },
            baseUrl: { type: String, default: "" },
            apiKey: { type: String, default: "" },
            model: { type: String, default: "" },
            enabled: { type: Boolean, default: true },
          },
        ],
        default: [],
      },
      defaultLanguage: { type: String, default: "manglish" },
      tone: { type: String, default: "warm" }, // warm | playful | caring | flirty | professional
      replyLength: { type: String, default: "short" }, // short | medium
      emojiLevel: { type: String, default: "light" }, // none | light | expressive
      identityRule: { type: String, default: "stay_in_character" }, // stay_in_character | honest
      memoryMessages: { type: Number, default: 12 },
      typingDelayMinSec: { type: Number, default: 2 },
      typingDelayMaxSec: { type: Number, default: 7 },
      splitLongReplies: { type: Boolean, default: true },
      replyWhen: { type: String, default: "always" }, // always | online
      quietHoursEnabled: { type: Boolean, default: false },
      quietStart: { type: String, default: "01:00" },
      quietEnd: { type: String, default: "07:00" },
      timezone: { type: String, default: "Asia/Kolkata" },
      maxRepliesPerUserPerDay: { type: Number, default: 80 },
      maxRepliesPerDay: { type: Number, default: 3000 },
      callNudgeEnabled: { type: Boolean, default: true },
      callNudgeAfterMessages: { type: Number, default: 6 },
      callNudgeEveryMessages: { type: Number, default: 6 },
      blockedTopics: { type: [String], default: ["politics", "religion debates", "self-harm instructions", "explicit sexual content"] },
      customRules: { type: String, default: "" },
      fallbackEnabled: { type: Boolean, default: true },
      temperature: { type: Number, default: 0.85 },
      maxTokens: { type: Number, default: 180 },
      timeoutMs: { type: Number, default: 20000 },
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

settingSchema.index({ createdAt: -1 });

module.exports = mongoose.model("Setting", settingSchema);
