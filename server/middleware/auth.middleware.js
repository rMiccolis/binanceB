const db = require("../src/utils/mongodb");

let accountCheck = async (req, res, next) => {
    let userId = req.params.userId;
    if (!userId) {
        return res.json({ err: "no APY_KEY found!" });
    }
    let dbUser = await db.aggregate("users", [{ $match: { id: userId } }]);
    if (dbUser.length < 1) {
        console.log("no APY_KEY found!");
        return res.json({ err: "no APY_KEY found!" });
    }
    if (userId != 'test') {
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    }
    req.params.user = dbUser[0]
    next()
}

module.exports = {
    accountCheck
}