const fs = require("fs");
const path = require("path");
const AvatarItem = require("../models/avatarItem.model");

const ASSET_DIR = path.join(__dirname, "..", "assets", "avatar-studio");
const MANIFEST = path.join(ASSET_DIR, "manifest.json");

// Upserts the bundled catalog (assets/avatar-studio/manifest.json) so a fresh
// database has a full studio on first boot. Existing rows keep any admin edits
// (price, name, active) — only missing keys are inserted.
async function seedAvatarStudio() {
  try {
    if (!fs.existsSync(MANIFEST)) return;
    const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
    const existing = new Set((await AvatarItem.find({}, { key: 1 }).lean()).map((x) => x.key));
    const missing = manifest.items.filter((it) => !existing.has(it.key));
    if (missing.length === 0) return;
    await AvatarItem.insertMany(
      missing.map((it) => ({
        key: it.key,
        category: it.category,
        name: it.name,
        image: `avatar-studio/${it.key}.webp`,
        colors: it.colors || [],
        coins: it.coins || 0,
        rarity: it.rarity || "common",
        gender: it.gender || "any",
        sortOrder: it.sortOrder || 0,
        isActive: true,
      })),
      { ordered: false }
    );
    console.log(`✅ Avatar Studio: seeded ${missing.length} items`);
  } catch (error) {
    console.error("❌ Avatar Studio seed failed:", error.message);
  }
}

module.exports = seedAvatarStudio;
module.exports.ASSET_DIR = ASSET_DIR;
module.exports.MANIFEST = MANIFEST;
