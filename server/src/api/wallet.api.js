var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const walletInfo = require("../wallet/walletInfo");
const earn = require("../wallet/earn");
const auth = require("../middleware/auth.middleware");

router.use(auth.checkJWT);
router.get("/", async (req, res, next) => {
    try {
        const spotClient = global.users[req.locals.userId].binanceSpotConnection;

        let data = await walletInfo.getAccountData(spotClient);
        data.balances = data.balances.filter((el) => parseFloat(el.free) > 0);
        res.json(data);
    } catch (error) {
        console.logError(error.data || error.message);
        console.log(error);
        res.status(400).send(error);
    }
});

router.get("/staking", async (req, res, next) => {
    const spotClient = global.users[req.locals.userId].binanceSpotConnection;
    let data = await earn.getBlockedStaking(spotClient);
    res.json(data);
});

/* GET account data. */

module.exports = router;
