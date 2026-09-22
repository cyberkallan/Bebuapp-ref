const Setting = require("../../models/setting.model");
const User = require("../../models/user.model");
const History = require("../../models/history.model");
const { HISTORY_TYPE } = require("../../types/constant");
const { LOGIN_METHODS, normalizeLogin, normalizeReward, dayKey } = require("../../util/loginRewards");
const { normalizeRewards } = require("../../util/rewards");

// Named combinations the admin can pick with one click. "custom" = whatever the toggles say.
const PRESETS = [
  { id: "recommended", label: "Recommended", hint: "Google hero, phone OTP and one-tap guest below", login: { google: true, phone: true, quick: true, email: false, primary: "google" } },
  { id: "phone", label: "Phone OTP only", hint: "Every account is tied to a verified number", login: { google: false, phone: true, quick: false, email: false, primary: "phone" } },
  { id: "google", label: "Google only", hint: "Fastest sign-in, verified email for free", login: { google: true, phone: false, quick: false, email: false, primary: "google" } },
  { id: "phone_google", label: "Phone + Google", hint: "Two verified paths, no anonymous accounts", login: { google: true, phone: true, quick: false, email: false, primary: "google" } },
  { id: "social", label: "Social only", hint: "Google and one-tap guest, no phone numbers", login: { google: true, quick: true, phone: false, email: false, primary: "google" } },
  { id: "all", label: "Everything", hint: "All four methods including email + password", login: { google: true, phone: true, quick: true, email: true, primary: "google" } },
];

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

function presetFor(login) {
  const hit = PRESETS.find((p) => LOGIN_METHODS.every((m) => p.login[m] === login[m]) && p.login.primary === login.primary);
  return hit ? hit.id : "custom";
}

async function stats(reward) {
  const today = dayKey(new Date(), reward.timezone);
  const since = new Date(Date.now() - 7 * 24 * 3600 * 1000);
  const [claimedToday, activeStreaks, weekAgg] = await Promise.all([
    User.countDocuments({ "dailyReward.lastClaimDate": today }),
    User.countDocuments({ "dailyReward.streak": { $gte: 3 }, "dailyReward.lastClaimDate": { $in: [today, dayKey(new Date(Date.now() - 86400000), reward.timezone)] } }),
    History.aggregate([
      { $match: { type: HISTORY_TYPE.DAILY_REWARD, createdAt: { $gte: since } } },
      { $group: { _id: null, coins: { $sum: "$userCoin" }, claims: { $sum: 1 } } },
    ]),
  ]);
  const week = weekAgg[0] || { coins: 0, claims: 0 };

  // Extra rewards: lifetime totals per type + how many users are referred.
  const sumBy = async (type) => {
    const [row] = await History.aggregate([{ $match: { type } }, { $group: { _id: null, coins: { $sum: "$userCoin" }, count: { $sum: 1 } } }]);
    return row || { coins: 0, count: 0 };
  };
  const [profile, referral, avatarBonus, referredUsers, referralPurchases] = await Promise.all([
    sumBy(HISTORY_TYPE.PROFILE_REWARD),
    sumBy(HISTORY_TYPE.REFERRAL_REWARD),
    sumBy(HISTORY_TYPE.AVATAR_BONUS),
    User.countDocuments({ referredBy: { $ne: null } }),
    User.aggregate([{ $match: { "referral.purchases": { $gt: 0 } } }, { $group: { _id: null, n: { $sum: "$referral.purchases" } } }]),
  ]);
  return {
    claimedToday,
    activeStreaks,
    weekClaims: week.claims,
    weekCoins: week.coins,
    profileClaims: profile.count,
    profileCoins: profile.coins,
    referredUsers,
    referralPurchases: referralPurchases[0]?.n || 0,
    referralCoins: referral.coins,
    avatarBonusUnlocks: avatarBonus.count,
    avatarBonusCoins: avatarBonus.coins,
  };
}

// GET /api/admin/loginRewards
exports.get = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });

    const login = normalizeLogin(setting.login);
    const dailyReward = normalizeReward(setting.dailyReward);
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settingId: setting._id,
        login,
        preset: presetFor(login),
        dailyReward,
        rewards: normalizeRewards(setting.rewards),
        welcomeCoins: Number(setting.dailyLoginBonusCoins) || 0,
        options: { methods: LOGIN_METHODS, presets: PRESETS },
        stats: await stats(dailyReward),
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/loginRewards  body: { preset?, login?, dailyReward?, welcomeCoins? }
exports.update = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });

    const body = req.body || {};

    if (body.preset && body.preset !== "custom") {
      const preset = PRESETS.find((p) => p.id === body.preset);
      if (!preset) return res.status(200).json({ status: false, message: "Unknown preset." });
      setting.login = normalizeLogin({ ...normalizeLogin(setting.login), ...preset.login });
      setting.markModified("login");
    }

    if (body.login && typeof body.login === "object") {
      setting.login = normalizeLogin({ ...normalizeLogin(setting.login), ...body.login });
      setting.markModified("login");
    }

    if (body.dailyReward && typeof body.dailyReward === "object") {
      setting.dailyReward = normalizeReward({ ...normalizeReward(setting.dailyReward), ...body.dailyReward });
      setting.markModified("dailyReward");
    }

    if (body.rewards && typeof body.rewards === "object") {
      const current = normalizeRewards(setting.rewards);
      const merged = {
        profile: { ...current.profile, ...(body.rewards.profile || {}) },
        referral: { ...current.referral, ...(body.rewards.referral || {}) },
        avatarBonus: { ...current.avatarBonus, ...(body.rewards.avatarBonus || {}) },
      };
      setting.rewards = normalizeRewards(merged);
      setting.markModified("rewards");
    }

    if (body.welcomeCoins !== undefined) {
      const n = Math.round(Number(body.welcomeCoins));
      if (Number.isFinite(n) && n >= 0) setting.dailyLoginBonusCoins = n;
    }

    await setting.save();
    global.updateSettingFile(setting);

    const login = normalizeLogin(setting.login);
    return res.status(200).json({
      status: true,
      message: "Login & rewards updated.",
      data: {
        login,
        preset: presetFor(login),
        dailyReward: normalizeReward(setting.dailyReward),
        rewards: normalizeRewards(setting.rewards),
        welcomeCoins: Number(setting.dailyLoginBonusCoins) || 0,
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.PRESETS = PRESETS;
