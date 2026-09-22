//fs
const fs = require("fs");

//path
const path = require("path");

//private key
const admin = require("../util/privateKey");

//import model
const User = require("../models/user.model");
const History = require("../models/history.model");
const Listener = require("../models/listener.model");
const ListenerMatchHistory = require("../models/listenerMatchHistory.model");
const Notification = require("../models/notification.model");
const Rating = require("../models/rating.model");
const Chat = require("../models/chat.model");
const ChatTopic = require("../models/chatTopic.model");
const WithdrawalRecord = require("../models/withdrawalRecord.model");

const mongoose = require("mongoose");

//Helper function to delete all data associated with a userId
const deleteUserDataById = async (userId, user) => {
  const excludedListenerId = new mongoose.Types.ObjectId("688499885442db64c451b898");

  const listeners = await Listener.find({
    userId,
    isFake: false,
    _id: { $ne: excludedListenerId },
  })
    .select("_id image identityProof")
    .lean();

  const listenerIds = listeners.map((l) => l._id);

  const chats = await Chat.find({
    senderId: { $in: [userId, ...listenerIds] },
  })
    .select("image audio")
    .lean();

  for (const chat of chats) {
    if (chat.image) {
      const imagePath = chat.image.split("storage")[1];
      if (imagePath) {
        const fullPath = "storage" + imagePath;
        if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
      }
    }

    if (chat.audio) {
      const audioPath = chat.audio.split("storage")[1];
      if (audioPath) {
        const fullPath = "storage" + audioPath;
        if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
      }
    }
  }

  await Promise.all([
    Chat.deleteMany({ senderId: { $in: [userId, ...listenerIds] } }),
    ChatTopic.deleteMany({
      $or: [{ senderId: userId }, { receiverId: userId }],
    }),
    History.deleteMany({ userId: { $in: [userId, ...listenerIds] } }),
    Notification.deleteMany({ userId: { $in: [userId, ...listenerIds] } }),
    Rating.deleteMany({ userId }),
    ListenerMatchHistory.deleteMany({ userId }),
  ]);

  for (const listener of listeners) {
    if (listener.image) {
      const imgPath = listener.image.split("storage")[1];
      if (imgPath) {
        const filePath = path.join("storage", imgPath);
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      }
    }

    if (Array.isArray(listener.identityProof)) {
      for (const proof of listener.identityProof) {
        const proofPath = proof?.split("storage")[1];
        if (proofPath) {
          const fullPath = "storage" + proofPath;
          if (fs.existsSync(fullPath)) {
            try {
              fs.unlinkSync(fullPath);
            } catch (err) {
              console.error("Error deleting identity proof:", fullPath, err);
            }
          }
        }
      }
    }

    await Promise.all([WithdrawalRecord.deleteMany({ listenerId: listener._id }), ListenerMatchHistory.deleteMany({ lastListenerId: listener._id }), Listener.findByIdAndDelete(listener._id)]);
  }

  if (user.profilePic?.includes("storage")) {
    const imagePath = path.join(__dirname, user.profilePic);
    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
      console.log("Profile picture deleted:", imagePath);
    }
  }

  if (user.firebaseId) {
    try {
      const adminPromise = await admin;
      await adminPromise.auth().deleteUser(user.firebaseId);
      console.log(`✅ Firebase user deleted: ${user.firebaseId}`);
    } catch (err) {
      console.error(`❌ Failed to delete Firebase user ${user.firebaseId}:`, err.message);
    }
  }

  await User.findByIdAndDelete(userId);
};

module.exports = deleteUserDataById;
