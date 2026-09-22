const express = require("express");
const route = express.Router();

const checkAccessWithSecretKey = require("../../util/checkAccess");
const validateAdminAuth = require("../../middleware/validateAdminAuth.middleware");
const DownloadController = require("../../controllers/admin/download.controller");

// Signed link: no bearer token (the browser navigates to it directly).
route.get("/get", DownloadController.signedFile);

route.get("/", checkAccessWithSecretKey(), validateAdminAuth, DownloadController.list);
route.get("/link", checkAccessWithSecretKey(), validateAdminAuth, DownloadController.link);
route.get("/file", checkAccessWithSecretKey(), validateAdminAuth, DownloadController.file);

module.exports = route;
