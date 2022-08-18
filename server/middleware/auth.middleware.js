const db = require('../mongodb/database');

let accountCheck = async (req, res, next) => {
    let userId = req.query.userId;
    let users = db.dynamicModel('users');
    req.locals = {}
    if (!userId) {
        return res.json({ err: "no USER received!" });
    }

    let dbUser = await users.aggregate([{ $match: { userId: userId } }]);
    if (dbUser.length < 1) {
        console.log("User not found!");
        return res.json({ err: "User not found!" });
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