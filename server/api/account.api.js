var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const walletInfo = require("../src/wallet/walletInfo");


/* GET account data. */
router.get("/", async (req, res, next) => {
    let user = req.locals.user;
    let apiKey = user.APY_KEY;
    let apiSecret = user.SECRET_KEY;
    // const spotClient = new Spot(apiKey, apiSecret, { baseURL: req.locals.url });
    const spotClient = new Spot(apiKey, apiSecret);
    let data = await walletInfo.getAccountData(spotClient);
    // console.log(data);
    data.balances = data.balances.filter(el => parseFloat(el.free) > 0)
    res.json(data)
});

module.exports = router;
