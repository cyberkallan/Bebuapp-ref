const mongoose = require("mongoose");

// Per fake-host AI persona. Kept out of the Listener document so nothing about
// the persona is ever serialised into app-facing listener payloads.
const listenerAiProfileSchema = new mongoose.Schema(
  {
    listenerId: { type: mongoose.Schema.Types.ObjectId, ref: "Listener", required: true, unique: true },
    enabled: { type: Boolean, default: true },
    language: { type: String, default: "" }, // "" = inherit Setting.aiChat.defaultLanguage
    tone: { type: String, default: "" }, // "" = inherit
    persona: { type: String, default: "" }, // free-text personality / backstory
    interests: { type: [String], default: [] },
    openingLine: { type: String, default: "" }, // optional first reply override
    callNudge: { type: String, default: "inherit" }, // inherit | on | off
    extraRules: { type: String, default: "" },
    replies: { type: Number, default: 0 },
    lastReplyAt: { type: Date, default: null },
  },
  { timestamps: true, versionKey: false }
);

module.exports = mongoose.model("ListenerAiProfile", listenerAiProfileSchema);
