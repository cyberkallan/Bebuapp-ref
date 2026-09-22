const mongoose = require("mongoose");

const User = require("../../models/user.model");
const PremiumItem = require("../../models/premiumItem.model");
const History = require("../../models/history.model");
const generateHistoryUniqueId = require("../../util/generateHistoryUniqueId");
const { HISTORY_TYPE } = require("../../types/constant");
const premium = require("../../util/premium");

const STYLE_SLOT = { wallpaper: "wallpaper", font: "font", chatTheme: "chatTheme", callTheme: "callTheme" };

function publicConfig(cfg) {
  return {
    enabled: cfg.enabled,
    name: cfg.name,
    tagline: cfg.tagline,
    passes: cfg.passes.filter((p) => p.isActive),
    features: cfg.features,
  };
}

async function loadUser(req) {
  const userId = new mongoose.Types.ObjectId(req.user.userId);
  const user = await User.findById(userId, `coins isBlock ${premium.PROJECTION}`).lean();
  return { userId, user };
}

// GET /api/user/premium/status — everything the Pro screen needs
exports.status = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const cfg = premium.config();
    const { userId, user } = await loadUser(req);
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });

    const [quota, style, styleCount] = await Promise.all([
      premium.randomMatchQuota(userId),
      premium.resolveStyle(user, cfg),
      PremiumItem.countDocuments({ isActive: true }),
    ]);

    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        config: publicConfig(cfg),
        coins: user.coins || 0,
        premium: premium.summary(user, cfg),
        quota,
        style,
        unlockedStyles: user.unlockedStyles || [],
        styleCount,
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/premium/buy  body: { passKey }
exports.buy = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const cfg = premium.config();
    if (!cfg.enabled) return res.status(200).json({ status: false, message: `${cfg.name} is not available right now.` });
    const pass = cfg.passes.find((p) => p.key === String(req.body?.passKey || "") && p.isActive);
    if (!pass) return res.status(200).json({ status: false, message: "That pass is no longer available." });

    const { userId, user } = await loadUser(req);
    if (!user || user.isBlock) return res.status(200).json({ status: false, message: "Account not allowed to buy a pass." });
    if (user.premium && user.premium.lifetime && cfg.enabled) {
      return res.status(200).json({ status: false, message: "You already have lifetime Pro." });
    }

    const r = await premium.activatePass(userId, pass, { source: "coins" });
    if (!r.ok) return res.status(200).json({ status: false, code: r.code, message: r.message, data: { balance: r.balance, need: r.need } });
    return res.status(200).json({ status: true, message: `${pass.name} activated.`, data: { coins: r.balance, premium: r.premium, pass, price: r.price } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/premium/badge  body: { enabled }
exports.badge = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const enabled = req.body?.enabled === true || req.body?.enabled === "true";
    const updated = await User.findByIdAndUpdate(req.user.userId, { $set: { "premium.badge": enabled } }, { new: true, projection: premium.PROJECTION }).lean();
    if (!updated) return res.status(200).json({ status: false, message: "User does not found." });
    return res.status(200).json({ status: true, message: enabled ? "Golden tick on." : "Golden tick hidden.", data: { premium: premium.summary(updated) } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// GET /api/user/premium/studio — Style Studio catalog priced for this user
exports.studio = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const cfg = premium.config();
    const { user } = await loadUser(req);
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });
    if (!cfg.enabled || !cfg.features.styleStudio) {
      return res.status(200).json({ status: true, message: "Style Studio is turned off.", data: { enabled: false, items: [], style: {}, premium: premium.summary(user, cfg), coins: user.coins || 0 } });
    }
    await premium.seedPremiumItems();
    const pro = premium.isPro(user, cfg);
    const unlocked = new Set(user.unlockedStyles || []);
    const items = await PremiumItem.find({ isActive: true }).sort({ type: 1, sortOrder: 1, coins: 1 }).lean();
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        enabled: true,
        pro,
        coins: user.coins || 0,
        premium: premium.summary(user, cfg),
        style: user.style || {},
        items: items.map((it) => premium.publicItem(it, { pro, unlocked, cfg })),
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/premium/unlock  body: { key }  — buy a style item (or claim a Pro-included one)
exports.unlock = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const cfg = premium.config();
    if (!cfg.enabled || !cfg.features.styleStudio) return res.status(200).json({ status: false, message: "Style Studio is turned off." });
    const key = String(req.body?.key || "").trim();
    if (!key) return res.status(200).json({ status: false, message: "key is required." });

    const { userId, user } = await loadUser(req);
    if (!user || user.isBlock) return res.status(200).json({ status: false, message: "Account not allowed." });
    const item = await PremiumItem.findOne({ key, isActive: true }).lean();
    if (!item) return res.status(200).json({ status: false, message: "This item is no longer available." });

    const pro = premium.isPro(user, cfg);
    if ((user.unlockedStyles || []).includes(key)) {
      return res.status(200).json({ status: true, message: "Already yours.", data: { key, coins: user.coins || 0, price: 0 } });
    }
    if (item.proOnly !== false && !pro) {
      return res.status(200).json({ status: false, code: "PRO_REQUIRED", message: `${cfg.name} is needed for this item.` });
    }
    const price = premium.priceFor(item, pro, cfg);
    const updated = await User.findOneAndUpdate(
      { _id: userId, coins: { $gte: price } },
      { $inc: { coins: -price, coinsSpent: price }, $addToSet: { unlockedStyles: key } },
      { new: true, projection: "coins" }
    ).lean();
    if (!updated) {
      return res.status(200).json({ status: false, code: "INSUFFICIENT_COINS", message: "Not enough coins.", data: { balance: user.coins || 0, need: price - (user.coins || 0) } });
    }
    await PremiumItem.updateOne({ _id: item._id }, { $inc: { unlockCount: 1 } });
    if (price > 0) {
      History.create({
        uniqueId: await generateHistoryUniqueId(),
        type: HISTORY_TYPE.STYLE_UNLOCK,
        userId,
        userCoin: price,
        adminCoin: price,
        reason: `${item.type}:${item.name}`,
        date: new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" }),
      }).catch((e) => console.error("style history:", e.message));
    }
    return res.status(200).json({ status: true, message: price > 0 ? "Unlocked." : "Included with Pro.", data: { key, coins: updated.coins, price } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/premium/apply  body: { type, key }  — key "" resets that slot to the app default
exports.apply = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const cfg = premium.config();
    const type = STYLE_SLOT[String(req.body?.type || "")];
    if (!type) return res.status(200).json({ status: false, message: "type must be wallpaper, font, chatTheme or callTheme." });
    const key = String(req.body?.key || "").trim();

    const { userId, user } = await loadUser(req);
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });

    if (key) {
      if (!cfg.enabled || !cfg.features.styleStudio) return res.status(200).json({ status: false, message: "Style Studio is turned off." });
      const item = await PremiumItem.findOne({ key, type, isActive: true }).lean();
      if (!item) return res.status(200).json({ status: false, message: "This item is no longer available." });
      const pro = premium.isPro(user, cfg);
      const owned = (user.unlockedStyles || []).includes(key) || (pro && cfg.features.freeStyleItems && item.includedInPro);
      if (!owned) return res.status(200).json({ status: false, code: "LOCKED", message: "Unlock this item first." });
    }
    const updated = await User.findByIdAndUpdate(userId, { $set: { [`style.${type}`]: key } }, { new: true, projection: premium.PROJECTION }).lean();
    const style = await premium.resolveStyle(updated, cfg);
    return res.status(200).json({ status: true, message: key ? "Applied." : "Back to default.", data: { style, keys: updated.style } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
