// bebu Pro: passes, entitlements and the Style Studio catalog.
// Settings live in `setting.premium`; this module normalises them, answers
// "is this user Pro?", activates passes, meters the free random-match cap and
// seeds the bundled catalog (assets/premium/manifest.json).
const fs = require("fs");
const path = require("path");

const User = require("../models/user.model");
const PremiumItem = require("../models/premiumItem.model");
const History = require("../models/history.model");
const Notification = require("../models/notification.model");
const generateHistoryUniqueId = require("./generateHistoryUniqueId");
const { HISTORY_TYPE } = require("../types/constant");
const { dayKey } = require("./loginRewards");

const ASSET_DIR = path.join(__dirname, "..", "assets", "premium");
const MANIFEST = path.join(ASSET_DIR, "manifest.json");

const DEFAULT_PASSES = [
  { key: "week", name: "1 week pass", days: 7, coins: 499, badge: "", isActive: true },
  { key: "month", name: "1 month pass", days: 30, coins: 1499, badge: "Popular", isActive: true },
  { key: "year", name: "1 year pass", days: 365, coins: 9999, badge: "Best value", isActive: true },
];

const DEFAULTS = {
  enabled: true,
  name: "bebu Pro",
  tagline: "Unlimited matching, golden tick, exclusive looks.",
  passes: DEFAULT_PASSES,
  features: {
    unlimitedRandomMatch: true,
    freeRandomMatchesPerDay: 5,
    goldenTick: true,
    proAvatarItems: true,
    proGifts: true,
    styleStudio: true,
    freeStyleItems: true,
  },
  showBadgeToHosts: true,
};

const plain = (raw) => (!raw ? {} : typeof raw.toObject === "function" ? raw.toObject() : raw);
const bool = (v, d) => (v === undefined || v === null ? d : typeof v === "boolean" ? v : String(v).toLowerCase() === "true");
const int = (v, d, lo = 0, hi = 10_000_000) => {
  const n = Math.round(Number(v));
  return Number.isFinite(n) ? Math.min(hi, Math.max(lo, n)) : d;
};
const str = (v, d, max = 80) => (v === undefined || v === null ? d : String(v).trim().slice(0, max));

function normalizePass(p, i) {
  const q = plain(p);
  const base = (str(q.key, "", 24) || str(q.name, `pass_${i + 1}`, 24)).toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
  return {
    key: base || `pass_${i + 1}`,
    name: str(q.name, "Pro pass", 40),
    days: int(q.days, 7, 0, 3650),
    coins: int(q.coins, 0, 0),
    badge: str(q.badge, "", 20),
    isActive: bool(q.isActive, true),
  };
}

function normalizePremium(raw) {
  const r = plain(raw);
  const f = { ...DEFAULTS.features, ...plain(r.features) };
  const passesRaw = Array.isArray(r.passes) && r.passes.length ? r.passes : DEFAULT_PASSES;
  const seen = new Set();
  const passes = passesRaw.map(normalizePass).filter((p) => {
    if (seen.has(p.key)) return false;
    seen.add(p.key);
    return true;
  });
  return {
    enabled: bool(r.enabled, DEFAULTS.enabled),
    name: str(r.name, DEFAULTS.name, 30) || DEFAULTS.name,
    tagline: str(r.tagline, DEFAULTS.tagline, 120),
    passes,
    features: {
      unlimitedRandomMatch: bool(f.unlimitedRandomMatch, true),
      freeRandomMatchesPerDay: int(f.freeRandomMatchesPerDay, 5, 0, 1000),
      goldenTick: bool(f.goldenTick, true),
      proAvatarItems: bool(f.proAvatarItems, true),
      proGifts: bool(f.proGifts, true),
      styleStudio: bool(f.styleStudio, true),
      freeStyleItems: bool(f.freeStyleItems, true),
    },
    showBadgeToHosts: bool(r.showBadgeToHosts, true),
  };
}

function config() {
  return normalizePremium(global.settingJSON && global.settingJSON.premium);
}

function timezone() {
  return (global.settingJSON && global.settingJSON.dailyReward && global.settingJSON.dailyReward.timezone) || "Asia/Kolkata";
}

// ── entitlement ──────────────────────────────────────────────────────────────

/** True while the user has an unexpired pass (and Pro is switched on). */
function isPro(user, cfg = config()) {
  if (!cfg.enabled) return false;
  const p = plain(user).premium || {};
  if (p.lifetime) return true;
  return !!(p.until && new Date(p.until).getTime() > Date.now());
}

/** Whether to draw the golden tick next to this user's name. */
function showsBadge(user, cfg = config()) {
  const p = plain(user).premium || {};
  return cfg.features.goldenTick && isPro(user, cfg) && p.badge !== false;
}

/** Compact object the app stores next to the profile. */
function summary(user, cfg = config()) {
  const p = plain(user).premium || {};
  const active = isPro(user, cfg);
  return {
    enabled: cfg.enabled,
    active,
    lifetime: !!p.lifetime && active,
    until: active && !p.lifetime ? p.until : null,
    planKey: active ? p.planKey || "" : "",
    badge: p.badge !== false,
    showBadge: showsBadge(user, cfg),
    since: p.since || null,
  };
}

/** The projection you need on a User query to call isPro/showsBadge. */
const PROJECTION = "premium style unlockedStyles randomMatch";

// ── passes ───────────────────────────────────────────────────────────────────

const now = () => new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" });

/**
 * Extend the user's Pro period by `pass` (stacking on the current end when
 * still active). `source` = "coins" (debits the wallet atomically) or "admin".
 */
async function activatePass(userId, pass, { source = "coins" } = {}) {
  const user = await User.findById(userId, "coins premium fcmToken isNotificationEnabled").lean();
  if (!user) return { ok: false, code: "NOT_FOUND", message: "User not found." };

  const price = source === "coins" ? Math.max(0, pass.coins || 0) : 0;
  const cur = user.premium || {};
  const active = cur.lifetime || (cur.until && new Date(cur.until).getTime() > Date.now());
  const base = active && !cur.lifetime ? new Date(cur.until) : new Date();
  const lifetime = pass.days === 0 || !!cur.lifetime;
  const until = lifetime ? null : new Date(base.getTime() + pass.days * 86400000);

  const set = {
    "premium.until": until,
    "premium.lifetime": lifetime,
    "premium.planKey": pass.key,
    "premium.grantedBy": source,
  };
  if (!cur.since) set["premium.since"] = new Date();
  const filter = { _id: userId };
  const inc = { "premium.passes": 1 };
  if (price > 0) {
    filter.coins = { $gte: price };
    inc.coins = -price;
    inc.coinsSpent = price;
    inc["premium.coinsSpent"] = price;
  }
  const updated = await User.findOneAndUpdate(filter, { $set: set, $inc: inc }, { new: true, projection: "coins premium" }).lean();
  if (!updated) {
    return { ok: false, code: "INSUFFICIENT_COINS", message: "Not enough coins for this pass.", balance: user.coins || 0, need: price - (user.coins || 0) };
  }

  History.create({
    uniqueId: await generateHistoryUniqueId(),
    type: HISTORY_TYPE.PREMIUM_PASS,
    userId,
    userCoin: price,
    adminCoin: price,
    reason: source === "admin" ? `Granted by admin: ${pass.name}` : pass.name,
    date: now(),
  }).catch((e) => console.error("premium history:", e.message));

  const cfg = config();
  const title = `You're ${cfg.name} now`;
  const body = lifetime ? `${pass.name} activated — enjoy it forever.` : `${pass.name} activated. Pro until ${until.toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })}.`;
  Notification.create({ userId, title, message: body, date: now() }).catch(() => {});
  if (user.fcmToken && user.isNotificationEnabled !== false) {
    require("./privateKey")
      .then((admin) => admin.messaging().send({ token: user.fcmToken, data: { title, body, type: "PREMIUM" } }))
      .catch((e) => console.log("premium FCM failed:", e.message));
  }

  return { ok: true, balance: updated.coins, premium: summary(updated, cfg), price };
}

/** Admin: end the pass right now. */
async function revoke(userId) {
  const updated = await User.findByIdAndUpdate(
    userId,
    { $set: { "premium.until": null, "premium.lifetime": false, "premium.planKey": "", "premium.grantedBy": "admin" } },
    { new: true, projection: "premium" }
  ).lean();
  return updated ? summary(updated) : null;
}

// ── random match cap ─────────────────────────────────────────────────────────

/**
 * Consume one random match for a free user, or pass straight through for a
 * Pro user. Returns the quota the app shows under the Start button.
 */
async function consumeRandomMatch(userId) {
  const cfg = config();
  const user = await User.findById(userId, PROJECTION).lean();
  if (!user) return { allowed: false, code: "NOT_FOUND" };
  const pro = isPro(user, cfg);
  const cap = cfg.enabled && cfg.features.unlimitedRandomMatch ? cfg.features.freeRandomMatchesPerDay : 0;
  const unlimited = pro || cap <= 0;

  const today = dayKey(new Date(), timezone());
  const used = user.randomMatch && user.randomMatch.date === today ? user.randomMatch.count || 0 : 0;

  if (!unlimited && used >= cap) {
    return { allowed: false, code: "MATCH_LIMIT", quota: { unlimited: false, pro, used, limit: cap, left: 0 } };
  }
  // Counting happens for Pro users too so the admin can see usage; it just never blocks them.
  await User.updateOne({ _id: userId }, user.randomMatch && user.randomMatch.date === today ? { $inc: { "randomMatch.count": 1 } } : { $set: { "randomMatch.date": today, "randomMatch.count": 1 } });
  return { allowed: true, quota: { unlimited, pro, used: used + 1, limit: cap, left: unlimited ? null : Math.max(0, cap - used - 1) } };
}

async function randomMatchQuota(userId) {
  const cfg = config();
  const user = await User.findById(userId, PROJECTION).lean();
  if (!user) return null;
  const pro = isPro(user, cfg);
  const cap = cfg.enabled && cfg.features.unlimitedRandomMatch ? cfg.features.freeRandomMatchesPerDay : 0;
  const unlimited = pro || cap <= 0;
  const today = dayKey(new Date(), timezone());
  const used = user.randomMatch && user.randomMatch.date === today ? user.randomMatch.count || 0 : 0;
  return { unlimited, pro, used, limit: cap, left: unlimited ? null : Math.max(0, cap - used) };
}

// ── style studio ─────────────────────────────────────────────────────────────

/** Price a style item costs *this* user right now (0 when their pass covers it). */
function priceFor(item, pro, cfg = config()) {
  if (pro && cfg.features.freeStyleItems && item.includedInPro) return 0;
  return Math.max(0, item.coins || 0);
}

function publicItem(item, { pro, unlocked, cfg = config() }) {
  const owned = unlocked.has(item.key);
  const price = priceFor(item, pro, cfg);
  return {
    _id: item._id,
    key: item.key,
    type: item.type,
    name: item.name,
    tagline: item.tagline || "",
    mood: item.mood || "",
    image: item.image || "",
    thumb: item.thumb || item.image || "",
    data: item.data || {},
    coins: item.coins || 0,
    price, // what this user pays now
    includedInPro: !!item.includedInPro,
    proOnly: item.proOnly !== false,
    owned: owned || price === 0 && pro && item.includedInPro,
    locked: !owned && !(pro && cfg.features.freeStyleItems && item.includedInPro),
    sortOrder: item.sortOrder || 0,
  };
}

// Insert the bundled catalog on first boot; existing keys keep admin edits.
async function seedPremiumItems() {
  try {
    if (!fs.existsSync(MANIFEST)) return;
    const m = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
    const existing = new Set((await PremiumItem.find({}, { key: 1 }).lean()).map((x) => x.key));
    const rows = [];
    const push = (type, list) => {
      for (const it of list || []) {
        if (existing.has(it.key)) continue;
        rows.push({
          key: it.key,
          type,
          name: it.name,
          tagline: it.tagline || "",
          mood: it.mood || "",
          image: type === "wallpaper" ? `premium/wallpapers/${it.key}.jpg` : "",
          thumb: type === "wallpaper" ? `premium/wallpapers/thumbs/${it.key}.jpg` : "",
          data: it.data || {},
          coins: it.coins || 0,
          includedInPro: !!it.includedInPro,
          proOnly: it.proOnly !== false,
          isActive: true,
          sortOrder: it.sortOrder || 0,
          credit: it.credit || "",
        });
      }
    };
    push("wallpaper", m.wallpapers);
    push("font", m.fonts);
    push("chatTheme", m.chatThemes);
    push("callTheme", m.callThemes);
    if (rows.length === 0) return;
    await PremiumItem.insertMany(rows, { ordered: false });
    console.log(`✅ Premium: seeded ${rows.length} style items`);
  } catch (error) {
    console.error("❌ Premium seed failed:", error.message);
  }
}

/** Resolve the user's saved style keys into full item definitions for the app. */
async function resolveStyle(user, cfg = config()) {
  const s = plain(user).style || {};
  const keys = [s.font, s.wallpaper, s.chatTheme, s.callTheme].filter(Boolean);
  if (!cfg.enabled || !cfg.features.styleStudio || keys.length === 0) return { font: null, wallpaper: null, chatTheme: null, callTheme: null };
  const items = await PremiumItem.find({ key: { $in: keys }, isActive: true }).lean();
  const byKey = Object.fromEntries(items.map((i) => [i.key, i]));
  const pick = (k) => (k && byKey[k] ? { key: byKey[k].key, name: byKey[k].name, image: byKey[k].image, thumb: byKey[k].thumb, data: byKey[k].data || {} } : null);
  return { font: pick(s.font), wallpaper: pick(s.wallpaper), chatTheme: pick(s.chatTheme), callTheme: pick(s.callTheme) };
}

module.exports = {
  ASSET_DIR,
  DEFAULTS,
  DEFAULT_PASSES,
  PROJECTION,
  normalizePremium,
  normalizePass,
  config,
  isPro,
  showsBadge,
  summary,
  activatePass,
  revoke,
  consumeRandomMatch,
  randomMatchQuota,
  priceFor,
  publicItem,
  seedPremiumItems,
  resolveStyle,
};
