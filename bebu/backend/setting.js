// Defaults used only when the database has no Settings document yet (first
// boot). Everything here is editable in Admin → Settings afterwards; the
// backend rewrites this file whenever settings change. Secrets (Firebase
// service account, ZegoCloud, payment keys) are never stored here by default:
// see deploy/.env.example and deploy/firebase-service-account.json.
module.exports = {
  currency: {
    name: "Rupee",
    symbol: "₹",
    countryCode: "IN",
    currencyCode: "INR",
    isDefault: true,
  },
  privacyPolicyUrl: "https://bebuapp.in/privacy",
  termsOfUseUrl: "https://bebuapp.in/terms",
  userPrivacyPolicyUrl: "https://bebuapp.in/privacy",
  listenerPrivacyPolicyUrl: "https://bebuapp.in/privacy",
  aboutUsUrl: "https://bebuapp.in",
  helpdeskEmail: "support@bebuapp.in",

  isGooglePlayEnabled: false,
  isStripeEnabled: false,
  isRazorpayEnabled: false,
  isFlutterwaveEnabled: false,

  isApplicationLive: true,
  isDemoContentEnabled: false,
  allowBecomeHostOption: true,

  dailyLoginBonusCoins: 20,
  adminCommissionPercent: 20,
  minimumCoinsForConversion: 100,
  minimumCoinsForPayout: 10,
  videoCallRatePrivate: 20,
  audioCallRatePrivate: 10,
  videoCallRateRandom: 40,
  audioCallRateRandom: 20,
};
