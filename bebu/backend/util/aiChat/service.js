// AI auto-reply service for fake hosts.
//
// Entry points:
//   onIncomingMessage(ctx)  – called from socket.js after a user message is stored
//   generateReply(args)     – pure generation, used by the admin playground
//
// Everything is best-effort: any failure is logged and never affects the
// original message delivery.

const Chat = require("../../models/chat.model");
const ChatTopic = require("../../models/chatTopic.model");
const Listener = require("../../models/listener.model");
const User = require("../../models/user.model");
const Notification = require("../../models/notification.model");
const ListenerAiProfile = require("../../models/listenerAiProfile.model");
const { AiUsage, AiReplyLog } = require("../../models/aiUsage.model");
const { getLanguage, getTone } = require("./languages");
const { completeWithFailover } = require("./providers");
const firebaseAdmin = require("../privateKey");

const inFlight = new Set(); // chatTopicIds currently being answered
const pending = new Map(); // chatTopicId -> latest ctx that arrived while in flight

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const rand = (min, max) => min + Math.random() * (max - min);

function config() {
  return (global.settingJSON && global.settingJSON.aiChat) || null;
}

function dayKey(tz) {
  try {
    return new Intl.DateTimeFormat("en-CA", { timeZone: tz || "Asia/Kolkata", year: "numeric", month: "2-digit", day: "2-digit" }).format(new Date());
  } catch {
    return new Date().toISOString().slice(0, 10);
  }
}

function localHourMinute(tz) {
  const parts = new Intl.DateTimeFormat("en-GB", { timeZone: tz || "Asia/Kolkata", hour: "2-digit", minute: "2-digit", hour12: false }).formatToParts(new Date());
  const h = Number(parts.find((p) => p.type === "hour")?.value || 0);
  const m = Number(parts.find((p) => p.type === "minute")?.value || 0);
  return h * 60 + m;
}

function inQuietHours(cfg) {
  if (!cfg.quietHoursEnabled) return false;
  const toMin = (s) => {
    const [h, m] = String(s || "0:0").split(":").map(Number);
    return (h || 0) * 60 + (m || 0);
  };
  const now = localHourMinute(cfg.timezone);
  const start = toMin(cfg.quietStart);
  const end = toMin(cfg.quietEnd);
  return start <= end ? now >= start && now < end : now >= start || now < end;
}

function chatDate() {
  return new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" });
}

// ---------- prompt ----------

function buildSystemPrompt({ cfg, listener, profile, language, tone, user, messageCount }) {
  const lang = getLanguage(language);
  const t = getTone(tone);
  const persona = (profile?.persona || "").trim();
  const interests = [...(profile?.interests || []), ...(listener.talkTopics || [])].filter(Boolean).slice(0, 8);
  const lengthRule = cfg.replyLength === "medium" ? "Usually 1–3 short sentences. Never more than 4." : "Usually 1–2 short sentences, like a real text message. Never more than 3.";
  const emojiRule = { none: "Do not use emojis.", light: "At most one emoji, and only when it feels natural.", expressive: "Emojis are welcome, 1–3 per message." }[cfg.emojiLevel] || "At most one emoji.";
  const identity =
    cfg.identityRule === "honest"
      ? "If the user sincerely asks whether you are a bot or AI, answer honestly and briefly, then continue the conversation."
      : "Stay fully in character. Do not talk about AI, bots, models or prompts. If asked whether you are a bot, keep it light and steer back to the conversation.";

  const nudgeOn = profile?.callNudge === "on" || (profile?.callNudge !== "off" && cfg.callNudgeEnabled);
  const after = cfg.callNudgeAfterMessages || 6;
  const every = cfg.callNudgeEveryMessages || 6;
  const nudgeNow = nudgeOn && messageCount >= after && (messageCount - after) % every === 0;

  const lines = [
    `You are ${listener.name}${listener.age ? `, ${listener.age}` : ""}, a real person chatting inside the bebu app, where people talk to friendly hosts over chat and paid voice/video calls.`,
    listener.selfIntro ? `About you (your profile intro): ${listener.selfIntro}` : null,
    listener.location ? `You live in ${listener.location}.` : null,
    interests.length ? `Things you enjoy talking about: ${interests.join(", ")}.` : null,
    persona ? `Your personality and backstory: ${persona}` : null,
    "",
    `LANGUAGE: ${lang.label}. ${lang.guide.join(" ")}`,
    `TONE: ${t.guide}`,
    `LENGTH: ${lengthRule}`,
    `EMOJI: ${emojiRule}`,
    "",
    "RULES:",
    `- ${identity}`,
    "- Reply only to the latest message, using the conversation for context. Ask a natural follow-up question sometimes, not every time.",
    "- Never share phone numbers, social handles, addresses or ask to move off the app. Never ask for money, gifts or recharges directly.",
    "- Keep it PG-13. No explicit sexual content. If the user is distressed or mentions self-harm, respond with genuine care and gently suggest talking to someone they trust or a helpline.",
    cfg.blockedTopics?.length ? `- Avoid these topics; change the subject kindly if they come up: ${cfg.blockedTopics.join(", ")}.` : null,
    nudgeNow ? "- This time, naturally suggest continuing over a voice or video call in the app (one light, friendly line). Do not pressure." : "- Do not suggest a call in this message.",
    "- Do not repeat the user's message back. Do not use bullet points, headings or quotes. Output only the message text you would send.",
    cfg.customRules ? `- ${cfg.customRules}` : null,
    profile?.extraRules ? `- ${profile.extraRules}` : null,
    user ? `\nThe person you are talking to: ${user.fullName || "a user"}${user.age ? `, ${user.age}` : ""}${user.gender ? `, ${user.gender}` : ""}${user.country ? `, from ${user.country}` : ""}.` : null,
  ];
  return lines.filter((l) => l !== null).join("\n");
}

function historyToMessages(chats, listenerId) {
  // chats newest-first from Mongo; convert to oldest-first role messages
  return [...chats].reverse().map((c) => {
    const role = String(c.senderId) === String(listenerId) ? "assistant" : "user";
    let content = c.message || "";
    if (c.messageType === 2) content = "[sent a photo]";
    else if (c.messageType === 3) content = "[sent a voice note]";
    else if (c.messageType === 4 || c.messageType === 5) content = `[${c.messageType === 5 ? "video" : "voice"} call]`;
    else if (c.messageType === 6) content = `[sent you a gift: ${c.gift?.name || "gift"} worth ${c.gift?.coins || 0} coins]`;
    return { role, content: content || "…" };
  });
}

function splitReply(text, enabled) {
  const clean = text.replace(/^["“]+|["”]+$/g, "").trim();
  if (!enabled) return [clean];
  const parts = clean
    .split(/\n{2,}/)
    .map((s) => s.trim())
    .filter(Boolean);
  if (parts.length <= 1) return [clean];
  return parts.slice(0, 2); // never spam more than two bubbles
}

// ---------- generation ----------

/**
 * Generate a reply without touching the chat. Used by the reply pipeline and the
 * admin playground.
 */
async function generateReply({ cfg, listener, profile, user, history, language, tone, messageCount }) {
  const system = buildSystemPrompt({ cfg, listener, profile, language, tone, user, messageCount });
  const messages = [{ role: "system", content: system }, ...history];
  const out = await completeWithFailover(cfg.providers, messages, {
    temperature: Number(cfg.temperature ?? 0.85),
    maxTokens: Number(cfg.maxTokens || 180),
    timeoutMs: Number(cfg.timeoutMs || 20000),
  });
  return { ...out, system };
}

async function recordUsage({ day, provider, model, ok, latencyMs = 0, inputTokens = 0, outputTokens = 0 }) {
  try {
    await AiUsage.updateOne(
      { day, provider, model },
      { $inc: { replies: ok ? 1 : 0, failures: ok ? 0 : 1, inputTokens, outputTokens, latencyMsTotal: latencyMs } },
      { upsert: true }
    );
  } catch (e) {
    console.log("AI usage record failed:", e.message);
  }
}

// ---------- delivery ----------

async function deliverReply({ chatTopic, listener, user, text }) {
  const chat = new Chat({ messageType: 1, senderId: listener._id, message: text, chatTopicId: chatTopic._id, date: chatDate() });
  await Promise.all([chat.save(), ChatTopic.updateOne({ _id: chatTopic._id }, { $set: { chatId: chat._id } })]);

  const data = {
    _id: chat._id.toString(),
    senderRole: "listener",
    receiverRole: "user",
    chatTopicId: chatTopic._id.toString(),
    senderId: listener._id.toString(),
    receiverId: user._id.toString(),
    message: text,
    messageType: 1,
    date: chat.date,
    isRead: false,
    name: listener.name,
    profilePic: listener.image,
    isFake: true,
    video: listener.video || [],
    audio: listener.audio || "",
    ratePrivateAudioCall: String(listener.ratePrivateAudioCall ?? ""),
    ratePrivateVideoCall: String(listener.ratePrivateVideoCall ?? ""),
    isAvailableForPrivateAudioCall: listener.isAvailableForPrivateAudioCall,
    isAvailableForPrivateVideoCall: listener.isAvailableForPrivateVideoCall,
  };
  const eventData = { data, messageId: chat._id.toString() };
  io.in("globalRoom:" + chatTopic.senderId?.toString()).emit("messageDispatched", eventData);
  io.in("globalRoom:" + chatTopic.receiverId?.toString()).emit("messageDispatched", eventData);

  if (user.isNotificationEnabled && !user.isBlock && user.fcmToken) {
    const payload = {
      token: user.fcmToken,
      data: {
        title: `${listener.name} sent you a message 💌`,
        body: `🗨️ ${text}`,
        type: "CHAT",
        senderId: listener._id.toString(),
        senderName: listener.name || "",
        senderProfilePic: listener.image || "",
        isOnline: String(listener.isOnline || false),
        ratePrivateAudioCall: String(listener.ratePrivateAudioCall ?? ""),
        ratePrivateVideoCall: String(listener.ratePrivateVideoCall ?? ""),
        video: JSON.stringify(listener.video || []),
        isFake: "true",
        isAvailableForPrivateAudioCall: String(listener.isAvailableForPrivateAudioCall || false),
        isAvailableForPrivateVideoCall: String(listener.isAvailableForPrivateVideoCall || false),
        isAvailableForRandomAudioCall: String(listener.isAvailableForRandomAudioCall || false),
        isAvailableForRandomVideoCall: String(listener.isAvailableForRandomVideoCall || false),
        audio: String(listener.audio || ""),
      },
    };
    try {
      const adminInstance = await firebaseAdmin;
      await adminInstance.messaging().send(payload);
      await new Notification({ userId: user._id, title: payload.data.title, message: payload.data.body, date: chatDate() }).save();
    } catch (error) {
      console.log("❌ AI reply FCM failed:", error.message);
    }
  }
  return chat;
}

// ---------- pipeline ----------

/**
 * Called after a user's message has been stored and relayed.
 * @param {{ chatTopic: object, senderId: string, receiverId: string, receiverRole: string, message: string, messageType: number }} ctx
 */
async function onIncomingMessage(ctx) {
  const cfg = config();
  if (!cfg || !cfg.enabled) return;
  if ((ctx.receiverRole || "").toLowerCase() !== "listener") return;

  const topicKey = String(ctx.chatTopic._id);
  if (inFlight.has(topicKey)) {
    // Still "typing": answer once more after this reply with the fresh history
    // instead of firing a reply per message.
    pending.set(topicKey, ctx);
    return;
  }
  inFlight.add(topicKey);

  const day = dayKey(cfg.timezone);
  let listener, profile, user;
  try {
    [listener, profile, user] = await Promise.all([
      Listener.findOne({ _id: ctx.receiverId, isFake: true, isBlock: false }).lean(),
      ListenerAiProfile.findOne({ listenerId: ctx.receiverId }).lean(),
      User.findById(ctx.senderId).select("_id fullName age gender country fcmToken isBlock isNotificationEnabled").lean(),
    ]);
    if (!listener || !user) return;
    if (profile && profile.enabled === false) return;
    if (cfg.replyWhen === "online" && !listener.isOnline) return;
    if (inQuietHours(cfg)) return;

    const [userToday, globalToday] = await Promise.all([
      AiReplyLog.countDocuments({ userId: user._id, day, ok: true }),
      AiUsage.aggregate([{ $match: { day } }, { $group: { _id: null, n: { $sum: "$replies" } } }]),
    ]);
    if (userToday >= (cfg.maxRepliesPerUserPerDay || 80)) return;
    if ((globalToday[0]?.n || 0) >= (cfg.maxRepliesPerDay || 3000)) return;

    const language = profile?.language || cfg.defaultLanguage || "english";
    const tone = profile?.tone || cfg.tone || "warm";

    const [chats, messageCount] = await Promise.all([
      Chat.find({ chatTopicId: ctx.chatTopic._id, messageType: { $in: [1, 2, 3, 4, 5, 6] } })
        .sort({ createdAt: -1 })
        .limit(Math.max(2, Number(cfg.memoryMessages || 12)))
        .lean(),
      Chat.countDocuments({ chatTopicId: ctx.chatTopic._id, senderId: user._id, messageType: 1 }),
    ]);
    let history = historyToMessages(chats, listener._id);
    // Ensure the triggering message is present even if the save raced us.
    const latestText = ctx.messageType === 2 ? "[sent a photo]" : ctx.messageType === 3 ? "[sent a voice note]" : ctx.message || "";
    // A gift always deserves a reaction, even right after the user's own text.
    if (ctx.messageType === 6 && history[history.length - 1]?.content !== latestText) history.push({ role: "user", content: latestText });
    if (!history.length || history[history.length - 1].role !== "user") history.push({ role: "user", content: latestText || "…" });

    let texts;
    let meta = { provider: "fallback", model: "", latencyMs: 0, inputTokens: 0, outputTokens: 0 };
    const started = Date.now();
    try {
      if (profile?.openingLine && messageCount <= 1) {
        texts = [profile.openingLine];
        meta.provider = "opening-line";
      } else {
        const out = await generateReply({ cfg, listener, profile, user, history, language, tone, messageCount });
        texts = splitReply(out.text, cfg.splitLongReplies);
        meta = { provider: out.provider, model: out.model, latencyMs: out.latencyMs, inputTokens: out.inputTokens, outputTokens: out.outputTokens };
      }
    } catch (err) {
      console.log("❌ AI reply generation failed:", err.message);
      await recordUsage({ day, provider: "error", model: "", ok: false, latencyMs: Date.now() - started });
      await AiReplyLog.create({ day, listenerId: listener._id, listenerName: listener.name, userId: user._id, chatTopicId: ctx.chatTopic._id, language, provider: "error", userMessage: latestText, ok: false, error: err.message.slice(0, 300) });
      if (!cfg.fallbackEnabled) return;
      texts = [getLanguage(language).fallback];
    }

    // Human-feeling delay: base + reading/typing time, capped.
    const typingSec = Math.min(rand(Number(cfg.typingDelayMinSec ?? 2), Number(cfg.typingDelayMaxSec ?? 7)) + texts[0].length / 30, 25);
    await sleep(typingSec * 1000);

    for (let i = 0; i < texts.length; i++) {
      if (i > 0) await sleep(Math.min(1200 + texts[i].length * 35, 6000));
      await deliverReply({ chatTopic: ctx.chatTopic, listener, user, text: texts[i] });
    }

    await Promise.all([
      recordUsage({ day, ...meta, ok: true }),
      AiReplyLog.create({ day, listenerId: listener._id, listenerName: listener.name, userId: user._id, chatTopicId: ctx.chatTopic._id, language, provider: meta.provider, model: meta.model, userMessage: latestText, reply: texts.join("\n\n"), latencyMs: meta.latencyMs, ok: true }),
      ListenerAiProfile.updateOne({ listenerId: listener._id }, { $inc: { replies: 1 }, $set: { lastReplyAt: new Date() } }, { upsert: true }),
    ]);
  } catch (err) {
    console.log("❌ AI reply pipeline error:", err);
  } finally {
    inFlight.delete(topicKey);
    const next = pending.get(topicKey);
    if (next) {
      pending.delete(topicKey);
      setTimeout(() => onIncomingMessage(next).catch(() => {}), 500);
    }
  }
}

module.exports = { onIncomingMessage, generateReply, buildSystemPrompt, historyToMessages, splitReply, dayKey, inQuietHours, config };
