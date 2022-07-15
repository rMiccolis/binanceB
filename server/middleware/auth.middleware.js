const db = require('../mongodb/database');

let accountCheck = async (req, res, next) => {
    let userId = req.query.userId;
    let users = db.dynamicModel('users');
    req.locals = {}
    if (!userId) {
        return res.json({ err: "no APY_KEY found!" });
    }

    let dbUser = await users.aggregate([{ $match: { id: userId } }]);
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