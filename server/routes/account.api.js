var express = require("express");
var router = express.Router();
const walletInfo = require("./wallet/walletInfo");
const db = require("../src/utils/mongodb");
/* GET account data. */
router.get("/", async (req, res, next) => {
    let userId = req.params.userId;
    let dbUser = await db.aggregate("users", [{ $match: { id: userId } }]);
    if (dbUser.length < 1) {
        return { err: "no APY_KEY found!" };
    }
    if (userId != 'test') {
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    }
    dbUser = dbUser[0];
    let apiKey = dbUser.APY_KEY;
    let apiSecret = dbUser.SECRET_KEY;
    let buyQty = 100;
    // const spotClient = await new Spot(apiKey, apiSecret)
    const spotClient = new Spot(apiKey, apiSecret, { baseURL: process.env.testNetBaseUrl });
    return await walletInfo.getAccountData(spotClient);
});

module.exports = router;
