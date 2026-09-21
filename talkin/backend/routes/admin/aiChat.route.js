//express
const express = require("express");
const route = express.Router();

//checkAccessWithSecretKey
const checkAccessWithSecretKey = require("../../util/checkAccess");

//controller
const AiChatController = require("../../controllers/admin/aiChat.controller");

//global AI chat configuration (providers, language, behaviour, safety)
route.get("/config", checkAccessWithSecretKey(), AiChatController.getConfig);
route.patch("/config", checkAccessWithSecretKey(), AiChatController.updateConfig);

//verify a provider key/model
route.post("/testProvider", checkAccessWithSecretKey(), AiChatController.testProvider);

//try a persona without touching real chats
route.post("/playground", checkAccessWithSecretKey(), AiChatController.playground);

//usage counters, provider health and recent replies
route.get("/usage", checkAccessWithSecretKey(), AiChatController.usage);

//per fake-host persona
route.get("/listenerProfile", checkAccessWithSecretKey(), AiChatController.getListenerProfile);
route.patch("/listenerProfile", checkAccessWithSecretKey(), AiChatController.updateListenerProfile);
route.post("/assignLanguage", checkAccessWithSecretKey(), AiChatController.assignLanguage);

module.exports = route;
