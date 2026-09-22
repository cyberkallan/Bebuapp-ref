const { LOGIN_TYPE } = require("../types/constant");

const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    nickName: { type: String, default: "" },
    fullName: { type: String, default: "" },
    birthDate: { type: String, default: "" },
    gender: { type: String, default: "" },
    bio: { type: String, default: "" },
    age: { type: Number, default: 18 },
    countryCode: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    profilePic: { type: String, default: "" },
    // Avatar Studio look. `active` means the studio avatar is the profile picture.
    avatar: {
      active: { type: Boolean, default: false },
      avatar: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      background: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      pet: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      vehicle: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      home: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      sky: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
      accessory: { type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem", default: null },
    },
    unlockedItems: [{ type: mongoose.Schema.Types.ObjectId, ref: "AvatarItem" }],
    email: { type: String, default: "" },
    password: { type: String, default: "" },
    countryFlag: { type: String, default: "" },
    country: { type: String, trim: true, lowercase: true, default: "" },
    loginType: { type: Number, enum: LOGIN_TYPE }, //1.google 2.quick(identity) 3.mobile-number 4.email-password
    identity: { type: String, default: "" },
    fcmToken: { type: String, default: null },
    uniqueId: { type: String, unique: true, default: "" },

    firebaseId: { type: String, unique: true, default: "" }, //firebase uid
    authProvider: { type: String, default: "" },

    coins: { type: Number, default: 0 },
    coinsSpent: { type: Number, default: 0 },
    coinsRecharged: { type: Number, default: 0 }, //totalTopUp (Total coins the user has topped up)

    isBlock: { type: Boolean, default: false },
    isOnline: { type: Boolean, default: false },
    isBusy: { type: Boolean, default: false },
    isNotificationEnabled: { type: Boolean, default: true },

    callId: { type: String, default: null }, //for videoCall

    isListener: { type: Boolean, default: false },
    listenerId: { type: mongoose.Schema.Types.ObjectId, ref: "Listener", default: null },

    lastlogin: { type: String, default: "" },
    date: { type: String, default: "" },

    // Daily streak reward progress (see controllers/user/dailyReward.controller.js).
    dailyReward: {
      lastClaimDate: { type: String, default: "" }, // YYYY-MM-DD in the configured timezone
      streak: { type: Number, default: 0 },
      bestStreak: { type: Number, default: 0 },
      totalClaims: { type: Number, default: 0 },
      totalCoins: { type: Number, default: 0 },
    },

    // Extra rewards (controllers/user/rewards.controller.js)
    referralCode: { type: String, default: null }, // this user's own invite code (sparse unique index below)
    referredBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    referral: {
      appliedAt: { type: Date, default: null }, // when this user entered someone's code
      invited: { type: Number, default: 0 }, // people who signed up with this user's code
      purchases: { type: Number, default: 0 }, // purchases by invited users that paid out
      earnedCoins: { type: Number, default: 0 },
    },
    rewards: {
      profileClaimedAt: { type: Date, default: null },
      avatarBonusCoins: { type: Number, default: 0 },
    },

    // bebu Pro (util/premium.js). Active while `until` is in the future or lifetime is set.
    premium: {
      until: { type: Date, default: null },
      lifetime: { type: Boolean, default: false },
      planKey: { type: String, default: "" },
      since: { type: Date, default: null }, // first time this user became Pro
      badge: { type: Boolean, default: true }, // user's own switch for the golden tick
      passes: { type: Number, default: 0 }, // passes bought
      coinsSpent: { type: Number, default: 0 },
      grantedBy: { type: String, default: "" }, // "admin" when the last pass came from the panel
    },
    // Style Studio look (keys of PremiumItem rows). Empty = app default.
    style: {
      font: { type: String, default: "" },
      wallpaper: { type: String, default: "" },
      chatTheme: { type: String, default: "" },
      callTheme: { type: String, default: "" },
    },
    unlockedStyles: { type: [String], default: [] },
    // Random match counter for the free daily cap (YYYY-MM-DD in the reward timezone).
    randomMatch: {
      date: { type: String, default: "" },
      count: { type: Number, default: 0 },
    },

    interests: {
      therapyType: { type: String, default: "" },
      gender: { type: String, default: "" },
      ageRange: { type: String, default: "" },
      country: { type: String, default: "" },
      sexualOrientation: { type: String, default: "" },
      religion: { type: String, default: "" },
      takesMedication: { type: Boolean, default: false },
      preferredLanguage: { type: String, default: "" },
      needHelpWith: [{ type: String }],
      communicationType: { type: String, default: "" },
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

userSchema.index({ identity: 1, loginType: 1 });
userSchema.index({ isBlock: 1 });
userSchema.index({ createdAt: -1 });
userSchema.index({ referralCode: 1 }, { unique: true, partialFilterExpression: { referralCode: { $type: "string" } } });
userSchema.index({ referredBy: 1 });
userSchema.index({ "premium.until": 1 });

module.exports = mongoose.model("User", userSchema);
