const db = require("../mongodb/database");
const jwt = require("jsonwebtoken");
const sessionHandler = require("../handlers/session.handler");

let checkJWT = async (req, res, next) => {
    const jwt_token = req.cookies?.access_token;
    if (jwt_token) {
        try {
            //controlla se jwt_token valido e non scaduto
            let decoded = await jwt.verify(jwt_token, process.env.ACCESS_TOKEN_SECRET);
            req.locals["userId"] = decoded.userId;
            let userId = req.locals.userId;
            if (!userId in global.binanceConnections) {
                await sessionHandler.setBinanceConnection(userId);
            }
            next();
        } catch (error) {
            console.log(error);
            res.status(403).json({ code: "INVALID_TOKEN" });
        }
    } else {
        //manca jwt_token o refresh_token
        res.status(403).json({ code: "MISSING_TOKEN" });
    }
};

module.exports = {
    checkJWT,
};
