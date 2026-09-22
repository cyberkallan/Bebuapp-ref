const mongoose = require("mongoose");

// One row per day per provider: cheap counters for the admin usage panel.
const aiUsageSchema = new mongoose.Schema(
  {
    day: { type: String, required: true }, // YYYY-MM-DD in the configured timezone
    provider: { type: String, default: "" }, // preset id, or "fallback"
    model: { type: String, default: "" },
    replies: { type: Number, default: 0 },
    failures: { type: Number, default: 0 },
    inputTokens: { type: Number, default: 0 },
    outputTokens: { type: Number, default: 0 },
    latencyMsTotal: { type: Number, default: 0 },
  },
  { timestamps: true, versionKey: false }
);
aiUsageSchema.index({ day: 1, provider: 1, model: 1 }, { unique: true });

// Recent replies for the admin log; auto-expires after 7 days.
const aiReplyLogSchema = new mongoose.Schema(
  {
    day: { type: String, default: "" },
    listenerId: { type: mongoose.Schema.Types.ObjectId, default: null },
    listenerName: { type: String, default: "" },
    userId: { type: mongoose.Schema.Types.ObjectId, default: null },
    chatTopicId: { type: mongoose.Schema.Types.ObjectId, default: null },
    language: { type: String, default: "" },
    provider: { type: String, default: "" },
    model: { type: String, default: "" },
    userMessage: { type: String, default: "" },
    reply: { type: String, default: "" },
    latencyMs: { type: Number, default: 0 },
    ok: { type: Boolean, default: true },
    error: { type: String, default: "" },
  },
  { timestamps: true, versionKey: false }
);
aiReplyLogSchema.index({ createdAt: -1 });
aiReplyLogSchema.index({ createdAt: 1 }, { expireAfterSeconds: 7 * 24 * 3600 });
aiReplyLogSchema.index({ userId: 1, day: 1 });

module.exports = {
  AiUsage: mongoose.model("AiUsage", aiUsageSchema),
  AiReplyLog: mongoose.model("AiReplyLog", aiReplyLogSchema),
};
