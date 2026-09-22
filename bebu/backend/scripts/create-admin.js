#!/usr/bin/env node
// Create (or reset) an admin-panel account without the sign-up screen.
//
//   docker compose exec backend node scripts/create-admin.js you@example.com 'StrongPassword!'
//
// Creates the Firebase email/password user (the admin panel signs in with
// Firebase) and the matching Admin document, or resets the password if the
// admin already exists. Needs the Settings document to hold the Firebase
// service account (first boot does that from deploy/firebase-service-account.json).
const mongoose = require("mongoose");
const firebase = require("firebase-admin");

const [email, password, name] = process.argv.slice(2);
if (!email || !password) {
  console.error("usage: node scripts/create-admin.js <email> <password> [name]");
  process.exit(2);
}
if (password.length < 8) {
  console.error("password must be at least 8 characters");
  process.exit(2);
}

(async () => {
  const uri = process.env.MongoDb_Connection_String || "mongodb://127.0.0.1:27017/bebu";
  await mongoose.connect(uri);

  const Setting = require("../models/setting.model");
  const Admin = require("../models/admin.model");
  const setting = await Setting.findOne().sort({ createdAt: -1 }).lean();
  const key = setting && setting.privateKey;
  if (!key || !key.private_key) {
    console.error("No Firebase service account in Settings yet. Start the backend once with deploy/firebase-service-account.json in place.");
    process.exit(1);
  }
  const cryptr = require("../util/cryptr");

  if (!firebase.apps.length) firebase.initializeApp({ credential: firebase.credential.cert(key) });
  let user;
  try {
    user = await firebase.auth().getUserByEmail(email);
    await firebase.auth().updateUser(user.uid, { password, emailVerified: true });
    console.log("Firebase user updated:", user.uid);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    user = await firebase.auth().createUser({ email, password, emailVerified: true, displayName: name || "Admin" });
    console.log("Firebase user created:", user.uid);
  }

  const admin = await Admin.findOneAndUpdate(
    { email },
    { $set: { uid: user.uid, email, name: name || "Admin", password: cryptr.encrypt(password), purchaseCode: "self-hosted" } },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  ).lean();
  console.log(`Admin ready: ${admin.email} (${admin._id}). Sign in at ${process.env.PUBLIC_URL || "your admin URL"}/login`);
  process.exit(0);
})().catch((error) => {
  console.error("Failed:", error.message);
  process.exit(1);
});
