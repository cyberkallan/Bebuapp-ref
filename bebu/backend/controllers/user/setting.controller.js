const { normalizeLogin, normalizeReward } = require("../../util/loginRewards");
const { normalizeGiftSettings } = require("../../util/gifts");
const { normalizeAppearance } = require("../admin/appearance.controller");

//get setting
exports.fetchAppSettingsData = async (req, res) => {
  try {
    const setting = settingJSON ? settingJSON : null;
    if (!setting) {
      return res.status(200).json({ status: false, message: "Setting does not found." });
    }

    const data = typeof setting.toObject === "function" ? setting.toObject() : { ...setting };
    delete data.aiChat; // provider API keys never leave the server
    data.login = normalizeLogin(data.login);
    data.dailyReward = normalizeReward(data.dailyReward);
    data.gift = normalizeGiftSettings(data.gift);
    data.rewards = require("../../util/rewards").normalizeRewards(data.rewards);
    data.premium = require("../../util/premium").normalizePremium(data.premium);

    return res.status(200).json({ status: true, message: "Success", data });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

//get setting (public, fetched before login: powers the sign-in screen)
exports.getAppConfiguration = async (req, res) => {
  try {
    const setting = settingJSON ? settingJSON : null;
    if (!setting) {
      return res.status(200).json({ status: false, message: "Setting does not found." });
    }

    const dailyReward = normalizeReward(setting.dailyReward);
    const filteredData = {
      userPrivacyPolicyUrl: setting.userPrivacyPolicyUrl,
      isApplicationLive: setting.isApplicationLive,
      login: normalizeLogin(setting.login),
      appearance: normalizeAppearance(setting.appearance),
      welcomeCoins: Number(setting.dailyLoginBonusCoins) || 0,
      dailyReward: { enabled: dailyReward.enabled, coins: dailyReward.coins },
      rewards: require("../../util/rewards").normalizeRewards(setting.rewards),
      premium: (() => {
        const p = require("../../util/premium").normalizePremium(setting.premium);
        return { enabled: p.enabled, name: p.name, tagline: p.tagline, features: p.features };
      })(),
    };

    return res.status(200).json({ status: true, message: "Success", data: filteredData });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
