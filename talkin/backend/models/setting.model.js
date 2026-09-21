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
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

settingSchema.index({ createdAt: -1 });

module.exports = mongoose.model("Setting", settingSchema);
