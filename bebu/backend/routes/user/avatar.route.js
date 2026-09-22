const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateUserAuthToken = require("../../middleware/validateUserAuthToken.middleware");
const AvatarController = require("../../controllers/user/avatar.controller");

// Avatar Studio: catalog + user's look, coin unlocks, equipping, presets
route.get("/studio", validateUserAuthToken, checkAccessWithSecretKey(), AvatarController.getStudio);
route.post("/unlock", validateUserAuthToken, checkAccessWithSecretKey(), AvatarController.unlockItem);
route.post("/equip", validateUserAuthToken, checkAccessWithSecretKey(), AvatarController.equip);
route.post("/preset", validateUserAuthToken, checkAccessWithSecretKey(), AvatarController.usePreset);

module.exports = route;
