var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const earn = require("../src/wallet/earn");


/* GET account data. */
router.get("/staking", async (req, res, next) => {
    const spotClient = global.binanceConnections[req.locals.userId]
    let data = await earn.getBlockedStaking(spotClient);
    res.json(data);
});

module.exports = router;
