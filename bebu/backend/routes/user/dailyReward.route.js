const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateUserAuthToken = require("../../middleware/validateUserAuthToken.middleware");
const DailyRewardController = require("../../controllers/user/dailyReward.controller");

// Daily streak reward: what can I claim today, and claim it.
route.get("/status", validateUserAuthToken, checkAccessWithSecretKey(), DailyRewardController.status);
route.post("/claim", validateUserAuthToken, checkAccessWithSecretKey(), DailyRewardController.claim);

module.exports = route;
