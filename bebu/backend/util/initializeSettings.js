const fs = require("fs");

//import model
const Setting = require("../models/setting.model");

//settingJson (fallback defaults when the database is empty)
const settingJson = require("../setting");

const hasServiceAccount = (key) => !!(key && typeof key === "object" && key.private_key && key.client_email);

// Firebase service account for first boot: FIREBASE_SERVICE_ACCOUNT_JSON (inline)
// or FIREBASE_SERVICE_ACCOUNT_FILE (path). install.sh writes the file.
function serviceAccountFromEnv() {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) return JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    const file = process.env.FIREBASE_SERVICE_ACCOUNT_FILE;
    if (file && fs.existsSync(file) && fs.statSync(file).isFile()) {
      const parsed = JSON.parse(fs.readFileSync(file, "utf8"));
      return hasServiceAccount(parsed) ? parsed : null;
    }
  } catch (error) {
    console.error("❌ Could not read the Firebase service account from the environment:", error.message);
  }
  return null;
}

async function initializeSettings() {
  try {
    let setting = await Setting.findOne().sort({ createdAt: -1 });

    if (!setting) {
      // Fresh database: create the Settings document from schema defaults plus
      // whatever the installer provided.
      setting = new Setting({
        ...settingJson,
        privateKey: serviceAccountFromEnv() || settingJson.privateKey || {},
        zegoAppId: process.env.ZEGO_APP_ID || settingJson.zegoAppId,
        zegoAppSignIn: process.env.ZEGO_APP_SIGN || settingJson.zegoAppSignIn,
      });
      await setting.save();
      console.log("✅ Settings created (first boot)");
    } else if (!hasServiceAccount(setting.privateKey)) {
      const fromEnv = serviceAccountFromEnv();
      if (fromEnv) {
        setting.privateKey = fromEnv;
        await setting.save();
        console.log("✅ Firebase service account loaded from the environment");
      }
    }

    global.settingJSON = setting;
    console.log("✅ Settings Initialized");

    if (!hasServiceAccount(setting.privateKey)) {
      console.error(
        "\n❌ No Firebase service account configured.\n" +
          "   Put the JSON from Firebase console → Project settings → Service accounts → Generate new private key\n" +
          "   at deploy/firebase-service-account.json (or paste it in Admin → Settings → Firebase private key),\n" +
          "   then restart: docker compose restart backend\n"
      );
      process.exit(1);
    }
  } catch (error) {
    console.error("❌ Failed to initialize settings:", error);
    process.exit(1);
  }
}

module.exports = initializeSettings;
