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

    // Daily streak reward: claimed once per calendar day (timezone below).
    // coins[i] is the reward on streak day i+1; the schedule loops after the last day.
    dailyReward: {
      enabled: { type: Boolean, default: true },
      coins: { type: [Number], default: [10, 15, 20, 25, 30, 40, 60] },
      resetStreakOnMiss: { type: Boolean, default: true },
      timezone: { type: String, default: "Asia/Kolkata" },
      autoOpen: { type: Boolean, default: true }, // pop the reward sheet automatically on home when claimable
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
