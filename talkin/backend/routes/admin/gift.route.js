const express = require("express");
const route = express.Router();

const multer = require("multer");
const storage = require("../../util/multer");
const upload = multer({ storage });

const checkAccessWithSecretKey = require("../../util/checkAccess");
const GiftController = require("../../controllers/admin/gift.controller");

route.get("/", checkAccessWithSecretKey(), GiftController.get);
route.patch("/settings", checkAccessWithSecretKey(), GiftController.updateSettings);
route.post("/", checkAccessWithSecretKey(), upload.single("image"), GiftController.add);
route.patch("/toggle", checkAccessWithSecretKey(), GiftController.toggle);
route.patch("/reorder", checkAccessWithSecretKey(), GiftController.reorder);
route.patch("/", checkAccessWithSecretKey(), upload.single("image"), GiftController.edit);
route.delete("/", checkAccessWithSecretKey(), GiftController.remove);

module.exports = route;
