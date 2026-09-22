const Setting = require("../../models/setting.model");

const THEMES = ["dark", "light", "system"];
const ACCENTS = [
  { id: "pink", label: "Bebu pink", primary: "#FF3D8A", deep: "#E11D74", light: "#FF5FA2" },
  { id: "violet", label: "Violet", primary: "#8B5CF6", deep: "#6D28D9", light: "#A78BFA" },
  { id: "coral", label: "Coral", primary: "#FF6B4A", deep: "#E2452B", light: "#FF8F73" },
  { id: "ocean", label: "Ocean", primary: "#38BDF8", deep: "#0284C7", light: "#7DD3FC" },
  { id: "mint", label: "Mint", primary: "#34D399", deep: "#059669", light: "#6EE7B7" },
  { id: "sunset", label: "Sunset", primary: "#FB923C", deep: "#EA580C", light: "#FDBA74" },
];
const MOTION = ["full", "reduced"];
const CORNERS = ["rounded", "soft", "sharp"];

const DEFAULTS = {
  defaultTheme: "dark",
  allowUserThemeChoice: true,
  askThemeOnOnboarding: true,
  accent: "pink",
  ambientGlow: true,
  motion: "full",
  cornerStyle: "rounded",
  liveRings: true,
  coinAnimation: true,
  soundEffects: true,
  chatSounds: true,
  haptics: true,
};

function normalize(raw = {}) {
  const a = { ...DEFAULTS, ...(raw && typeof raw.toObject === "function" ? raw.toObject() : raw) };
  return {
    defaultTheme: THEMES.includes(a.defaultTheme) ? a.defaultTheme : DEFAULTS.defaultTheme,
    allowUserThemeChoice: a.allowUserThemeChoice !== false,
    askThemeOnOnboarding: a.askThemeOnOnboarding !== false,
    accent: ACCENTS.some((x) => x.id === a.accent) ? a.accent : DEFAULTS.accent,
    ambientGlow: a.ambientGlow !== false,
    motion: MOTION.includes(a.motion) ? a.motion : DEFAULTS.motion,
    cornerStyle: CORNERS.includes(a.cornerStyle) ? a.cornerStyle : DEFAULTS.cornerStyle,
    liveRings: a.liveRings !== false,
    coinAnimation: a.coinAnimation !== false,
    soundEffects: a.soundEffects !== false,
    chatSounds: a.chatSounds !== false,
    haptics: a.haptics !== false,
  };
}

async function currentSetting() {
  return Setting.findOne().sort({ createdAt: -1 });
}

// GET /api/admin/appearance
exports.getAppearance = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        settingId: setting._id,
        appearance: normalize(setting.appearance),
        options: { themes: THEMES, accents: ACCENTS, motion: MOTION, cornerStyles: CORNERS },
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// PATCH /api/admin/appearance  body: partial appearance
exports.updateAppearance = async (req, res) => {
  try {
    const setting = await currentSetting();
    if (!setting) return res.status(200).json({ status: false, message: "Setting does not found." });

    const body = req.body || {};
    const merged = { ...normalize(setting.appearance) };
    for (const k of Object.keys(DEFAULTS)) {
      if (body[k] === undefined) continue;
      merged[k] = typeof DEFAULTS[k] === "boolean" ? body[k] === true || body[k] === "true" : String(body[k]).trim();
    }
    setting.appearance = normalize(merged);
    setting.markModified("appearance");
    await setting.save();
    global.updateSettingFile(setting);

    return res.status(200).json({ status: true, message: "Appearance updated.", data: setting.appearance });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

exports.normalizeAppearance = normalize;
exports.APPEARANCE_ACCENTS = ACCENTS;
