const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

// Admin → Downloads: release bundles (source zips, APK/AAB, docs) dropped into
// DOWNLOADS_DIR on the server. Nothing here is public; every request goes
// through validateAdminAuth. Files are described by an optional
// DOWNLOADS_DIR/manifest.json: { "<file>": { "title", "description", "group" } }.
const DOWNLOADS_DIR = path.resolve(process.env.DOWNLOADS_DIR || path.join(__dirname, "..", "..", "storage", "downloads"));

const KNOWN_EXT = new Set([".zip", ".apk", ".aab", ".ipa", ".pdf", ".md", ".txt", ".json", ".tar.gz", ".tgz"]);

function ensureDir() {
  fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
}

function readManifest() {
  try {
    return JSON.parse(fs.readFileSync(path.join(DOWNLOADS_DIR, "manifest.json"), "utf8"));
  } catch {
    return {};
  }
}

function guessGroup(name) {
  const n = name.toLowerCase();
  if (n.endsWith(".apk") || n.endsWith(".aab") || n.endsWith(".ipa")) return "Mobile builds";
  if (n.includes("codecanyon") || n.includes("marketplace")) return "Marketplace package";
  if (n.includes("production") || n.includes("source")) return "Source code";
  if (n.endsWith(".pdf") || n.endsWith(".md")) return "Documentation";
  return "Other";
}

function safeName(name) {
  const base = path.basename(String(name || ""));
  if (!base || base === "manifest.json" || base.startsWith(".")) return null;
  const full = path.join(DOWNLOADS_DIR, base);
  if (!full.startsWith(DOWNLOADS_DIR + path.sep)) return null;
  return { base, full };
}

function checksumFor(base) {
  try {
    const sums = fs.readFileSync(path.join(DOWNLOADS_DIR, "SHA256SUMS.txt"), "utf8");
    const line = sums.split("\n").find((l) => l.trim().endsWith(" " + base) || l.trim().endsWith("*" + base));
    return line ? line.trim().split(/\s+/)[0] : null;
  } catch {
    return null;
  }
}

// GET /api/admin/download — list files
exports.list = async (req, res) => {
  try {
    ensureDir();
    const manifest = readManifest();
    const files = fs
      .readdirSync(DOWNLOADS_DIR, { withFileTypes: true })
      .filter((d) => d.isFile() && d.name !== "manifest.json" && d.name !== "SHA256SUMS.txt" && !d.name.startsWith("."))
      .filter((d) => KNOWN_EXT.has(path.extname(d.name).toLowerCase()) || d.name.endsWith(".tar.gz"))
      .map((d) => {
        const stat = fs.statSync(path.join(DOWNLOADS_DIR, d.name));
        const meta = manifest[d.name] || {};
        return {
          name: d.name,
          title: meta.title || d.name,
          description: meta.description || "",
          group: meta.group || guessGroup(d.name),
          bytes: stat.size,
          modifiedAt: stat.mtime,
          sha256: checksumFor(d.name),
        };
      })
      .sort((a, b) => new Date(b.modifiedAt) - new Date(a.modifiedAt));

    return res.status(200).json({ status: true, message: "Success", dir: DOWNLOADS_DIR, files });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};

// GET /api/admin/download/file?name=… — stream one file (supports Range)
exports.file = async (req, res) => {
  try {
    const target = safeName(req.query.name);
    if (!target || !fs.existsSync(target.full) || !fs.statSync(target.full).isFile()) {
      return res.status(404).json({ status: false, message: "File not found." });
    }
    return res.download(target.full, target.base, { dotfiles: "deny", cacheControl: false });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};

// Browsers cannot attach the admin's bearer token to a plain download link, so
// the panel first asks for a short-lived signed URL and then navigates to it.
const LINK_TTL_MS = 10 * 60 * 1000;

function sign(base, exp) {
  const secret = process.env.secretKey || process.env.SECRET_KEY || "bebu";
  return crypto.createHmac("sha256", secret).update(`${base}:${exp}`).digest("hex");
}

// GET /api/admin/download/link?name=… (admin auth) → { url }
exports.link = async (req, res) => {
  try {
    const target = safeName(req.query.name);
    if (!target || !fs.existsSync(target.full)) return res.status(404).json({ status: false, message: "File not found." });
    const exp = Date.now() + LINK_TTL_MS;
    const sig = sign(target.base, exp);
    const url = `/api/admin/download/get?name=${encodeURIComponent(target.base)}&exp=${exp}&sig=${sig}`;
    return res.status(200).json({ status: true, message: "Success", url, expiresAt: new Date(exp) });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};

// GET /api/admin/download/get?name=&exp=&sig= (signed, no bearer token)
exports.signedFile = async (req, res) => {
  try {
    const { name, exp, sig } = req.query;
    const target = safeName(name);
    const expNum = Number(exp);
    if (!target || !expNum || !sig) return res.status(400).json({ status: false, message: "Invalid link." });
    if (Date.now() > expNum) return res.status(410).json({ status: false, message: "This download link has expired. Open the Downloads page again." });
    const expected = sign(target.base, expNum);
    if (expected.length !== String(sig).length || !crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(String(sig)))) {
      return res.status(403).json({ status: false, message: "Invalid link." });
    }
    if (!fs.existsSync(target.full) || !fs.statSync(target.full).isFile()) return res.status(404).json({ status: false, message: "File not found." });
    return res.download(target.full, target.base, { dotfiles: "deny", cacheControl: false });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};
