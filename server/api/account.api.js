var express = require("express");
var router = express.Router();
const { Spot } = require("@binance/connector");
const walletInfo = require("../src/wallet/walletInfo");

/* GET account data. */
router.get("/", async (req, res, next) => {
  try {
    let user = req.locals.user;
    let apiKey = user.APY_KEY;
    let apiSecret = user.SECRET_KEY;
    const spotClient = new Spot(apiKey, apiSecret, { baseURL: req.locals.url });
    let data = await walletInfo.getAccountData(spotClient);
    // console.log(data);
    data.balances = data.balances.filter((el) => parseFloat(el.free) > 0);
    res.json(data);
  } catch (error) {
    res.status(400).send(error);
  }
});

module.exports = router;
