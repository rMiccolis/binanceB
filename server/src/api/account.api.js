var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const walletInfo = require("../src/wallet/walletInfo");

/* GET account data. */
router.get("/", async (req, res, next) => {
  try {    
    const spotClient = global.binanceConnections[req.locals.userId];

    let data = await walletInfo.getAccountData(spotClient);
    data.balances = data.balances.filter((el) => parseFloat(el.free) > 0);
    res.json(data);
  } catch (error) {
    console.logError(error.data || error.message);
    res.status(400).send(error);
  }
});

module.exports = router;
