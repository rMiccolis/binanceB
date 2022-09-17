var express = require("express");
var router = express.Router();
const db = require("../mongodb/database");
const testStrategy = require("../src/test");
const sessionHandler = require("../handlers/session.handler");



/* PREFIX: /auth */
router.post("/signin", sessionHandler.signin)

router.post("/signup", sessionHandler.signup)

router.get("/refresh",  sessionHandler.refresh)

router.get("/isLoggedIn",  sessionHandler.isLoggedIn)

router.get("/logout",  sessionHandler.logout)

module.exports = router;
