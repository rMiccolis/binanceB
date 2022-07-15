let accountCheck = async (req, res, next) => {
    let userId = req.query.userId;
    req.locals = {}
    if (!userId) {
        return res.json({ err: "no APY_KEY found!" });
    }
    let dbUser = await global.db.aggregate("users", [{ $match: { id: userId } }]);
    console.log(dbUser);
    if (dbUser.length < 1) {
        console.log("no APY_KEY found!");
        return res.json({ err: "no APY_KEY found!" });
    }
    if (userId != 'test') {
        req.locals.url = process.env.BINANCE_BASE_URL
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    } else {
        req.locals.url = process.env.TESTNET_BASE_URL
    }
    req.locals.user = dbUser[0]
    next()
}

module.exports = {
    accountCheck
}