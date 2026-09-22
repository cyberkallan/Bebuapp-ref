const express = require("express");
const route = express.Router();

const multer = require("multer");
const storage = require("../../util/multer");
const upload = multer({ storage });

const checkAccessWithSecretKey = require("../../util/checkAccess");
const AvatarStudioController = require("../../controllers/admin/avatarStudio.controller");

route.get("/", checkAccessWithSecretKey(), AvatarStudioController.getStudio);
route.patch("/settings", checkAccessWithSecretKey(), AvatarStudioController.updateSettings);
route.post("/item", checkAccessWithSecretKey(), upload.single("image"), AvatarStudioController.addItem);
route.patch("/item", checkAccessWithSecretKey(), upload.single("image"), AvatarStudioController.editItem);
route.patch("/item/toggle", checkAccessWithSecretKey(), AvatarStudioController.toggleItem);
route.delete("/item", checkAccessWithSecretKey(), AvatarStudioController.deleteItem);

module.exports = route;
