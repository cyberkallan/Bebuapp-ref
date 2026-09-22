const mongoose = require("mongoose");

const Gift = require("../../models/gift.model");
const User = require("../../models/user.model");
const Listener = require("../../models/listener.model");
const Chat = require("../../models/chat.model");
const ChatTopic = require("../../models/chatTopic.model");
const History = require("../../models/history.model");
const Notification = require("../../models/notification.model");
const Setting = require("../../models/setting.model");

const admin = require("../../util/privateKey");
const generateHistoryUniqueId = require("../../util/generateHistoryUniqueId");
const { HISTORY_TYPE, MESSAGE_TYPE } = require("../../types/constant");
const { normalizeGiftSettings, splitGiftCoins, seedGifts } = require("../../util/gifts");
const aiChat = require("../../util/aiChat/service");

const now = () => new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" });

async function giftSettings() {
  const setting = await Setting.findOne().sort({ createdAt: -1 }).select("gift").lean();
  return normalizeGiftSettings(setting?.gift);
}

function publicGift(g) {
  return { _id: g._id, key: g.key, name: g.name, tagline: g.tagline, image: g.image, accent: g.accent, coins: g.coins, sortOrder: g.sortOrder };
}

// GET /api/user/gift/list — catalog + the flags the app needs to show/hide gift UI
exports.list = async (req, res) => {
  try {
    const settings = await giftSettings();
    if (!settings.enabled) {
      return res.status(200).json({ status: true, message: "Gifts are turned off.", data: { enabled: false, showInChat: false, showInCall: false, gifts: [] } });
    }
    await seedGifts();
    const gifts = await Gift.find({ isActive: true }).sort({ sortOrder: 1, coins: 1 }).lean();
    return res.status(200).json({
      status: true,
      message: "Success",
      data: {
        enabled: true,
        showInChat: settings.showInChat,
        showInCall: settings.showInCall,
        minBalanceHint: settings.minBalanceHint,
        gifts: gifts.map(publicGift),
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};

// POST /api/user/gift/send  body: { giftId, listenerId, chatTopicId?, context: "chat" | "call", callId? }
// Charges the user atomically, credits the host, writes history, drops a gift
// message into the conversation and pushes it to both phones over the socket.
exports.send = async (req, res) => {
  try {
    if (!req.user || !req.user.userId) return res.status(401).json({ status: false, message: "Unauthorized access. Invalid token." });

    const { giftId, listenerId, chatTopicId, context, callId } = req.body || {};
    if (!giftId || !mongoose.Types.ObjectId.isValid(giftId) || !listenerId || !mongoose.Types.ObjectId.isValid(listenerId)) {
      return res.status(200).json({ status: false, message: "giftId and listenerId are required." });
    }

    const settings = await giftSettings();
    if (!settings.enabled) return res.status(200).json({ status: false, message: "Gifts are turned off right now." });

    const userId = new mongoose.Types.ObjectId(req.user.userId);
    const listenerObjId = new mongoose.Types.ObjectId(listenerId);

    const [gift, listener, user] = await Promise.all([
      Gift.findOne({ _id: giftId, isActive: true }).lean(),
      Listener.findOne({ _id: listenerObjId, isBlock: false }).select("_id name image fcmToken isNotificationEnabled isFake isOnline video audio ratePrivateAudioCall ratePrivateVideoCall isAvailableForPrivateAudioCall isAvailableForPrivateVideoCall").lean(),
      User.findById(userId).select("_id fullName profilePic coins isBlock").lean(),
    ]);

    if (!gift) return res.status(200).json({ status: false, message: "This gift is no longer available." });
    if (!listener) return res.status(200).json({ status: false, message: "Host not found." });
    if (!user || user.isBlock) return res.status(200).json({ status: false, message: "Account not allowed to send gifts." });

    const { total, host, platform } = splitGiftCoins(gift.coins, settings.hostSharePercent);

    if ((user.coins || 0) < total) {
      return res.status(200).json({ status: false, code: "INSUFFICIENT_COINS", message: "Not enough coins for this gift.", data: { balance: user.coins || 0, need: total - (user.coins || 0) } });
    }

    // Atomic debit: the balance filter makes a double-tap harmless.
    const debited = await User.findOneAndUpdate(
      { _id: userId, coins: { $gte: total } },
      { $inc: { coins: -total, coinsSpent: total } },
      { new: true, select: "coins" }
    );
    if (!debited) return res.status(200).json({ status: false, code: "INSUFFICIENT_COINS", message: "Not enough coins for this gift.", data: { balance: user.coins || 0 } });

    // Conversation: reuse the topic if we have it, else find/create the pair's topic.
    let chatTopic = null;
    if (chatTopicId && mongoose.Types.ObjectId.isValid(chatTopicId)) chatTopic = await ChatTopic.findById(chatTopicId);
    if (!chatTopic) {
      chatTopic = await ChatTopic.findOne({
        $or: [
          { senderId: userId, receiverId: listenerObjId },
          { senderId: listenerObjId, receiverId: userId },
        ],
      });
    }
    if (!chatTopic) chatTopic = await ChatTopic.create({ senderId: userId, receiverId: listenerObjId });

    const chat = new Chat({
      chatTopicId: chatTopic._id,
      senderId: userId,
      messageType: MESSAGE_TYPE.GIFT,
      message: `🎁 ${gift.name}`,
      gift: { giftId: gift._id, name: gift.name, image: gift.image, accent: gift.accent, coins: total },
      date: now(),
    });

    const [historyId] = await Promise.all([
      generateHistoryUniqueId(),
      chat.save(),
      ChatTopic.updateOne({ _id: chatTopic._id }, { $set: { chatId: chat._id } }),
      Listener.updateOne({ _id: listener._id }, { $inc: { totalCoins: host, currentCoinBalance: host } }),
      Gift.updateOne({ _id: gift._id }, { $inc: { sentCount: 1, coinsTotal: total } }),
    ]);

    await History.create({
      uniqueId: historyId,
      type: HISTORY_TYPE.GIFT,
      userId,
      listenerId: listener._id,
      callerRole: "user",
      callType: context === "call" ? "gift_in_call" : "gift_in_chat",
      userCoin: total,
      listenerCoin: host,
      adminCoin: platform,
      reason: gift.name,
      date: now(),
    });

    // Same envelope the app already parses for messageDispatched.
    const data = {
      _id: chat._id.toString(),
      senderRole: "user",
      receiverRole: "listener",
      chatTopicId: chatTopic._id.toString(),
      senderId: userId.toString(),
      receiverId: listener._id.toString(),
      message: chat.message,
      messageType: MESSAGE_TYPE.GIFT,
      giftId: gift._id.toString(),
      giftName: gift.name,
      giftImage: gift.image,
      giftAccent: gift.accent,
      giftCoins: total,
      hostCoins: host,
      context: context === "call" ? "call" : "chat",
      callId: callId || "",
      date: chat.date,
      isRead: false,
      name: user.fullName || "",
      profilePic: user.profilePic || "",
    };
    const eventData = { data, messageId: chat._id.toString() };
    if (global.io) {
      global.io.in("globalRoom:" + userId.toString()).emit("messageDispatched", eventData);
      global.io.in("globalRoom:" + listener._id.toString()).emit("messageDispatched", eventData);
      // Dedicated event so a host on a call screen can play the animation without being in the chat.
      global.io.in("globalRoom:" + listener._id.toString()).emit("giftReceived", data);
    }

    if (settings.aiThankYou && listener.isFake) {
      aiChat
        .onIncomingMessage({ chatTopic, senderId: userId.toString(), receiverId: listener._id.toString(), receiverRole: "listener", message: `[sent you a gift: ${gift.name} worth ${total} coins]`, messageType: MESSAGE_TYPE.GIFT })
        .catch((e) => console.log("AI gift reply error:", e?.message));
    }

    if (!listener.isFake && listener.isNotificationEnabled && listener.fcmToken) {
      const title = `${user.fullName || "Someone"} sent you a ${gift.name} 🎁`;
      const body = `+${host} coins added to your earnings`;
      try {
        const adminInstance = await admin;
        await adminInstance.messaging().send({
          token: listener.fcmToken,
          data: { title, body, type: "CHAT", senderId: userId.toString(), senderName: String(user.fullName || ""), senderProfilePic: String(user.profilePic || "") },
        });
        await Notification.create({ listenerId: listener._id, title, message: body, date: now() });
      } catch (error) {
        console.log("❌ Gift FCM failed:", error.message);
      }
    }

    return res.status(200).json({
      status: true,
      message: `${gift.name} sent!`,
      data: { balance: debited.coins, coins: total, hostCoins: host, gift: publicGift(gift), chatTopicId: chatTopic._id.toString(), message: { ...data, messageId: chat._id.toString() } },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, error: error.message || "Internal Server Error" });
  }
};
