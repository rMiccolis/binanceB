const express = require("express");
const db = require("../mongodb/database");
const generalRouter = express.Router();

generalRouter.route("/").get(async function (req, res) {
    try {
        if (global.globalDBConnection.readyState === 1) res.json({ health: "OK", message: "App is running!" });
        else res.json({ health: "KO", message: "App running but something goes wrong!" });
    } catch (error) {
        res.json({ health: "KO", message: "App running but something goes wrong!" });
    }
});

generalRouter.route("/healthCheck").get(async function (req, res) {
    try {
        if (global.globalDBConnection.readyState === 1) {
            let healthCheck = db.dynamicModel("healthCheck");
            let healt = await healthCheck.aggregate([{ $match: {} }]);
            res.json({ health: "OK", message: "DB is correctly running!", healthCheck: healt });
        }
    } catch (error) {
        res.json({ health: "KO", message: "DB is is not running!", error: error.message });
    }
});

module.exports = generalRouter;