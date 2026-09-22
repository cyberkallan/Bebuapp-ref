const fs = require("fs");
const mongoose = require("mongoose");

const Setting = require("../../models/setting.model");
const User = require("../../models/user.model");
const PremiumItem = require("../../models/premiumItem.model");
const History = require("../../models/history.model");
const { deleteFile } = require("../../util/deletefile");
const { HISTORY_TYPE } = require("../../types/constant");
const premium = require("../../util/premium");

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

function removeUpload(p) {
  if (p && p.startsWith("storage") && fs.existsSync(p)) fs.unlinkSync(p);
}

async function stats() {
  const now = new Date();
  const d7 = new Date(now.getTime() - 7 * 86400000);
  const d30 = new Date(now.getTime() - 30 * 86400000);
  const [activePro, lifetime, expiring7d, passes, styles, itemCount, topStyle] = await Promise.all([
    User.countDocuments({ $or: [{ "premium.lifetime": true }, { "premium.until": { $gt: now } }] }),
    User.countDocuments({ "premium.lifetime": true }),
    User.countDocuments({ "premium.lifetime": { $ne: true }, "premium.until": { $gt: now, $lte: new Date(now.getTime() + 7 * 86400000) } }),
    History.aggregate([
      { $match: { type: HISTORY_TYPE.PREMIUM_PASS } },
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          coins: { $sum: "$userCoin" },
          last7: { $sum: { $cond: [{ $gte: ["$createdAt", d7] }, 1, 0] } },
          coins7: { $sum: { $cond: [{ $gte: ["$createdAt", d7] }, "$userCoin", 0] } },
          last30: { $sum: { $cond: [{ $gte: ["$createdAt", d30] }, 1, 0] } },
          coins30: { $sum: { $cond: [{ $gte: ["$createdAt", d30] }, "$userCoin", 0] } },
        },
      },
    ]),
    History.aggregate([{ $match: { type: HISTORY_TYPE.STYLE_UNLOCK } }, { $group: { _id: null, total: { $sum: 1 }, coins: { $sum: "$userCoin" } } }]),
    PremiumItem.countDocuments({ isActive: true }),
    PremiumItem.findOne({ unlockCount: { $gt: 0 } }).sort({ unlockCount: -1 }).select("name type unlockCount").lean(),
  ]);
  const p = passes[0] || {};
  const s = styles[0] || {};
  return {
    activePro,
    lifetime,
    expiring7d,
    passesSold: p.total || 0,
    passCoins: p.coins || 0,
    passes7d: p.last7 || 0,
    passCoins7d: p.coins7 || 0,
    passes30d: p.last30 || 0,
    passCoins30d: p.coins30 || 0,
    styleUnlocks: s.total || 0,
    styleCoins: s.coins || 0,
    activeItems: itemCount,
    topStyle: topStyle ? `${topStyle.name} (${topStyle.unlockCount})` : "",
  };
}

// GET /api/admin/premium — settings, catalog and stats
exports.get = async (req, res) => {
  try {
    await premium.seedPremiumItems();
    const [setting, items, st] = await Promise.all([currentSetting(), PremiumItem.find().sort({ type: 1, sortOrder: 1, coins: 1 }).lean(), stats()]);
    return res.status(200).json({
      status: true,
      message: "Success",
      data: { settings: premium.normalizePremium(setting?.premium), items, stats: st, defaults: premium.DEFAULTS },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/premium/settings  body: partial premium settings
exports.updateSettings = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });
    const cur = premium.normalizePremium(setting.premium);
    const b = req.body || {};
    const merged = {
      ...cur,
      ...(b.enabled !== undefined ? { enabled: b.enabled } : {}),
      ...(b.name !== undefined ? { name: b.name } : {}),
      ...(b.tagline !== undefined ? { tagline: b.tagline } : {}),
      ...(b.showBadgeToHosts !== undefined ? { showBadgeToHosts: b.showBadgeToHosts } : {}),
      passes: Array.isArray(b.passes) ? b.passes : cur.passes,
      features: { ...cur.features, ...(b.features || {}) },
    };
    const next = premium.normalizePremium(merged);
    if (next.passes.length === 0) return res.status(200).json({ status: false, message: "Keep at least one pass." });
    setting.premium = next;
    setting.markModified("premium");
    await setting.save();
    if (typeof global.updateSettingFile === "function") global.updateSettingFile(setting);
    return res.status(200).json({ status: true, message: next.enabled ? "Pro settings saved." : `${next.name} is now hidden in the app.`, data: next });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// ── catalog ──────────────────────────────────────────────────────────────────

function parseData(raw) {
  if (raw === undefined) return undefined;
  if (typeof raw === "object" && raw !== null) return raw;
  try {
    const v = JSON.parse(String(raw));
    return typeof v === "object" && v !== null ? v : {};
  } catch {
    return undefined;
  }
}

function readBody(body = {}, file) {
  const out = {};
  if (body.name !== undefined) out.name = String(body.name).trim().slice(0, 40);
  if (body.tagline !== undefined) out.tagline = String(body.tagline).trim().slice(0, 80);
  if (body.mood !== undefined) out.mood = String(body.mood).trim().toLowerCase().slice(0, 24);
  if (body.type !== undefined && PremiumItem.TYPES.includes(body.type)) out.type = body.type;
  if (body.coins !== undefined) out.coins = Math.max(0, parseInt(body.coins, 10) || 0);
  if (body.sortOrder !== undefined) out.sortOrder = parseInt(body.sortOrder, 10) || 0;
  if (body.isActive !== undefined) out.isActive = body.isActive === true || body.isActive === "true";
  if (body.includedInPro !== undefined) out.includedInPro = body.includedInPro === true || body.includedInPro === "true";
  if (body.proOnly !== undefined) out.proOnly = body.proOnly === true || body.proOnly === "true";
  if (body.credit !== undefined) out.credit = String(body.credit).trim().slice(0, 120);
  const data = parseData(body.data);
  if (data !== undefined) out.data = data;
  if (file) {
    out.image = file.path;
    out.thumb = file.path;
  }
  return out;
}

// POST /api/admin/premium/item  (multipart; image required for wallpapers)
exports.addItem = async (req, res) => {
  try {
    const data = readBody(req.body, req.file);
    if (!data.type || !data.name) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "type and name are required." });
    }
    if (data.type === "wallpaper" && !data.image) return res.status(200).json({ status: false, message: "Upload a portrait JPG/PNG (2160×3840 recommended) for the wallpaper." });
    if (data.type === "font" && !(data.data && data.data.family)) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "Fonts need data.family (a Google Fonts family name)." });
    }
    const base = data.name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "") || "item";
    let key = `${data.type}_${base}`.toLowerCase();
    let n = 1;
    while (await PremiumItem.exists({ key })) key = `${data.type}_${base}_${++n}`;
    if (data.sortOrder === undefined) {
      const last = await PremiumItem.findOne({ type: data.type }).sort({ sortOrder: -1 }).select("sortOrder").lean();
      data.sortOrder = (last?.sortOrder || 0) + 1;
    }
    const item = await PremiumItem.create({ ...data, key });
    return res.status(200).json({ status: true, message: "Item added.", data: item });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/premium/item?itemId=  (multipart, optional image)
exports.editItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "Valid itemId is required." });
    }
    const item = await PremiumItem.findById(itemId);
    if (!item) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "Item not found." });
    }
    const data = readBody(req.body, req.file);
    delete data.type; // type is fixed once created
    if (data.image && item.image) removeUpload(item.image);
    Object.assign(item, data);
    await item.save();
    return res.status(200).json({ status: true, message: "Item updated.", data: item });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/premium/item/toggle?itemId=
exports.toggleItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) return res.status(200).json({ status: false, message: "Valid itemId is required." });
    const item = await PremiumItem.findById(itemId);
    if (!item) return res.status(200).json({ status: false, message: "Item not found." });
    item.isActive = !item.isActive;
    await item.save();
    return res.status(200).json({ status: true, message: item.isActive ? "Item is live." : "Item hidden.", data: item });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// DELETE /api/admin/premium/item?itemId=
exports.deleteItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) return res.status(200).json({ status: false, message: "Valid itemId is required." });
    const item = await PremiumItem.findById(itemId);
    if (!item) return res.status(200).json({ status: false, message: "Item not found." });
    removeUpload(item.image);
    await Promise.all([
      item.deleteOne(),
      // Users who had it applied fall back to the default look.
      User.updateMany({ [`style.${item.type}`]: item.key }, { $set: { [`style.${item.type}`]: "" } }),
    ]);
    return res.status(200).json({ status: true, message: "Item deleted." });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// ── users ────────────────────────────────────────────────────────────────────

// POST /api/admin/premium/grant  body: { userId, passKey? , days? }
exports.grant = async (req, res) => {
  try {
    const { userId, passKey, days } = req.body || {};
    if (!userId || !mongoose.Types.ObjectId.isValid(userId)) return res.status(200).json({ status: false, message: "Valid userId is required." });
    const cfg = premium.config();
    let pass = cfg.passes.find((p) => p.key === passKey);
    if (!pass) {
      const d = Math.max(0, parseInt(days, 10) || 0);
      pass = { key: d === 0 ? "lifetime" : `custom_${d}d`, name: d === 0 ? "Lifetime Pro" : `${d}-day Pro`, days: d, coins: 0 };
    }
    const r = await premium.activatePass(new mongoose.Types.ObjectId(userId), pass, { source: "admin" });
    if (!r.ok) return res.status(200).json({ status: false, message: r.message });
    return res.status(200).json({ status: true, message: `${pass.name} granted.`, data: r.premium });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/admin/premium/revoke  body: { userId }
exports.revoke = async (req, res) => {
  try {
    const { userId } = req.body || {};
    if (!userId || !mongoose.Types.ObjectId.isValid(userId)) return res.status(200).json({ status: false, message: "Valid userId is required." });
    const s = await premium.revoke(new mongoose.Types.ObjectId(userId));
    if (!s) return res.status(200).json({ status: false, message: "User not found." });
    return res.status(200).json({ status: true, message: "Pro removed.", data: s });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// GET /api/admin/premium/user?userId=
exports.userStatus = async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId || !mongoose.Types.ObjectId.isValid(userId)) return res.status(200).json({ status: false, message: "Valid userId is required." });
    const user = await User.findById(userId, premium.PROJECTION).lean();
    if (!user) return res.status(200).json({ status: false, message: "User not found." });
    return res.status(200).json({
      status: true,
      message: "Success",
      data: { premium: premium.summary(user), raw: user.premium || {}, style: user.style || {}, unlockedStyles: user.unlockedStyles || [], passes: premium.config().passes },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
