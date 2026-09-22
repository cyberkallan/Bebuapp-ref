const Setting = require("../../models/setting.model");
const User = require("../../models/user.model");
const History = require("../../models/history.model");
const { HISTORY_TYPE } = require("../../types/constant");
const { LOGIN_METHODS, normalizeLogin, normalizeReward, dayKey } = require("../../util/loginRewards");

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
  return { claimedToday, activeStreaks, weekClaims: week.claims, weekCoins: week.coins };
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
        welcomeCoins: Number(setting.dailyLoginBonusCoins) || 0,
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.PRESETS = PRESETS;
