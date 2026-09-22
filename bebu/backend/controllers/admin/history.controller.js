const History = require("../../models/history.model");

//import model
const User = require("../../models/user.model");
const Listener = require("../../models/listener.model");

//mongoose
const mongoose = require("mongoose");

//get coin history ( user )
exports.getWalletHistory = async (req, res) => {
  try {
    if (!req.query.userId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: listenerId." });
    }

    if (!mongoose.Types.ObjectId.isValid(req.query.userId)) {
      return res.status(200).json({ status: false, message: "Invalid listenerId. It must be a valid MongoDB ObjectId." });
    }

    const userId = new mongoose.Types.ObjectId(req.query.userId);
    const startDate = req.query.startDate || "All";
    const endDate = req.query.endDate || "All";

    const start = parseInt(req.query.start) || 1;
    const limit = parseInt(req.query.limit) || 20;

    let dateFilterQuery = {};
    if (startDate !== "All" && endDate !== "All") {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);
      endDateObj.setHours(23, 59, 59, 999);

      dateFilterQuery = {
        createdAt: {
          $gte: startDateObj,
          $lte: endDateObj,
        },
      };
    }

    const [user, total, transactionHistory, typeWiseStat] = await Promise.all([
      User.findOne({ _id: userId }).select("_id").lean(),
      History.countDocuments({
        ...dateFilterQuery,
        type: { $nin: [7] },
        userId: userId,
        userCoin: { $gt: 0 },
      }),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: { $nin: [7] },
            userId: userId,
            userCoin: { $gt: 0 },
          },
        },
        {
          $lookup: {
            from: "listeners",
            localField: "listenerId",
            foreignField: "_id",
            as: "listener",
          },
        },
        { $unwind: { path: "$listener", preserveNullAndEmptyArrays: true } },
        {
          $addFields: {
            callStatusText: {
              $cond: [
                { $eq: ["$callConnect", false] },
                "Missed Call",
                {
                  $cond: [{ $eq: ["$callerRole", "user"] }, "Outgoing Call", "Incoming Call"],
                },
              ],
            },
          },
        },
        {
          $project: {
            _id: 1,
            uniqueId: 1,
            type: 1,
            userCoin: 1,
            listenerCoin: 1,
            adminCoin: 1,
            callerRole: 1,
            callType: 1,
            isRandom: 1,
            isPrivate: 1,
            callStartTime: 1,
            callEndTime: 1,
            duration: 1,
            price: 1,
            paymentGateway: 1,
            date: 1,
            createdAt: 1,
            callStatusText: 1,
            receiverName: { $ifNull: ["$listener.name", ""] },
            receiverImage: { $ifNull: ["$listener.image", ""] },
            isIncome: {
              $cond: {
                if: { $in: ["$type", [1, 2]] },
                then: true,
                else: {
                  $cond: {
                    if: {
                      $in: ["$type", [3, 4, 5, 6]],
                    },
                    then: false,
                    else: false,
                  },
                },
              },
            },
          },
        },
        { $skip: (start - 1) * limit },
        { $limit: limit },
        { $sort: { createdAt: -1 } },
      ]),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: { $nin: [7] },
            userId: userId,
            userCoin: { $gt: 0 },
          },
        },
        {
          $group: {
            _id: "$type",
            count: { $sum: 1 },
          },
        },
        {
          $project: { type: "$_id", count: 1, _id: 0 },
        },
      ]),
    ]);

    if (!user) {
      return res.status(200).json({ status: false, message: "User not found in the database." });
    }

    return res.status(200).json({
      status: true,
      message: "Transaction history fetch successfully.",
      total,
      data: transactionHistory,
      typeWiseStat,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: "Something went wrong. Please try again later." });
  }
};

//get call history ( user )
exports.listCallRecords = async (req, res) => {
  try {
    if (!req.query.userId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: userId." });
    }

    if (!req.query.userId || !mongoose.Types.ObjectId.isValid(req.query.userId)) {
      return res.status(200).json({ status: false, message: "Valid userId is required." });
    }

    const userId = new mongoose.Types.ObjectId(req.query.userId);
    const startDate = req.query.startDate || "All";
    const endDate = req.query.endDate || "All";

    const start = parseInt(req.query.start) || 1;
    const limit = parseInt(req.query.limit) || 20;

    let dateFilterQuery = {};
    if (startDate !== "All" && endDate !== "All") {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);
      endDateObj.setHours(23, 59, 59, 999);

      dateFilterQuery = {
        createdAt: {
          $gte: startDateObj,
          $lte: endDateObj,
        },
      };
    }

    const [total, transactionHistory] = await Promise.all([
      History.countDocuments({
        ...dateFilterQuery,
        type: { $in: [3, 4, 5, 6] },
        userId: userId,
        userCoin: { $gt: 0 },
      }),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: { $in: [3, 4, 5, 6] },
            userId: userId,
            userCoin: { $gt: 0 },
          },
        },
        {
          $lookup: {
            from: "listeners",
            localField: "listenerId",
            foreignField: "_id",
            as: "listener",
          },
        },
        { $unwind: { path: "$listener", preserveNullAndEmptyArrays: false } },
        {
          $addFields: {
            callStatusText: {
              $cond: [
                { $eq: ["$callConnect", false] },
                "Missed Call",
                {
                  $cond: [{ $eq: ["$callerRole", "user"] }, "Outgoing Call", "Incoming Call"],
                },
              ],
            },
          },
        },
        {
          $project: {
            _id: 1,
            uniqueId: 1,
            userCoin: 1,
            listenerCoin: 1,
            adminCoin: 1,
            callerRole: 1,
            callType: 1,
            isRandom: 1,
            isPrivate: 1,
            callStartTime: 1,
            callEndTime: 1,
            duration: 1,
            date: 1,
            createdAt: 1,
            callStatusText: 1,
            name: { $ifNull: ["$listener.name", ""] },
            image: { $ifNull: ["$listener.image", ""] },
          },
        },
        { $skip: (start - 1) * limit },
        { $limit: limit },
        { $sort: { createdAt: -1 } },
      ]),
    ]);

    return res.status(200).json({
      status: true,
      message: "Transaction history fetch successfully.",
      total,
      data: transactionHistory,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: "Something went wrong. Please try again later." });
  }
};

//get coinplan history ( user )
exports.retrievePurchaseLog = async (req, res) => {
  try {
    if (!req.query.userId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: userId." });
    }

    if (!req.query.userId || !mongoose.Types.ObjectId.isValid(req.query.userId)) {
      return res.status(200).json({ status: false, message: "Valid userId is required." });
    }

    const userId = new mongoose.Types.ObjectId(req.query.userId);
    const startDate = req.query.startDate || "All";
    const endDate = req.query.endDate || "All";

    const start = parseInt(req.query.start) || 1;
    const limit = parseInt(req.query.limit) || 20;

    let dateFilterQuery = {};
    if (startDate !== "All" && endDate !== "All") {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);
      endDateObj.setHours(23, 59, 59, 999);

      dateFilterQuery = {
        createdAt: {
          $gte: startDateObj,
          $lte: endDateObj,
        },
      };
    }

    const [total, transactionHistory] = await Promise.all([
      History.countDocuments({ ...dateFilterQuery, type: 2, userId: userId, userCoin: { $gt: 0 }, price: { $gt: 0 } }),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: 2,
            userId: userId,
            userCoin: { $gt: 0 },
            price: { $gt: 0 },
          },
        },
        {
          $project: {
            _id: 1,
            uniqueId: 1,
            userCoin: 1,
            price: 1,
            paymentGateway: 1,
            date: 1,
            createdAt: 1,
          },
        },
        { $skip: (start - 1) * limit },
        { $limit: limit },
        { $sort: { createdAt: -1 } },
      ]),
    ]);

    return res.status(200).json({
      status: true,
      message: "Transaction history fetch successfully.",
      total,
      data: transactionHistory,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: "Something went wrong. Please try again later." });
  }
};

//get coin history ( listener )
exports.fetchCoinTransactions = async (req, res) => {
  try {
    const { listenerId } = req.query;

    if (!listenerId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: listenerId." });
    }

    if (!mongoose.Types.ObjectId.isValid(listenerId)) {
      return res.status(200).json({ status: false, message: "Invalid listenerId. It must be a valid MongoDB ObjectId." });
    }

    const listenerObjId = new mongoose.Types.ObjectId(listenerId);
    const startDate = req.query.startDate || "All";
    const endDate = req.query.endDate || "All";

    const start = parseInt(req.query.start) || 1;
    const limit = parseInt(req.query.limit) || 20;

    let dateFilterQuery = {};
    if (startDate !== "All" && endDate !== "All") {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);
      endDateObj.setHours(23, 59, 59, 999);

      dateFilterQuery = {
        createdAt: {
          $gte: startDateObj,
          $lte: endDateObj,
        },
      };
    }

    const [listener, total, transactionHistory] = await Promise.all([
      Listener.findOne({ _id: listenerId }).select("_id").lean(),
      History.countDocuments({
        ...dateFilterQuery,
        type: { $in: [3, 4, 5, 6, 7] },
        listenerId: listenerObjId,
        listenerCoin: { $gt: 0 },
      }),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: { $in: [3, 4, 5, 6, 7] },
            listenerId: listenerObjId,
            listenerCoin: { $gt: 0 },
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "userDetails",
          },
        },
        { $unwind: { path: "$userDetails", preserveNullAndEmptyArrays: true } },
        {
          $addFields: {
            callStatusText: {
              $cond: [
                { $eq: ["$callConnect", false] },
                "Missed Call",
                {
                  $cond: [{ $eq: ["$callerRole", "user"] }, "Outgoing Call", "Incoming Call"],
                },
              ],
            },
          },
        },
        {
          $project: {
            _id: 1,
            uniqueId: 1,
            type: 1,
            userCoin: 1,
            listenerCoin: 1,
            adminCoin: 1,
            callerRole: 1,
            callType: 1,
            isRandom: 1,
            isPrivate: 1,
            callStartTime: 1,
            callEndTime: 1,
            duration: 1,
            payoutStatus: 1,
            paymentGateway: 1,
            callStatusText: 1,
            createdAt: 1,
            fullName: { $ifNull: ["$userDetails.fullName", ""] },
            profilePic: { $ifNull: ["$userDetails.profilePic", ""] },
          },
        },
        { $skip: (start - 1) * limit },
        { $limit: limit },
        { $sort: { createdAt: -1 } },
      ]),
    ]);

    if (!listener) {
      return res.status(200).json({ status: false, message: "Listener request not found." });
    }

    return res.status(200).json({
      status: true,
      message: "Transaction history fetch successfully.",
      total,
      data: transactionHistory,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: "Something went wrong. Please try again later." });
  }
};

//get call history ( listener )
exports.fetchCallHistory = async (req, res) => {
  try {
    const { listenerId } = req.query;

    if (!listenerId) {
      return res.status(200).json({ status: false, message: "Missing required query parameter: listenerId." });
    }

    if (!mongoose.Types.ObjectId.isValid(listenerId)) {
      return res.status(200).json({ status: false, message: "Invalid listenerId. It must be a valid MongoDB ObjectId." });
    }

    const listenerObjId = new mongoose.Types.ObjectId(listenerId);
    const startDate = req.query.startDate || "All";
    const endDate = req.query.endDate || "All";

    const start = parseInt(req.query.start) || 1;
    const limit = parseInt(req.query.limit) || 20;

    let dateFilterQuery = {};
    if (startDate !== "All" && endDate !== "All") {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);
      endDateObj.setHours(23, 59, 59, 999);

      dateFilterQuery = {
        createdAt: {
          $gte: startDateObj,
          $lte: endDateObj,
        },
      };
    }

    const [total, transactionHistory] = await Promise.all([
      History.countDocuments({
        ...dateFilterQuery,
        type: { $in: [3, 4, 5, 6] },
        listenerId: listenerObjId,
        listenerCoin: { $gt: 0 },
      }),
      History.aggregate([
        {
          $match: {
            ...dateFilterQuery,
            type: { $in: [3, 4, 5, 6] },
            listenerId: listenerObjId,
            listenerCoin: { $gt: 0 },
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "userDetails",
          },
        },
        { $unwind: { path: "$userDetails", preserveNullAndEmptyArrays: false } },
        {
          $addFields: {
            callStatusText: {
              $cond: [
                { $eq: ["$callConnect", false] },
                "Missed Call",
                {
                  $cond: [{ $eq: ["$callerRole", "listener"] }, "Outgoing Call", "Incoming Call"],
                },
              ],
            },
          },
        },
        {
          $project: {
            _id: 1,
            uniqueId: 1,
            callerRole: 1,
            callType: 1,
            isRandom: 1,
            isPrivate: 1,
            callStartTime: 1,
            callEndTime: 1,
            duration: 1,
            userCoin: 1,
            listenerCoin: 1,
            adminCoin: 1,
            date: 1,
            createdAt: 1,
            callStatusText: 1,
            nickName: { $ifNull: ["$userDetails.nickName", ""] },
            fullName: { $ifNull: ["$userDetails.fullName", ""] },
            profilePic: { $ifNull: ["$userDetails.profilePic", ""] },
          },
        },
        { $skip: (start - 1) * limit },
        { $limit: limit },
        { $sort: { createdAt: -1 } },
      ]),
    ]);

    return res.status(200).json({
      status: true,
      message: "Transaction history fetch successfully.",
      total,
      data: transactionHistory,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: "Something went wrong. Please try again later." });
  }
};
