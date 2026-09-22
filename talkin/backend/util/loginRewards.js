// Shared shape + validation for `setting.login` and `setting.dailyReward`.
// Both the admin controller and the app-facing settings responses go through
// here so a half-written document never reaches the app.

const LOGIN_METHODS = ["google", "phone", "quick", "email"];

const LOGIN_DEFAULTS = {
  quick: true,
  google: true,
  phone: true,
  email: false,
  primary: "google",
  showWelcomeBonus: true,
  requireConsentCheckbox: false,
  headline: "",
};

const REWARD_DEFAULTS = {
  enabled: true,
  coins: [10, 15, 20, 25, 30, 40, 60],
  resetStreakOnMiss: true,
  timezone: "Asia/Kolkata",
  autoOpen: true,
};

function plain(raw) {
  if (!raw) return {};
  return typeof raw.toObject === "function" ? raw.toObject() : raw;
}

function bool(v, d) {
  if (v === undefined || v === null) return d;
  if (typeof v === "boolean") return v;
  return String(v).toLowerCase() === "true";
}

function normalizeLogin(raw) {
  const l = { ...LOGIN_DEFAULTS, ...plain(raw) };
  const out = {
    quick: bool(l.quick, LOGIN_DEFAULTS.quick),
    google: bool(l.google, LOGIN_DEFAULTS.google),
    phone: bool(l.phone, LOGIN_DEFAULTS.phone),
    email: bool(l.email, LOGIN_DEFAULTS.email),
    primary: LOGIN_METHODS.includes(l.primary) ? l.primary : LOGIN_DEFAULTS.primary,
    showWelcomeBonus: bool(l.showWelcomeBonus, LOGIN_DEFAULTS.showWelcomeBonus),
    requireConsentCheckbox: bool(l.requireConsentCheckbox, LOGIN_DEFAULTS.requireConsentCheckbox),
    headline: typeof l.headline === "string" ? l.headline.trim().slice(0, 80) : "",
  };

  // Never ship a screen with zero ways to sign in.
  if (!out.quick && !out.google && !out.phone && !out.email) {
    out.google = true;
    out.phone = true;
  }
  // The hero button has to be an enabled method.
  if (!out[out.primary]) {
    out.primary = LOGIN_METHODS.find((m) => out[m]) || "google";
  }
  return out;
}

function normalizeReward(raw) {
  const r = { ...REWARD_DEFAULTS, ...plain(raw) };
  let coins = Array.isArray(r.coins) ? r.coins : String(r.coins || "").split(",");
  coins = coins
    .map((c) => Math.round(Number(c)))
    .filter((c) => Number.isFinite(c) && c >= 0)
    .slice(0, 14);
  if (coins.length === 0) coins = [...REWARD_DEFAULTS.coins];

  let timezone = typeof r.timezone === "string" && r.timezone.trim() ? r.timezone.trim() : REWARD_DEFAULTS.timezone;
  try {
    new Intl.DateTimeFormat("en-CA", { timeZone: timezone });
  } catch (_) {
    timezone = REWARD_DEFAULTS.timezone;
  }

  return {
    enabled: bool(r.enabled, REWARD_DEFAULTS.enabled),
    coins,
    resetStreakOnMiss: bool(r.resetStreakOnMiss, REWARD_DEFAULTS.resetStreakOnMiss),
    timezone,
    autoOpen: bool(r.autoOpen, REWARD_DEFAULTS.autoOpen),
  };
}

/** YYYY-MM-DD for `date` in `timezone`. */
function dayKey(date, timezone) {
  return new Intl.DateTimeFormat("en-CA", { timeZone: timezone, year: "numeric", month: "2-digit", day: "2-digit" }).format(date);
}

/** Wall-clock offset (ms) of `timezone` at `date`. */
function tzOffsetMs(date, timezone) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    hourCycle: "h23",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).formatToParts(date);
  const get = (t) => Number(parts.find((p) => p.type === t).value);
  const asUtc = Date.UTC(get("year"), get("month") - 1, get("day"), get("hour"), get("minute"), get("second"));
  return asUtc - date.getTime();
}

/** Start of the next calendar day in `timezone`, as a Date. */
function nextMidnight(date, timezone) {
  const key = dayKey(date, timezone);
  const [y, m, d] = key.split("-").map(Number);
  const localMidnightNext = Date.UTC(y, m - 1, d + 1, 0, 0, 0);
  const guess = new Date(localMidnightNext - tzOffsetMs(date, timezone));
  // DST edges can shift the offset across the boundary; correct once.
  return new Date(localMidnightNext - tzOffsetMs(guess, timezone));
}

function previousDayKey(key) {
  const [y, m, d] = key.split("-").map(Number);
  const prev = new Date(Date.UTC(y, m - 1, d - 1));
  return prev.toISOString().slice(0, 10);
}

/**
 * Computes what the user can claim right now.
 * Returns { canClaim, streak, day, coins, nextCoins, nextClaimAt, todayKey }.
 *  - streak: streak length *after* claiming today (or the current one if already claimed)
 *  - day: 1-based position in the schedule for the claimable/claimed reward
 */
function computeStatus(userReward, rewardCfg, now = new Date()) {
  const cfg = normalizeReward(rewardCfg);
  const progress = plain(userReward);
  const todayKey = dayKey(now, cfg.timezone);
  const yesterdayKey = previousDayKey(todayKey);
  const len = cfg.coins.length;
  const lastKey = progress.lastClaimDate || "";
  const currentStreak = Number(progress.streak) || 0;

  const claimedToday = lastKey === todayKey;
  let streak;
  if (claimedToday) {
    streak = Math.max(currentStreak, 1);
  } else if (lastKey === yesterdayKey || (!cfg.resetStreakOnMiss && lastKey)) {
    streak = currentStreak + 1;
  } else {
    streak = 1;
  }

  const day = ((streak - 1) % len) + 1;
  const coins = cfg.coins[day - 1];
  const nextCoins = cfg.coins[day % len];

  return {
    enabled: cfg.enabled,
    canClaim: cfg.enabled && !claimedToday,
    claimedToday,
    streak,
    day,
    coins,
    nextCoins,
    schedule: cfg.coins,
    nextClaimAt: nextMidnight(now, cfg.timezone).toISOString(),
    todayKey,
    bestStreak: Math.max(Number(progress.bestStreak) || 0, claimedToday ? streak : currentStreak),
    totalClaims: Number(progress.totalClaims) || 0,
    autoOpen: cfg.autoOpen,
  };
}

module.exports = {
  LOGIN_METHODS,
  LOGIN_DEFAULTS,
  REWARD_DEFAULTS,
  normalizeLogin,
  normalizeReward,
  computeStatus,
  dayKey,
};
