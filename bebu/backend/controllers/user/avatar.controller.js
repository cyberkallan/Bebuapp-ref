const fs = require("fs");
const mongoose = require("mongoose");

const AvatarItem = require("../../models/avatarItem.model");
const User = require("../../models/user.model");
const History = require("../../models/history.model");
const { HISTORY_TYPE } = require("../../types/constant");
const generateHistoryUniqueId = require("../../util/generateHistoryUniqueId");
const { MANIFEST } = require("../../util/seedAvatarStudio");

const SLOTS = ["avatar", "background", "pet", "vehicle", "home", "sky", "accessory"];

function studioSettings() {
  const s = (global.settingJSON && global.settingJSON.avatarStudio) || {};
  return {
    enabled: s.enabled !== false,
    allowPhotoUpload: s.allowPhotoUpload !== false,
    // Coin bonus paid back on premium unlocks, so tiles can show "+N bonus" up front.
    bonus: require("../../util/rewards").config().avatarBonus,
  };
}

function presetKeys() {
  try {
    const m = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
    return m.presets || { male: [], female: [] };
  } catch {
    return { male: [], female: [] };
  }
}

function equippedOf(user) {
  const out = {};
  for (const slot of SLOTS) out[slot] = user?.avatar?.[slot] ? String(user.avatar[slot]) : null;
  return out;
}

// GET /api/user/avatar/studio — everything the studio screen needs in one call
exports.getStudio = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const userId = new mongoose.Types.ObjectId(req.user.userId);

    const presets = presetKeys();
    const premium = require("../../util/premium");
    const pcfg = premium.config();
    const [user, items, presetItems] = await Promise.all([
      User.findById(userId, { coins: 1, avatar: 1, unlockedItems: 1, profilePic: 1, gender: 1, premium: 1 }).lean(),
      AvatarItem.find({ isActive: true }).sort({ category: 1, sortOrder: 1 }).lean(),
      AvatarItem.find({ key: { $in: [...presets.male, ...presets.female] } }, { key: 1, image: 1, gender: 1 }).lean(),
    ]);
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });

    const byKey = Object.fromEntries(presetItems.map((p) => [p.key, p]));
    const pro = premium.isPro(user, pcfg);
    const proItems = pcfg.enabled && pcfg.features.proAvatarItems;
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settings: { ...studioSettings(), proItems, proName: pcfg.name },
        pro,
        coins: user.coins || 0,
        gender: user.gender || "",
        profilePic: user.profilePic || "",
        active: user.avatar?.active === true,
        equipped: equippedOf(user),
        unlocked: (user.unlockedItems || []).map(String),
        items,
        presets: {
          male: presets.male.map((k) => byKey[k]).filter(Boolean),
          female: presets.female.map((k) => byKey[k]).filter(Boolean),
        },
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/avatar/unlock  body: { itemId }
exports.unlockItem = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    if (!studioSettings().enabled) return res.status(200).json({ status: false, message: "Avatar Studio is turned off." });
    const { itemId } = req.body || {};
    if (!itemId || !mongoose.Types.ObjectId.isValid(itemId)) return res.status(200).json({ status: false, message: "itemId is required." });

    const userId = new mongoose.Types.ObjectId(req.user.userId);
    const item = await AvatarItem.findOne({ _id: itemId, isActive: true }).lean();
    if (!item) return res.status(200).json({ status: false, message: "Item not found." });

    const owned = await User.exists({ _id: userId, unlockedItems: item._id });
    if (owned) {
      const u = await User.findById(userId, { coins: 1 }).lean();
      return res.status(200).json({ status: true, message: "Already unlocked.", coins: u?.coins || 0, itemId: String(item._id) });
    }

    let price = Math.max(0, item.coins || 0);
    let viaPro = false;
    if (item.includedInPro && price > 0) {
      const premium = require("../../util/premium");
      const pcfg = premium.config();
      if (pcfg.enabled && pcfg.features.proAvatarItems) {
        const u = await User.findById(userId, premium.PROJECTION).lean();
        if (premium.isPro(u, pcfg)) {
          price = 0;
          viaPro = true;
        }
      }
    }
    // Atomic: only succeeds if the balance still covers the price.
    const updated = await User.findOneAndUpdate(
      { _id: userId, coins: { $gte: price } },
      { $inc: { coins: -price, coinsSpent: price }, $addToSet: { unlockedItems: item._id } },
      { new: true, projection: { coins: 1 } }
    );
    if (!updated) {
      const u = await User.findById(userId, { coins: 1 }).lean();
      return res.status(200).json({ status: false, code: "INSUFFICIENT_COINS", message: "Not enough coins.", coins: u?.coins || 0, price });
    }

    await Promise.all([
      AvatarItem.updateOne({ _id: item._id }, { $inc: { unlockCount: 1 } }),
      price > 0
        ? History.create({
            uniqueId: await generateHistoryUniqueId(),
            type: HISTORY_TYPE.AVATAR_UNLOCK,
            userId,
            userCoin: price,
            reason: `${item.category}:${item.name}`,
            date: new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" }),
          })
        : Promise.resolve(),
    ]);

    // Premium-item bonus (settings → rewards.avatarBonus): a few coins back, scaled by price.
    let bonus = 0;
    let balance = updated.coins;
    try {
      const b = await require("../../util/rewards").onAvatarUnlock(userId, price);
      if (b) {
        bonus = b.bonus;
        if (b.balance !== null) balance = b.balance;
      }
    } catch (e) {
      console.log("avatar bonus:", e.message);
    }

    return res.status(200).json({ status: true, message: viaPro ? "Included with Pro." : "Unlocked.", coins: balance, itemId: String(item._id), price, bonus, viaPro });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/avatar/equip  body: { avatar, background, pet, ... (ids or null), active }
exports.equip = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    if (!studioSettings().enabled) return res.status(200).json({ status: false, message: "Avatar Studio is turned off." });
    const userId = new mongoose.Types.ObjectId(req.user.userId);
    const body = req.body || {};

    const user = await User.findById(userId);
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });

    const wanted = {};
    const ids = [];
    for (const slot of SLOTS) {
      if (body[slot] === undefined) continue; // untouched slot
      if (body[slot] === null || body[slot] === "") {
        wanted[slot] = null;
      } else if (mongoose.Types.ObjectId.isValid(body[slot])) {
        wanted[slot] = String(body[slot]);
        ids.push(new mongoose.Types.ObjectId(body[slot]));
      } else {
        return res.status(200).json({ status: false, message: `Invalid id for ${slot}.` });
      }
    }

    const items = ids.length ? await AvatarItem.find({ _id: { $in: ids }, isActive: true }).lean() : [];
    const byId = Object.fromEntries(items.map((i) => [String(i._id), i]));
    const unlocked = new Set((user.unlockedItems || []).map(String));

    for (const [slot, id] of Object.entries(wanted)) {
      if (!id) continue;
      const item = byId[id];
      if (!item) return res.status(200).json({ status: false, message: `Item for ${slot} not found.` });
      if (item.category !== slot) return res.status(200).json({ status: false, message: `${item.name} is not a ${slot}.` });
      if ((item.coins || 0) > 0 && !unlocked.has(id)) {
        return res.status(200).json({ status: false, code: "LOCKED", message: `${item.name} is locked.`, itemId: id });
      }
    }

    user.avatar = user.avatar || {};
    for (const [slot, id] of Object.entries(wanted)) user.avatar[slot] = id ? new mongoose.Types.ObjectId(id) : null;

    const active = body.active === undefined ? user.avatar.active === true : body.active === true || body.active === "true";
    user.avatar.active = active && !!user.avatar.avatar;

    if (user.avatar.active) {
      const avatarItem = byId[String(user.avatar.avatar)] || (await AvatarItem.findById(user.avatar.avatar).lean());
      if (avatarItem?.image) user.profilePic = avatarItem.image;
    }
    user.markModified("avatar");
    await user.save();

    return res.status(200).json({
      status: true,
      message: "Look saved.",
      data: { active: user.avatar.active, equipped: equippedOf(user), profilePic: user.profilePic },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/avatar/preset  body: { key } — pick one of the 3+3 premade pictures (studio off path)
exports.usePreset = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });
    const { key } = req.body || {};
    const presets = presetKeys();
    if (!key || ![...presets.male, ...presets.female].includes(key)) return res.status(200).json({ status: false, message: "Unknown preset." });

    const item = await AvatarItem.findOne({ key }).lean();
    if (!item?.image) return res.status(200).json({ status: false, message: "Preset image missing." });

    const user = await User.findByIdAndUpdate(
      req.user.userId,
      { $set: { profilePic: item.image, "avatar.active": false } },
      { new: true, projection: { profilePic: 1 } }
    );
    if (!user) return res.status(200).json({ status: false, message: "User does not found." });
    return res.status(200).json({ status: true, message: "Profile picture updated.", profilePic: user.profilePic });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.SLOTS = SLOTS;
exports.studioSettings = studioSettings;
