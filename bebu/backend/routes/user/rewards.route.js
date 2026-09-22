const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateUserAuthToken = require("../../middleware/validateUserAuthToken.middleware");
const RewardsController = require("../../controllers/user/rewards.controller");

route.get("/hub", validateUserAuthToken, checkAccessWithSecretKey(), RewardsController.hub);
route.post("/profile/claim", validateUserAuthToken, checkAccessWithSecretKey(), RewardsController.claimProfile);
route.post("/referral/apply", validateUserAuthToken, checkAccessWithSecretKey(), RewardsController.applyReferral);

module.exports = route;
