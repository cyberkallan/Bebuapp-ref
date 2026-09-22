const fs = require("fs");
const mongoose = require("mongoose");

const Gift = require("../../models/gift.model");
const History = require("../../models/history.model");
const Setting = require("../../models/setting.model");
const { deleteFile } = require("../../util/deletefile");
const { HISTORY_TYPE } = require("../../types/constant");
const { SETTING_DEFAULTS, normalizeGiftSettings, seedGifts } = require("../../util/gifts");

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

function removeUpload(image) {
  if (image && image.startsWith("storage") && fs.existsSync(image)) fs.unlinkSync(image);
}

// GET /api/admin/gift — settings, catalog and 7-day usage
exports.get = async (req, res) => {
  try {
    await seedGifts();
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const [setting, gifts, week, top] = await Promise.all([
      currentSetting(),
      Gift.find().sort({ sortOrder: 1, coins: 1 }).lean(),
      History.aggregate([
        { $match: { type: HISTORY_TYPE.GIFT, createdAt: { $gte: since } } },
        { $group: { _id: null, sent: { $sum: 1 }, coins: { $sum: "$userCoin" }, hostCoins: { $sum: "$listenerCoin" }, platformCoins: { $sum: "$adminCoin" }, senders: { $addToSet: "$userId" } } },
      ]),
      History.aggregate([{ $match: { type: HISTORY_TYPE.GIFT, createdAt: { $gte: since } } }, { $group: { _id: "$reason", n: { $sum: 1 } } }, { $sort: { n: -1 } }, { $limit: 1 }]),
    ]);
    const w = week[0] || {};
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settings: normalizeGiftSettings(setting?.gift),
        gifts,
        stats: {
          sent7d: w.sent || 0,
          coins7d: w.coins || 0,
          hostCoins7d: w.hostCoins || 0,
          platformCoins7d: w.platformCoins || 0,
          senders7d: (w.senders || []).length,
          topGift: top[0]?._id || "",
          active: gifts.filter((g) => g.isActive).length,
          total: gifts.length,
        },
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/gift/settings  body: any subset of SETTING_DEFAULTS
exports.updateSettings = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });
    const merged = { ...normalizeGiftSettings(setting.gift) };
    for (const k of Object.keys(SETTING_DEFAULTS)) {
      if (req.body?.[k] !== undefined) merged[k] = req.body[k];
    }
    setting.gift = normalizeGiftSettings(merged);
    setting.markModified("gift");
    await setting.save();
    if (typeof global.updateSettingFile === "function") global.updateSettingFile(setting);
    return res.status(200).json({ status: true, message: setting.gift.enabled ? "Gift settings saved." : "Gifts are now hidden in the app.", data: setting.gift });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

function readBody(body = {}, file) {
  const out = {};
  if (body.name !== undefined) out.name = String(body.name).trim().slice(0, 40);
  if (body.tagline !== undefined) out.tagline = String(body.tagline).trim().slice(0, 80);
  if (body.coins !== undefined) out.coins = Math.max(1, parseInt(body.coins, 10) || 1);
  if (body.sortOrder !== undefined) out.sortOrder = parseInt(body.sortOrder, 10) || 0;
  if (body.isActive !== undefined) out.isActive = body.isActive === true || body.isActive === "true";
  if (body.tier !== undefined) out.tier = body.tier === "pro" ? "pro" : "standard";
  if (body.accent !== undefined && /^#?[0-9a-fA-F]{6}$/.test(String(body.accent).trim())) {
    const a = String(body.accent).trim();
    out.accent = a.startsWith("#") ? a : `#${a}`;
  }
  if (file) out.image = file.path;
  return out;
}

// POST /api/admin/gift  (multipart: image required)
exports.add = async (req, res) => {
  try {
    const data = readBody(req.body, req.file);
    if (!data.name || !data.coins) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "name and coins are required." });
    }
    if (!data.image) return res.status(200).json({ status: false, message: "Upload a PNG with a transparent background for the gift." });
    const base = data.name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "") || "gift";
    let key = base;
    let n = 1;
    while (await Gift.exists({ key })) key = `${base}_${++n}`;
    if (data.sortOrder === undefined) {
      const last = await Gift.findOne().sort({ sortOrder: -1 }).select("sortOrder").lean();
      data.sortOrder = (last?.sortOrder || 0) + 1;
    }
    const gift = await Gift.create({ ...data, key });
    return res.status(200).json({ status: true, message: "Gift added.", data: gift });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/gift?giftId=  (multipart, optional image)
exports.edit = async (req, res) => {
  try {
    const { giftId } = req.query;
    if (!giftId || !mongoose.Types.ObjectId.isValid(giftId)) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "giftId is required." });
    }
    const gift = await Gift.findById(giftId);
    if (!gift) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "Gift not found." });
    }
    const data = readBody(req.body, req.file);
    if (req.file) removeUpload(gift.image);
    Object.assign(gift, data);
    await gift.save();
    return res.status(200).json({ status: true, message: "Gift updated.", data: gift });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/gift/toggle?giftId=
exports.toggle = async (req, res) => {
  try {
    const { giftId } = req.query;
    if (!giftId || !mongoose.Types.ObjectId.isValid(giftId)) return res.status(200).json({ status: false, message: "giftId is required." });
    const gift = await Gift.findById(giftId);
    if (!gift) return res.status(200).json({ status: false, message: "Gift not found." });
    gift.isActive = !gift.isActive;
    await gift.save();
    return res.status(200).json({ status: true, message: gift.isActive ? `${gift.name} is live.` : `${gift.name} hidden.`, data: gift });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/gift/reorder  body: { order: [giftId, ...] }
exports.reorder = async (req, res) => {
  try {
    const order = Array.isArray(req.body?.order) ? req.body.order.filter((id) => mongoose.Types.ObjectId.isValid(id)) : [];
    if (!order.length) return res.status(200).json({ status: false, message: "order is required." });
    await Gift.bulkWrite(order.map((id, i) => ({ updateOne: { filter: { _id: id }, update: { $set: { sortOrder: i + 1 } } } })));
    return res.status(200).json({ status: true, message: "Order saved." });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// DELETE /api/admin/gift?giftId=
exports.remove = async (req, res) => {
  try {
    const { giftId } = req.query;
    if (!giftId || !mongoose.Types.ObjectId.isValid(giftId)) return res.status(200).json({ status: false, message: "giftId is required." });
    const gift = await Gift.findById(giftId);
    if (!gift) return res.status(200).json({ status: false, message: "Gift not found." });
    if (gift.sentCount > 0) return res.status(200).json({ status: false, message: `${gift.name} has been sent ${gift.sentCount} time(s). Hide it instead of deleting so history keeps its picture.` });
    removeUpload(gift.image);
    await gift.deleteOne();
    return res.status(200).json({ status: true, message: "Gift deleted." });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
