const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateUserAuthToken = require("../../middleware/validateUserAuthToken.middleware");
const PremiumController = require("../../controllers/user/premium.controller");

route.get("/status", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.status);
route.post("/buy", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.buy);
route.post("/badge", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.badge);
route.get("/studio", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.studio);
route.post("/unlock", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.unlock);
route.post("/apply", validateUserAuthToken, checkAccessWithSecretKey(), PremiumController.apply);

module.exports = route;
