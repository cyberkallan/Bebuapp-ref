const mongoose = require("mongoose");

const Setting = require("../../models/setting.model");
const Listener = require("../../models/listener.model");
const ListenerAiProfile = require("../../models/listenerAiProfile.model");
const { AiUsage, AiReplyLog } = require("../../models/aiUsage.model");
const { LANGUAGES, TONES } = require("../../util/aiChat/languages");
const { PRESETS, resolveProvider, callProvider, cooldownState } = require("../../util/aiChat/providers");
const aiChat = require("../../util/aiChat/service");

const MASK = "••••••••";

function maskKey(key) {
  if (!key) return "";
  return key.length <= 4 ? MASK : `${MASK}${key.slice(-4)}`;
}

function publicConfig(setting) {
  const cfg = (setting.aiChat && setting.aiChat.toObject ? setting.aiChat.toObject() : setting.aiChat) || {};
  return {
    ...cfg,
    providers: (cfg.providers || []).map((p) => ({ ...p, apiKey: maskKey(p.apiKey), hasKey: Boolean(p.apiKey) })),
  };
}

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

// GET /config
exports.getConfig = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settingId: setting._id,
        aiChat: publicConfig(setting),
        languages: LANGUAGES.map(({ id, label, native, region, fallback }) => ({ id, label, native, region, fallback })),
        tones: TONES.map(({ id, label }) => ({ id, label })),
        presets: Object.entries(PRESETS).map(([id, p]) => ({ id, ...p })),
        cooldowns: cooldownState(),
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /config  body: partial aiChat
exports.updateConfig = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });

    const body = req.body || {};
    const current = setting.aiChat || {};
    const numeric = ["memoryMessages", "typingDelayMinSec", "typingDelayMaxSec", "maxRepliesPerUserPerDay", "maxRepliesPerDay", "callNudgeAfterMessages", "callNudgeEveryMessages", "temperature", "maxTokens", "timeoutMs"];
    const booleans = ["enabled", "splitLongReplies", "quietHoursEnabled", "callNudgeEnabled", "fallbackEnabled"];
    const strings = ["defaultLanguage", "tone", "replyLength", "emojiLevel", "identityRule", "replyWhen", "quietStart", "quietEnd", "timezone", "customRules"];

    for (const k of numeric) if (body[k] !== undefined && body[k] !== "" && !Number.isNaN(Number(body[k]))) setting.aiChat[k] = Number(body[k]);
    for (const k of booleans) if (body[k] !== undefined) setting.aiChat[k] = body[k] === true || body[k] === "true";
    for (const k of strings) if (typeof body[k] === "string") setting.aiChat[k] = body[k].trim();
    if (Array.isArray(body.blockedTopics)) setting.aiChat.blockedTopics = body.blockedTopics.map((t) => String(t).trim()).filter(Boolean);

    if (Array.isArray(body.providers)) {
      const old = current.providers || [];
      setting.aiChat.providers = body.providers.slice(0, 6).map((p, i) => {
        const prev = old.find((o) => o._id && String(o._id) === String(p._id)) || old[i];
        let apiKey = typeof p.apiKey === "string" ? p.apiKey.trim() : "";
        // Masked value or empty string means "keep the stored key".
        if (!apiKey || apiKey.startsWith(MASK)) apiKey = prev?.apiKey || "";
        if (p.clearKey === true) apiKey = "";
        return {
          preset: PRESETS[p.preset] ? p.preset : "custom",
          label: String(p.label || "").trim(),
          baseUrl: String(p.baseUrl || "").trim(),
          apiKey,
          model: String(p.model || "").trim(),
          enabled: p.enabled !== false,
        };
      });
    }

    if (setting.aiChat.typingDelayMaxSec < setting.aiChat.typingDelayMinSec) setting.aiChat.typingDelayMaxSec = setting.aiChat.typingDelayMinSec;
    if (setting.aiChat.temperature < 0 || setting.aiChat.temperature > 2) setting.aiChat.temperature = 0.85;

    setting.markModified("aiChat");
    await setting.save();
    global.updateSettingFile(setting);

    return res.status(200).json({ status: true, message: "AI chat settings updated.", data: publicConfig(setting) });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /testProvider  body: { provider: {preset, baseUrl, apiKey, model}, index }
exports.testProvider = async (req, res) => {
  try {
    const setting = await currentSetting();
    const body = req.body || {};
    let provider = body.provider || {};
    if (!provider.apiKey || String(provider.apiKey).startsWith(MASK)) {
      const stored = (setting?.aiChat?.providers || [])[Number(body.index)] || {};
      provider = { ...provider, apiKey: stored.apiKey || "" };
    }
    const resolved = resolveProvider(provider);
    const out = await callProvider(resolved, [{ role: "system", content: "You are a friendly host in a chat app." }, { role: "user", content: "Reply with one short friendly greeting in Manglish." }], {
      temperature: 0.7,
      maxTokens: 60,
      timeoutMs: 15000,
    });
    return res.status(200).json({ status: true, message: "Provider is working.", data: { sample: out.text, latencyMs: out.latencyMs, model: out.model } });
  } catch (error) {
    return res.status(200).json({ status: false, message: error.message || "Provider test failed." });
  }
};

// POST /playground  body: { listenerId?, language?, tone?, persona?, messages: [{role, content}] }
exports.playground = async (req, res) => {
  try {
    const cfg = aiChat.config();
    if (!cfg) return res.status(200).json({ status: false, message: "Settings not loaded." });
    const body = req.body || {};

    let listener = null;
    let profile = null;
    if (body.listenerId && mongoose.Types.ObjectId.isValid(body.listenerId)) {
      [listener, profile] = await Promise.all([Listener.findById(body.listenerId).lean(), ListenerAiProfile.findOne({ listenerId: body.listenerId }).lean()]);
    }
    listener = listener || { _id: new mongoose.Types.ObjectId(), name: body.name || "Anjali", age: 24, selfIntro: "Loves late-night talks and filter coffee.", talkTopics: ["Movies", "Life"], location: "Kochi" };
    profile = { ...(profile || {}), ...(typeof body.persona === "string" ? { persona: body.persona } : {}) };

    const history = (Array.isArray(body.messages) ? body.messages : []).filter((m) => m && (m.role === "user" || m.role === "assistant") && typeof m.content === "string").slice(-20);
    if (!history.length) return res.status(200).json({ status: false, message: "Send at least one message." });

    const language = body.language || profile.language || cfg.defaultLanguage;
    const tone = body.tone || profile.tone || cfg.tone;
    const messageCount = history.filter((m) => m.role === "user").length;
    const out = await aiChat.generateReply({ cfg, listener, profile, user: { fullName: "Test user" }, history, language, tone, messageCount });
    return res.status(200).json({
      status: true,
      message: "Success",
      data: { reply: out.text, provider: out.provider, providerLabel: out.providerLabel, model: out.model, latencyMs: out.latencyMs, inputTokens: out.inputTokens, outputTokens: out.outputTokens, systemPrompt: body.showPrompt ? out.system : undefined },
    });
  } catch (error) {
    return res.status(200).json({ status: false, message: error.message || "Generation failed." });
  }
};

// GET /usage?days=14
exports.usage = async (req, res) => {
  try {
    const cfg = aiChat.config() || {};
    const days = Math.min(Math.max(Number(req.query.days) || 14, 1), 60);
    const today = aiChat.dayKey(cfg.timezone);
    const since = new Date(Date.now() - days * 86400000).toISOString().slice(0, 10);

    const [rows, recent, todayRow, topHosts, activeProfiles] = await Promise.all([
      AiUsage.find({ day: { $gte: since } }).sort({ day: 1 }).lean(),
      AiReplyLog.find().sort({ createdAt: -1 }).limit(30).lean(),
      AiUsage.aggregate([{ $match: { day: today } }, { $group: { _id: null, replies: { $sum: "$replies" }, failures: { $sum: "$failures" }, inputTokens: { $sum: "$inputTokens" }, outputTokens: { $sum: "$outputTokens" }, latency: { $sum: "$latencyMsTotal" } } }]),
      AiReplyLog.aggregate([{ $match: { ok: true, day: { $gte: since } } }, { $group: { _id: "$listenerId", name: { $last: "$listenerName" }, replies: { $sum: 1 } } }, { $sort: { replies: -1 } }, { $limit: 8 }]),
      ListenerAiProfile.countDocuments({ enabled: true }),
    ]);

    const byDay = {};
    const byProvider = {};
    for (const r of rows) {
      byDay[r.day] = byDay[r.day] || { day: r.day, replies: 0, failures: 0 };
      byDay[r.day].replies += r.replies;
      byDay[r.day].failures += r.failures;
      const key = r.provider || "unknown";
      byProvider[key] = byProvider[key] || { provider: key, replies: 0, failures: 0, latencyMsTotal: 0, inputTokens: 0, outputTokens: 0 };
      byProvider[key].replies += r.replies;
      byProvider[key].failures += r.failures;
      byProvider[key].latencyMsTotal += r.latencyMsTotal;
      byProvider[key].inputTokens += r.inputTokens;
      byProvider[key].outputTokens += r.outputTokens;
    }
    const t = todayRow[0] || { replies: 0, failures: 0, inputTokens: 0, outputTokens: 0, latency: 0 };

    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        today: { day: today, replies: t.replies, failures: t.failures, inputTokens: t.inputTokens, outputTokens: t.outputTokens, avgLatencyMs: t.replies ? Math.round(t.latency / t.replies) : 0, cap: cfg.maxRepliesPerDay || 0 },
        byDay: Object.values(byDay),
        byProvider: Object.values(byProvider).map((p) => ({ ...p, avgLatencyMs: p.replies ? Math.round(p.latencyMsTotal / p.replies) : 0 })),
        topHosts,
        activeProfiles,
        recent,
        cooldowns: cooldownState(),
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// GET /listenerProfile?listenerId=
exports.getListenerProfile = async (req, res) => {
  try {
    const { listenerId } = req.query;
    if (!mongoose.Types.ObjectId.isValid(listenerId)) return res.status(200).json({ status: false, message: "Invalid listenerId." });
    const profile = await ListenerAiProfile.findOne({ listenerId }).lean();
    return res.status(200).json({ status: true, message: "Success", data: profile || { listenerId, enabled: true, language: "", tone: "", persona: "", interests: [], openingLine: "", callNudge: "inherit", extraRules: "" } });
  } catch (error) {
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /listenerProfile?listenerId=  body: profile fields
exports.updateListenerProfile = async (req, res) => {
  try {
    const { listenerId } = req.query;
    if (!mongoose.Types.ObjectId.isValid(listenerId)) return res.status(200).json({ status: false, message: "Invalid listenerId." });
    const listener = await Listener.findById(listenerId).select("_id isFake").lean();
    if (!listener) return res.status(200).json({ status: false, message: "Listener not found." });
    if (!listener.isFake) return res.status(200).json({ status: false, message: "AI replies are only available for fake hosts." });

    const b = req.body || {};
    const $set = {};
    if (b.enabled !== undefined) $set.enabled = b.enabled === true || b.enabled === "true";
    for (const k of ["language", "tone", "persona", "openingLine", "extraRules"]) if (typeof b[k] === "string") $set[k] = b[k].trim();
    if (["inherit", "on", "off"].includes(b.callNudge)) $set.callNudge = b.callNudge;
    if (Array.isArray(b.interests)) $set.interests = b.interests.map((s) => String(s).trim()).filter(Boolean).slice(0, 12);
    if (typeof b.interests === "string") $set.interests = b.interests.split(",").map((s) => s.trim()).filter(Boolean).slice(0, 12);

    const profile = await ListenerAiProfile.findOneAndUpdate({ listenerId }, { $set, $setOnInsert: { listenerId } }, { new: true, upsert: true }).lean();
    return res.status(200).json({ status: true, message: "AI persona saved.", data: profile });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /assignLanguage  body: { listenerIds: [], language, enabled? }
exports.assignLanguage = async (req, res) => {
  try {
    const { listenerIds, language, enabled } = req.body || {};
    const ids = (Array.isArray(listenerIds) ? listenerIds : []).filter((id) => mongoose.Types.ObjectId.isValid(id));
    if (!ids.length) return res.status(200).json({ status: false, message: "No listeners selected." });
    const fakeIds = (await Listener.find({ _id: { $in: ids }, isFake: true }).select("_id").lean()).map((l) => l._id);
    const $set = {};
    if (typeof language === "string") $set.language = language.trim();
    if (enabled !== undefined) $set.enabled = enabled === true || enabled === "true";
    await ListenerAiProfile.bulkWrite(fakeIds.map((id) => ({ updateOne: { filter: { listenerId: id }, update: { $set, $setOnInsert: { listenerId: id } }, upsert: true } })));
    return res.status(200).json({ status: true, message: `Updated ${fakeIds.length} host${fakeIds.length === 1 ? "" : "s"}.`, data: { updated: fakeIds.length } });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
