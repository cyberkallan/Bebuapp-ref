const mongoose = require("mongoose");

// A gift a user can send a host from chat or during a call. Coins are the
// user's price; the host's cut is decided by setting.gift.hostSharePercent.
const giftSchema = new mongoose.Schema(
  {
    key: { type: String, unique: true, trim: true }, // stable id for bundled gifts (rose, crown, ...)
    name: { type: String, trim: true, default: "" },
    tagline: { type: String, trim: true, default: "" }, // one-liner shown under the name in the sheet
    image: { type: String, default: "" }, // "gifts/rose.png" (bundled) or "storage/..." (uploaded)
    accent: { type: String, default: "#FF4D6D" }, // glow colour for the animation
    coins: { type: Number, default: 0 },
    tier: { type: String, enum: ["standard", "pro"], default: "standard" }, // "pro" = only bebu Pro users can send it
    sortOrder: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    sentCount: { type: Number, default: 0 },
    coinsTotal: { type: Number, default: 0 }, // lifetime coins spent on this gift
  },
  { timestamps: true, versionKey: false }
);

giftSchema.index({ isActive: 1, sortOrder: 1 });

module.exports = mongoose.model("Gift", giftSchema);
