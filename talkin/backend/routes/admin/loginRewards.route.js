const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const LoginRewardsController = require("../../controllers/admin/loginRewards.controller");

// Sign-in methods + daily streak reward configuration
route.get("/", checkAccessWithSecretKey(), LoginRewardsController.get);
route.patch("/", checkAccessWithSecretKey(), LoginRewardsController.update);

module.exports = route;
