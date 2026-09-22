// Extra coin rewards: profile completion, invite friends, avatar unlock bonus.
// Settings live in `setting.rewards`; this module normalises them, decides
// eligibility and does the atomic credit + history + push for every grant.
const crypto = require("crypto");

const User = require("../models/user.model");
const History = require("../models/history.model");
const Notification = require("../models/notification.model");
const generateHistoryUniqueId = require("./generateHistoryUniqueId");
const { HISTORY_TYPE } = require("../types/constant");

const DEFAULTS = {
  profile: { enabled: true, coins: 25 },
  referral: { enabled: true, inviterCoins: 20, inviteeCoins: 0, purchaseSharePercent: 40, firstPurchaseOnly: true, codeWindowDays: 7 },
  avatarBonus: { enabled: true, percent: 5, minCoins: 4, maxCoins: 10 },
};

const plain = (raw) => (!raw ? {} : typeof raw.toObject === "function" ? raw.toObject() : raw);
const bool = (v, d) => (v === undefined || v === null ? d : typeof v === "boolean" ? v : String(v).toLowerCase() === "true");
const int = (v, d, lo = 0, hi = 1_000_000) => {
  const n = Math.round(Number(v));
  return Number.isFinite(n) ? Math.min(hi, Math.max(lo, n)) : d;
};

function normalizeRewards(raw) {
  const r = plain(raw);
  const p = { ...DEFAULTS.profile, ...plain(r.profile) };
  const f = { ...DEFAULTS.referral, ...plain(r.referral) };
  const a = { ...DEFAULTS.avatarBonus, ...plain(r.avatarBonus) };
  const minCoins = int(a.minCoins, DEFAULTS.avatarBonus.minCoins, 0, 100000);
  return {
    profile: { enabled: bool(p.enabled, true), coins: int(p.coins, DEFAULTS.profile.coins) },
    referral: {
      enabled: bool(f.enabled, true),
      inviterCoins: int(f.inviterCoins, DEFAULTS.referral.inviterCoins),
      inviteeCoins: int(f.inviteeCoins, DEFAULTS.referral.inviteeCoins),
      purchaseSharePercent: int(f.purchaseSharePercent, DEFAULTS.referral.purchaseSharePercent, 0, 100),
      firstPurchaseOnly: bool(f.firstPurchaseOnly, true),
      codeWindowDays: int(f.codeWindowDays, DEFAULTS.referral.codeWindowDays, 1, 365),
    },
    avatarBonus: {
      enabled: bool(a.enabled, true),
      percent: int(a.percent, DEFAULTS.avatarBonus.percent, 0, 100),
      minCoins,
      maxCoins: Math.max(minCoins, int(a.maxCoins, DEFAULTS.avatarBonus.maxCoins, 0, 100000)),
    },
  };
}

function config() {
  return normalizeRewards(global.settingJSON && global.settingJSON.rewards);
}

// ── profile completion ───────────────────────────────────────────────────────
const DEFAULT_PICS = ["male.png", "female.png"];

function profileChecklist(user) {
  const u = plain(user);
  const pic = String(u.profilePic || "");
  const hasPhoto = (pic && !DEFAULT_PICS.includes(pic.split("/").pop())) || (u.avatar && u.avatar.active && u.avatar.avatar);
  return [
    { key: "name", label: "Add your name", done: String(u.fullName || u.nickName || "").trim().length >= 2 },
    { key: "photo", label: "Add a profile photo or avatar", done: !!hasPhoto },
    { key: "gender", label: "Choose your gender", done: ["male", "female", "other"].includes(String(u.gender || "").toLowerCase()) },
    { key: "birthday", label: "Add your birthday", done: String(u.birthDate || "").trim().length >= 6 },
    { key: "country", label: "Pick your country", done: String(u.country || "").trim().length >= 2 },
    { key: "bio", label: "Write a short bio (10+ characters)", done: String(u.bio || "").trim().length >= 10 },
  ];
}

const isProfileComplete = (user) => profileChecklist(user).every((c) => c.done);

// ── avatar bonus ─────────────────────────────────────────────────────────────
function avatarBonusFor(price, cfg = config().avatarBonus) {
  if (!cfg.enabled || !(price > 0)) return 0;
  const raw = Math.round((price * cfg.percent) / 100);
  return Math.min(cfg.maxCoins, Math.max(cfg.minCoins, raw));
}

// ── referral codes ───────────────────────────────────────────────────────────
const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I

function randomCode(len = 6) {
  const bytes = crypto.randomBytes(len);
  let out = "";
  for (let i = 0; i < len; i++) out += ALPHABET[bytes[i] % ALPHABET.length];
  return out;
}

async function ensureReferralCode(userId) {
  const user = await User.findById(userId).select("referralCode").lean();
  if (!user) return null;
  if (user.referralCode) return user.referralCode;
  for (let attempt = 0; attempt < 6; attempt++) {
    const code = randomCode(6);
    try {
      const r = await User.updateOne({ _id: userId, referralCode: null }, { $set: { referralCode: code } });
      if (r.modifiedCount === 1) return code;
      const again = await User.findById(userId).select("referralCode").lean();
      if (again && again.referralCode) return again.referralCode;
    } catch (error) {
      if (error.code !== 11000) throw error; // duplicate → try another code
    }
  }
  throw new Error("Could not allocate a referral code");
}

const normalizeCode = (code) => String(code || "").toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 12);

// ── crediting ────────────────────────────────────────────────────────────────
/**
 * Adds `coins` to a user, writes the history row and (optionally) pushes a
 * notification. Returns the new balance or null when the user is missing.
 */
async function credit(userId, coins, { type, reason, notify, extraInc = {}, extraSet = {} }) {
  if (!(coins > 0)) return null;
  const updated = await User.findOneAndUpdate({ _id: userId }, { $inc: { coins, ...extraInc }, $set: extraSet }, { new: true, select: "coins fcmToken isNotificationEnabled" }).lean();
  if (!updated) return null;

  History.create({
    type,
    uniqueId: await generateHistoryUniqueId(),
    userId,
    userCoin: coins,
    reason: reason || "",
    date: new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" }),
  }).catch((e) => console.error("reward history:", e.message));

  if (notify) {
    const { title, body } = notify;
    Notification.create({ userId, title, message: body, date: new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" }) }).catch(() => {});
    if (updated.fcmToken && updated.isNotificationEnabled !== false) {
      require("./privateKey")
        .then((admin) => admin.messaging().send({ token: updated.fcmToken, data: { title, body, type: "REWARD", coins: String(coins) } }))
        .catch((e) => console.log("reward FCM failed:", e.message));
    }
  }
  return updated.coins;
}

// Profile reward: idempotent through the profileClaimedAt guard.
async function grantProfileReward(userDoc) {
  const cfg = config().profile;
  if (!cfg.enabled || !(cfg.coins > 0)) return null;
  const u = plain(userDoc);
  if (u.rewards && u.rewards.profileClaimedAt) return null;
  if (!isProfileComplete(u)) return null;
  const claimed = await User.findOneAndUpdate(
    { _id: u._id, "rewards.profileClaimedAt": null },
    { $set: { "rewards.profileClaimedAt": new Date() } },
    { new: false, select: "_id" }
  ).lean();
  if (!claimed) return null;
  const balance = await credit(u._id, cfg.coins, {
    type: HISTORY_TYPE.PROFILE_REWARD,
    reason: "Profile completed",
    notify: { title: "Profile complete!", body: `+${cfg.coins} coins for finishing your profile.` },
  });
  return { type: "profile", coins: cfg.coins, balance };
}

// Invite: new user `userId` enters `code`. Returns { ok, message, inviteeCoins, balance }.
async function applyReferral(userId, code) {
  const cfg = config().referral;
  if (!cfg.enabled) return { ok: false, message: "Invite rewards are turned off right now." };
  const clean = normalizeCode(code);
  if (clean.length < 4) return { ok: false, message: "Enter a valid invite code." };

  const me = await User.findById(userId).select("referredBy referralCode createdAt coinsRecharged fullName nickName").lean();
  if (!me) return { ok: false, message: "User not found." };
  if (me.referredBy) return { ok: false, message: "You already used an invite code." };
  if (me.referralCode === clean) return { ok: false, message: "That is your own code." };
  const ageMs = Date.now() - new Date(me.createdAt).getTime();
  if (ageMs > cfg.codeWindowDays * 86400000) return { ok: false, message: `Invite codes can only be entered within ${cfg.codeWindowDays} days of joining.` };
  if ((me.coinsRecharged || 0) > 0) return { ok: false, message: "Invite codes can only be used before your first purchase." };

  const inviter = await User.findOne({ referralCode: clean }).select("_id isBlock fullName nickName").lean();
  if (!inviter) return { ok: false, message: "We could not find that invite code." };
  if (inviter.isBlock) return { ok: false, message: "That invite code is not active." };

  const linked = await User.updateOne({ _id: userId, referredBy: null }, { $set: { referredBy: inviter._id, "referral.appliedAt": new Date() } });
  if (linked.modifiedCount !== 1) return { ok: false, message: "You already used an invite code." };

  const inviteeName = me.fullName || me.nickName || "A new friend";
  if (cfg.inviterCoins > 0) {
    await credit(inviter._id, cfg.inviterCoins, {
      type: HISTORY_TYPE.REFERRAL_REWARD,
      reason: `${inviteeName} joined with your code`,
      extraInc: { "referral.invited": 1, "referral.earnedCoins": cfg.inviterCoins },
      notify: { title: "Your invite worked!", body: `${inviteeName} joined bebu with your code. +${cfg.inviterCoins} coins.` },
    });
  } else {
    await User.updateOne({ _id: inviter._id }, { $inc: { "referral.invited": 1 } });
  }

  let balance = null;
  if (cfg.inviteeCoins > 0) {
    balance = await credit(userId, cfg.inviteeCoins, { type: HISTORY_TYPE.REFERRAL_REWARD, reason: "Welcome bonus for using an invite code" });
  }
  return { ok: true, message: cfg.inviteeCoins > 0 ? `Code accepted! +${cfg.inviteeCoins} coins for you.` : "Code accepted! Your friend just got their reward.", inviteeCoins: cfg.inviteeCoins, balance, inviterName: inviter.fullName || inviter.nickName || "" };
}

// Purchase share: called after a coin plan purchase by `userId` of `coins`.
async function onPurchase(userId, coins) {
  const cfg = config().referral;
  if (!cfg.enabled || !(cfg.purchaseSharePercent > 0) || !(coins > 0)) return null;
  const buyer = await User.findById(userId).select("referredBy fullName nickName").lean();
  if (!buyer || !buyer.referredBy) return null;
  if (cfg.firstPurchaseOnly) {
    const earlier = await History.countDocuments({ userId, type: HISTORY_TYPE.COIN_PLAN_PURCHASE });
    if (earlier > 1) return null; // the current purchase is already recorded
  }
  const share = Math.round((coins * cfg.purchaseSharePercent) / 100);
  if (!(share > 0)) return null;
  const name = buyer.fullName || buyer.nickName || "Your friend";
  await credit(buyer.referredBy, share, {
    type: HISTORY_TYPE.REFERRAL_REWARD,
    reason: `${name} bought coins — ${cfg.purchaseSharePercent}% share`,
    extraInc: { "referral.purchases": 1, "referral.earnedCoins": share },
    notify: { title: "Invite bonus!", body: `${name} bought a coin pack. You earned ${share} coins.` },
  });
  return share;
}

// Avatar unlock bonus for `price` coins spent. Returns { bonus, balance } or null.
async function onAvatarUnlock(userId, price) {
  const bonus = avatarBonusFor(price);
  if (!(bonus > 0)) return null;
  const balance = await credit(userId, bonus, {
    type: HISTORY_TYPE.AVATAR_BONUS,
    reason: "Premium avatar item bonus",
    extraInc: { "rewards.avatarBonusCoins": bonus },
  });
  return { bonus, balance };
}

module.exports = { DEFAULTS, normalizeRewards, config, profileChecklist, isProfileComplete, avatarBonusFor, ensureReferralCode, normalizeCode, applyReferral, onPurchase, onAvatarUnlock, grantProfileReward, credit };
