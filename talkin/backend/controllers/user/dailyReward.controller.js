const User = require("../../models/user.model");
const History = require("../../models/history.model");
const { HISTORY_TYPE } = require("../../types/constant");
const generateHistoryUniqueId = require("../../util/generateHistoryUniqueId");
const { computeStatus, normalizeReward } = require("../../util/loginRewards");

function rewardConfig() {
  return normalizeReward(global.settingJSON && global.settingJSON.dailyReward);
}

// GET /api/user/dailyReward/status
exports.status = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select("coins dailyReward").lean();
    if (!user) return res.status(200).json({ status: false, message: "User not found." });

    const status = computeStatus(user.dailyReward, rewardConfig());
    return res.status(200).json({ status: true, message: "Success", data: { ...status, balance: user.coins } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/dailyReward/claim
exports.claim = async (req, res) => {
  try {
    const cfg = rewardConfig();
    if (!cfg.enabled) {
      return res.status(200).json({ status: false, message: "Daily rewards are turned off right now." });
    }

    const user = await User.findById(req.user.userId).select("coins dailyReward fcmToken").lean();
    if (!user) return res.status(200).json({ status: false, message: "User not found." });

    const status = computeStatus(user.dailyReward, cfg);
    if (!status.canClaim) {
      return res.status(200).json({
        status: false,
        message: "You already collected today's reward. Come back tomorrow!",
        data: { ...status, balance: user.coins },
      });
    }

    // The date guard makes this idempotent under double taps / retries.
    const updated = await User.findOneAndUpdate(
      { _id: user._id, "dailyReward.lastClaimDate": { $ne: status.todayKey } },
      {
        $inc: { coins: status.coins, "dailyReward.totalClaims": 1, "dailyReward.totalCoins": status.coins },
        $set: {
          "dailyReward.lastClaimDate": status.todayKey,
          "dailyReward.streak": status.streak,
          "dailyReward.bestStreak": Math.max(status.streak, status.bestStreak),
        },
      },
      { new: true, select: "coins dailyReward" }
    ).lean();

    if (!updated) {
      const again = computeStatus(user.dailyReward, cfg);
      return res.status(200).json({ status: false, message: "Reward already claimed today.", data: { ...again, balance: user.coins } });
    }

    History.create({
      type: HISTORY_TYPE.DAILY_REWARD,
      uniqueId: await generateHistoryUniqueId(),
      userId: updated._id,
      userCoin: status.coins,
      reason: `Day ${status.day} streak reward`,
      date: new Date().toLocaleString("en-US", { timeZone: cfg.timezone }),
    }).catch((e) => console.error("dailyReward history:", e.message));

    const after = computeStatus(updated.dailyReward, cfg);
    return res.status(200).json({
      status: true,
      message: `+${status.coins} coins collected. Day ${status.day} streak!`,
      data: { ...after, claimed: status.coins, balance: updated.coins },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
