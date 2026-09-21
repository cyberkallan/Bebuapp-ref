const Notification = require("../../models/notification.model");

//import model
const Listener = require("../../models/listener.model");

//mongoose
const mongoose = require("mongoose");

//get notification list
exports.fetchNotifications = async (req, res, next) => {
  try {
    const { listenerId } = req.query;

    if (!listenerId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: listenerId." });
    }

    if (!mongoose.Types.ObjectId.isValid(listenerId)) {
      return res.status(200).json({ status: false, message: "Invalid listenerId. It must be a valid MongoDB ObjectId." });
    }

    const listenerObjId = new mongoose.Types.ObjectId(listenerId);

    const [listener, notification] = await Promise.all([Listener.findById(listenerObjId).select("_id isBlock").lean(), Notification.find({ listenerId: listenerObjId }).sort({ creatdAt: -1 }).lean()]);

    if (!listener) {
      return res.status(200).json({ status: false, message: "Listener does not found." });
    }

    if (listener.isBlock) {
      return res.status(200).json({ status: false, message: "you are blocked by the admin." });
    }

    return res.status(200).json({
      status: true,
      message: "Retrive the notification list.",
      notification: notification,
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};

//clear all notification
exports.resetNotificationHistory = async (req, res) => {
  try {
    const { listenerId } = req.query;

    if (!listenerId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: listenerId." });
    }

    if (!mongoose.Types.ObjectId.isValid(listenerId)) {
      return res.status(200).json({ status: false, message: "Invalid listenerId. It must be a valid MongoDB ObjectId." });
    }

    const listenerObjId = new mongoose.Types.ObjectId(listenerId);

    const [listener, clearNotificationHistory] = await Promise.all([Listener.findById(listenerObjId).select("_id isBlock").lean(), Notification.deleteMany({ listenerId: listenerObjId })]);

    if (!listener) {
      return res.status(200).json({ status: false, message: "Listener does not found." });
    }

    if (listener.isBlock) {
      return res.status(200).json({ status: false, message: "you are blocked by the admin." });
    }

    if (clearNotificationHistory.deletedCount > 0) {
      return res.status(200).json({
        status: true,
        message: "Successfully cleared all Notification history.",
      });
    } else {
      return res.status(200).json({
        status: false,
        message: "Notification history not found.",
      });
    }
  } catch (error) {
    console.log(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};
