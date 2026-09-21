const fs = require("fs");
const mongoose = require("mongoose");

const AvatarItem = require("../../models/avatarItem.model");
const Setting = require("../../models/setting.model");
const User = require("../../models/user.model");
const { deleteFile } = require("../../util/deletefile");
const seedAvatarStudio = require("../../util/seedAvatarStudio");

const { CATEGORIES, RARITIES, GENDERS } = AvatarItem;


function normalizeSettings(raw = {}) {
  const a = { ...SETTING_DEFAULTS, ...(raw && typeof raw.toObject === "function" ? raw.toObject() : raw) };
  return {
    enabled: a.enabled !== false,
    allowPhotoUpload: a.allowPhotoUpload !== false,
  };
}

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

// GET /api/admin/avatarStudio — settings + catalog + usage stats
exports.getStudio = async (req, res) => {
  try {
    await seedAvatarStudio();
    const [setting, items, stats] = await Promise.all([
      currentSetting(),
      AvatarItem.find().sort({ category: 1, sortOrder: 1 }).lean(),
      User.aggregate([
        { $group: { _id: null, usingAvatar: { $sum: { $cond: [{ $eq: ["$avatar.active", true] }, 1, 0] } }, unlocks: { $sum: { $size: { $ifNull: ["$unlockedItems", []] } } } } },
      ]),
    ]);
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settings: normalizeSettings(setting?.avatarStudio),
        items,
        stats: { usingAvatar: stats[0]?.usingAvatar || 0, unlocks: stats[0]?.unlocks || 0, items: items.length },
        options: { categories: CATEGORIES, rarities: RARITIES, genders: GENDERS },
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.updateSettings = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });
    const merged = { ...normalizeSettings(setting.avatarStudio) };
    for (const k of Object.keys(SETTING_DEFAULTS)) {
      if (req.body?.[k] === undefined) continue;
      merged[k] = req.body[k] === true || req.body[k] === "true";
    }
    setting.avatarStudio = normalizeSettings(merged);
    setting.markModified("avatarStudio");
    await setting.save();
    global.updateSettingFile(setting);
    return res.status(200).json({ status: true, message: "Avatar Studio settings updated.", data: setting.avatarStudio });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

function readItemBody(body = {}, file) {
  const out = {};
  if (body.name !== undefined) out.name = String(body.name).trim();
  if (body.category !== undefined && CATEGORIES.includes(body.category)) out.category = body.category;
  if (body.rarity !== undefined && RARITIES.includes(body.rarity)) out.rarity = body.rarity;
  if (body.gender !== undefined && GENDERS.includes(body.gender)) out.gender = body.gender;
  if (body.coins !== undefined) out.coins = Math.max(0, parseInt(body.coins, 10) || 0);
  if (body.sortOrder !== undefined) out.sortOrder = parseInt(body.sortOrder, 10) || 0;
  if (body.isActive !== undefined) out.isActive = body.isActive === true || body.isActive === "true";
  if (body.colors !== undefined) {
    const arr = Array.isArray(body.colors) ? body.colors : String(body.colors).split(",");
    out.colors = arr.map((c) => String(c).trim()).filter((c) => /^#?[0-9a-fA-F]{6}$/.test(c)).map((c) => (c.startsWith("#") ? c : `#${c}`));
  }
  if (file) out.image = file.path;
  return out;
}

// POST /api/admin/avatarStudio/item  (multipart, optional `image`)
exports.addItem = async (req, res) => {
  try {
    const data = readItemBody(req.body, req.file);
    if (!data.name || !data.category) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "name and category are required." });
    }
    if (!data.image && data.category !== "background") {
      return res.status(200).json({ status: false, message: "An image is required for this category." });
    }
    const base = (req.body.key || data.name).toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
    let key = `${data.category}_${base}`;
    let n = 1;
    while (await AvatarItem.exists({ key })) key = `${data.category}_${base}_${++n}`;
    const item = await AvatarItem.create({ ...data, key });
    return res.status(200).json({ status: true, message: "Item added.", data: item });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/avatarStudio/item?itemId=  (multipart, optional `image`)
exports.editItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "itemId is required." });
    }
    const item = await AvatarItem.findById(itemId);
    if (!item) {
      if (req.file) deleteFile(req.file);
      return res.status(200).json({ status: false, message: "Item not found." });
    }
    const data = readItemBody(req.body, req.file);
    if (req.file && item.image && item.image.startsWith("storage") && fs.existsSync(item.image)) fs.unlinkSync(item.image);
    Object.assign(item, data);
    await item.save();
    // Users wearing this avatar keep a valid picture if the image changed.
    if (req.file && item.category === "avatar") {
      await User.updateMany({ "avatar.active": true, "avatar.avatar": item._id }, { $set: { profilePic: item.image } });
    }
    return res.status(200).json({ status: true, message: "Item updated.", data: item });
  } catch (error) {
    if (req.file) deleteFile(req.file);
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/avatarStudio/item/toggle?itemId=
exports.toggleItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) return res.status(200).json({ status: false, message: "itemId is required." });
    const item = await AvatarItem.findById(itemId);
    if (!item) return res.status(200).json({ status: false, message: "Item not found." });
    item.isActive = !item.isActive;
    await item.save();
    return res.status(200).json({ status: true, message: item.isActive ? "Item is live." : "Item hidden.", data: item });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// DELETE /api/admin/avatarStudio/item?itemId=
exports.deleteItem = async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) return res.status(200).json({ status: false, message: "itemId is required." });
    const item = await AvatarItem.findById(itemId);
    if (!item) return res.status(200).json({ status: false, message: "Item not found." });
    const wearing = await User.countDocuments({ [`avatar.${item.category}`]: item._id });
    if (wearing > 0) return res.status(200).json({ status: false, message: `${wearing} user(s) have this equipped. Hide it instead of deleting.` });
    if (item.image && item.image.startsWith("storage") && fs.existsSync(item.image)) fs.unlinkSync(item.image);
    await item.deleteOne();
    await User.updateMany({ unlockedItems: item._id }, { $pull: { unlockedItems: item._id } });
    return res.status(200).json({ status: true, message: "Item deleted." });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.normalizeAvatarStudioSettings = normalizeSettings;
