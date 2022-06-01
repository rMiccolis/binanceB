var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const earn = require("../src/wallet/earn");


/* GET account data. */
router.get("/blocked", async (req, res, next) => {
    let user = req.locals.user;
    if (user.id != 'test') {
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    }
    let apiKey = user.APY_KEY;
    let apiSecret = user.SECRET_KEY;
    // const spotClient = await new Spot(apiKey, apiSecret)
    const spotClient = new Spot(apiKey, apiSecret, { baseURL: req.locals.url });
    let data = await earn.getBlockedStaking(spotClient);
    res.json(data);
});

module.exports = router;
