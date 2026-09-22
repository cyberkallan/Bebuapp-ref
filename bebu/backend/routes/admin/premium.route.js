const express = require("express");
const route = express.Router();

const multer = require("multer");
const storage = require("../../util/multer");
const upload = multer({ storage });

const checkAccessWithSecretKey = require("../../util/checkAccess");
const PremiumController = require("../../controllers/admin/premium.controller");

// bebu Pro: passes, features, Style Studio catalog, per-user grants
route.get("/", checkAccessWithSecretKey(), PremiumController.get);
route.patch("/settings", checkAccessWithSecretKey(), PremiumController.updateSettings);
route.post("/item", checkAccessWithSecretKey(), upload.single("image"), PremiumController.addItem);
route.patch("/item/toggle", checkAccessWithSecretKey(), PremiumController.toggleItem);
route.patch("/item", checkAccessWithSecretKey(), upload.single("image"), PremiumController.editItem);
route.delete("/item", checkAccessWithSecretKey(), PremiumController.deleteItem);
route.get("/user", checkAccessWithSecretKey(), PremiumController.userStatus);
route.post("/grant", checkAccessWithSecretKey(), PremiumController.grant);
route.post("/revoke", checkAccessWithSecretKey(), PremiumController.revoke);

module.exports = route;
