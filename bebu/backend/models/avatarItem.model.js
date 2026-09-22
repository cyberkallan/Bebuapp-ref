const mongoose = require("mongoose");

const CATEGORIES = ["avatar", "background", "pet", "vehicle", "home", "sky", "accessory"];
const RARITIES = ["common", "rare", "epic", "legendary"];
const GENDERS = ["any", "male", "female"];

// One unlockable thing in the Avatar Studio: an avatar bust, a scene
// background, or a companion item that sits on the stage around the avatar.
const avatarItemSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true, trim: true }, // stable id, also the bundled asset name in the app
    category: { type: String, enum: CATEGORIES, required: true },
    name: { type: String, required: true, trim: true },
    image: { type: String, default: "" }, // relative path served by this server (avatar-studio/<key>.webp or storage/...)
    colors: [{ type: String }], // background gradient stops (hex), backgrounds only
    coins: { type: Number, default: 0, min: 0 }, // 0 = free
    rarity: { type: String, enum: RARITIES, default: "common" },
    includedInPro: { type: Boolean, default: false }, // bebu Pro users equip it without paying
    gender: { type: String, enum: GENDERS, default: "any" }, // avatars only
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
    unlockCount: { type: Number, default: 0 },
  },
  { timestamps: true, versionKey: false }
);

avatarItemSchema.index({ category: 1, isActive: 1, sortOrder: 1 });

module.exports = mongoose.model("AvatarItem", avatarItemSchema);
module.exports.CATEGORIES = CATEGORIES;
module.exports.RARITIES = RARITIES;
module.exports.GENDERS = GENDERS;
