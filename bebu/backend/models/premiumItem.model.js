const mongoose = require("mongoose");

const TYPES = ["wallpaper", "font", "chatTheme", "callTheme"];

// One item of the Style Studio: a 4K wallpaper, a display font, a chat theme
// or a call-screen template. `data` holds the type-specific definition the
// app renders (font family, gradient stops, bubble colours ...).
const premiumItemSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true, trim: true },
    type: { type: String, enum: TYPES, required: true },
    name: { type: String, required: true, trim: true },
    tagline: { type: String, trim: true, default: "" },
    mood: { type: String, trim: true, default: "" }, // love | friendship | romantic | ...
    image: { type: String, default: "" }, // wallpapers: full-size path served by this server
    thumb: { type: String, default: "" }, // wallpapers: 540px preview
    data: { type: Object, default: {} },
    coins: { type: Number, default: 0, min: 0 }, // price for everyone who is not covered by includedInPro
    includedInPro: { type: Boolean, default: false }, // free while the user is bebu Pro
    proOnly: { type: Boolean, default: true }, // hidden from non-Pro users when true
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
    unlockCount: { type: Number, default: 0 },
    credit: { type: String, default: "" }, // photographer / licence note for bundled wallpapers
  },
  { timestamps: true, versionKey: false }
);

premiumItemSchema.index({ type: 1, isActive: 1, sortOrder: 1 });

module.exports = mongoose.model("PremiumItem", premiumItemSchema);
module.exports.TYPES = TYPES;
