const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateUserAuthToken = require("../../middleware/validateUserAuthToken.middleware");
const GiftController = require("../../controllers/user/gift.controller");

route.get("/list", validateUserAuthToken, checkAccessWithSecretKey(), GiftController.list);
route.post("/send", validateUserAuthToken, checkAccessWithSecretKey(), GiftController.send);

module.exports = route;
