const db = require("../mongodb/database");
const jwt = require("jsonwebtoken");
const sessionHandler = require("../handlers/session.handler");

let checkJWT = async (req, res, next) => {
    const access_token = req.cookies?.access_token;
    if (access_token) {
        try {
            //controlla se access_token valido e non scaduto
            let decoded = jwt.verify(access_token, process.env.ACCESS_TOKEN_SECRET);
            req.locals["userId"] = decoded.userId;
            let userId = req.locals.userId;
            if (!(userId in global.users)) {
                console.logDebug(`Setting Binance connection for user: ${userId}`);
                await sessionHandler.setBinanceConnection(userId);
            }
            next();
        } catch (error) {
            console.logError(error);
            await sessionHandler.revokeTokens(req, res)
            res.status(403).json({ error: true, code: "INVALID_TOKEN" });
        }
    } else {
        //manca access_token
        console.logError("checkJWT MISSING_TOKEN");
        await sessionHandler.revokeTokens(req, res)
        res.status(403).json({ error: true, code: "MISSING_TOKEN" });
    }
};

module.exports = {
    checkJWT,
};
