var express = require("express");
var router = express.Router();
const db = require("../mongodb/database");
const testStrategy = require("../src/test");
const sessionHandler = require("../handlers/session.handler");



/* PREFIX: /auth */
router.post("/signin", sessionHandler.signin)

router.post("/signup", sessionHandler.signup)

router.post("/refresh",  sessionHandler.refresh)

module.exports = router;
