const fs = require("fs");
const path = require("path");
const Gift = require("../models/gift.model");

const ASSET_DIR = path.join(__dirname, "..", "assets", "gifts");
const MANIFEST = path.join(ASSET_DIR, "manifest.json");

const SETTING_DEFAULTS = {
  enabled: true,
  hostSharePercent: 70,
  showInChat: true,
  showInCall: true,
  aiThankYou: true,
  minBalanceHint: true,
};

function clampPercent(v, fallback) {
  const n = Number(v);
  if (!Number.isFinite(n)) return fallback;
  return Math.min(100, Math.max(0, Math.round(n)));
}

// Fill defaults and coerce types so every consumer sees the same shape.
function normalizeGiftSettings(raw = {}) {
  const g = raw && typeof raw.toObject === "function" ? raw.toObject() : raw || {};
  const bool = (v, d) => (v === undefined || v === null ? d : v === true || v === "true");
  return {
    enabled: bool(g.enabled, SETTING_DEFAULTS.enabled),
    hostSharePercent: clampPercent(g.hostSharePercent, SETTING_DEFAULTS.hostSharePercent),
    showInChat: bool(g.showInChat, SETTING_DEFAULTS.showInChat),
    showInCall: bool(g.showInCall, SETTING_DEFAULTS.showInCall),
    aiThankYou: bool(g.aiThankYou, SETTING_DEFAULTS.aiThankYou),
    minBalanceHint: bool(g.minBalanceHint, SETTING_DEFAULTS.minBalanceHint),
  };
}

// Split a gift's price: host share rounds down, platform keeps the remainder.
function splitGiftCoins(coins, hostSharePercent) {
  const total = Math.max(0, Math.floor(Number(coins) || 0));
  const host = Math.floor((total * clampPercent(hostSharePercent, SETTING_DEFAULTS.hostSharePercent)) / 100);
  return { total, host, platform: total - host };
}

// Insert the bundled catalog (assets/gifts/manifest.json) on first boot.
// Rows already in the DB keep any admin edits; only missing keys are added.
async function seedGifts() {
  try {
    if (!fs.existsSync(MANIFEST)) return;
    const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
    const existing = new Set((await Gift.find({}, { key: 1 }).lean()).map((x) => x.key));
    const missing = (manifest.items || []).filter((it) => !existing.has(it.key));
    if (missing.length === 0) return;
    await Gift.insertMany(
      missing.map((it) => ({
        key: it.key,
        name: it.name,
        tagline: it.tagline || "",
        image: `gifts/${it.key}.png`,
        accent: it.accent || "#FF4D6D",
        coins: it.coins || 0,
        sortOrder: it.sortOrder || 0,
        isActive: true,
      })),
      { ordered: false }
    );
    console.log(`✅ Gifts: seeded ${missing.length} gifts`);
  } catch (error) {
    console.error("❌ Gift seed failed:", error.message);
  }
}

module.exports = { ASSET_DIR, SETTING_DEFAULTS, normalizeGiftSettings, splitGiftCoins, seedGifts };
