const User = require("../../models/user.model");
const { computeStatus, normalizeReward } = require("../../util/loginRewards");
const rewards = require("../../util/rewards");

const PUBLIC_URL = () => (process.env.PUBLIC_URL || "").replace(/\/$/, "");

// GET /api/user/rewards/hub — everything the Earn coins screen shows
exports.hub = async (req, res) => {
  try {
    const cfg = rewards.config();
    const user = await User.findById(req.user.userId).select("coins dailyReward fullName nickName profilePic avatar gender age birthDate bio country referralCode referredBy referral rewards createdAt coinsRecharged").lean();
    if (!user) return res.status(200).json({ status: false, message: "User not found." });

    const daily = computeStatus(user.dailyReward, normalizeReward(global.settingJSON && global.settingJSON.dailyReward));
    const checklist = rewards.profileChecklist(user);
    const profileClaimed = !!(user.rewards && user.rewards.profileClaimedAt);

    let code = user.referralCode;
    if (cfg.referral.enabled && !code) code = await rewards.ensureReferralCode(user._id);
    const ageDays = (Date.now() - new Date(user.createdAt).getTime()) / 86400000;
    const canEnterCode = cfg.referral.enabled && !user.referredBy && ageDays <= cfg.referral.codeWindowDays && !(user.coinsRecharged > 0);

    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        balance: user.coins || 0,
        daily: { ...daily, enabled: daily.enabled !== false },
        profile: {
          enabled: cfg.profile.enabled && cfg.profile.coins > 0,
          coins: cfg.profile.coins,
          claimed: profileClaimed,
          checklist,
          done: checklist.filter((c) => c.done).length,
          total: checklist.length,
          canClaim: cfg.profile.enabled && !profileClaimed && checklist.every((c) => c.done),
        },
        referral: {
          enabled: cfg.referral.enabled,
          code: code || "",
          shareUrl: PUBLIC_URL() ? `${PUBLIC_URL()}/invite/${code || ""}` : "",
          inviterCoins: cfg.referral.inviterCoins,
          inviteeCoins: cfg.referral.inviteeCoins,
          purchaseSharePercent: cfg.referral.purchaseSharePercent,
          firstPurchaseOnly: cfg.referral.firstPurchaseOnly,
          codeWindowDays: cfg.referral.codeWindowDays,
          canEnterCode,
          applied: !!user.referredBy,
          stats: { invited: user.referral?.invited || 0, purchases: user.referral?.purchases || 0, earnedCoins: user.referral?.earnedCoins || 0 },
        },
        avatarBonus: { ...cfg.avatarBonus, earned: user.rewards?.avatarBonusCoins || 0 },
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/rewards/profile/claim
exports.claimProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select("coins fullName nickName profilePic avatar gender age birthDate bio country rewards").lean();
    if (!user) return res.status(200).json({ status: false, message: "User not found." });
    const cfg = rewards.config().profile;
    if (!cfg.enabled) return res.status(200).json({ status: false, message: "This reward is turned off right now." });
    if (user.rewards && user.rewards.profileClaimedAt) return res.status(200).json({ status: false, code: "CLAIMED", message: "You already collected this reward." });
    const checklist = rewards.profileChecklist(user);
    if (!checklist.every((c) => c.done)) {
      return res.status(200).json({ status: false, code: "INCOMPLETE", message: "Finish every step first.", data: { checklist } });
    }
    const granted = await rewards.grantProfileReward(user);
    if (!granted) return res.status(200).json({ status: false, code: "CLAIMED", message: "You already collected this reward." });
    return res.status(200).json({ status: true, message: `+${granted.coins} coins! Your profile is complete.`, data: granted });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/rewards/referral/apply  body: { code }
exports.applyReferral = async (req, res) => {
  try {
    const r = await rewards.applyReferral(req.user.userId, req.body && req.body.code);
    return res.status(200).json({ status: r.ok, message: r.message, data: r.ok ? { inviteeCoins: r.inviteeCoins, balance: r.balance, inviterName: r.inviterName } : undefined });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
