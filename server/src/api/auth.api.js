const express = require("express");
const router = express.Router();
const db = require("../mongodb/database");
const testStrategy = require("../test");
const sessionHandler = require("../handlers/session.handler");



/* PREFIX: /auth */
router.post("/signin", sessionHandler.signin)

router.post("/signup", sessionHandler.signup)

router.get("/refresh",  sessionHandler.refresh)

router.get("/isLoggedIn",  sessionHandler.isLoggedIn)

router.get("/logout",  sessionHandler.logout)

module.exports = router;
