const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const AppearanceController = require("../../controllers/admin/appearance.controller");

// App look & feel: default theme, user choice, accent, motion, corners, effects
route.get("/", checkAccessWithSecretKey(), AppearanceController.getAppearance);
route.patch("/", checkAccessWithSecretKey(), AppearanceController.updateAppearance);

module.exports = route;
