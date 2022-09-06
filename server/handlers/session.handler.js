const db = require("../mongodb/database");
const { Spot } = require("@binance/connector");
const crypto = require("node:crypto");
const jwt = require("jsonwebtoken");

let revokeTokens = async (req, res, userId = null) => {
    if (userId) {
        let users = db.dynamicModel("users");
        await users.updateOne({ userId: userId }, { $set: { refresh_token: "", last_update: Date.now() } });
    }
    res.cookie("refresh_token", "", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", //https
        expires: new Date(0),
        sameSite: "Strict",
    });
    res.cookie("access_token", "", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", //https
        expires: new Date(0),
        sameSite: "Strict",
    });
};

let setTokens = async (tokenData, req, res) => {
    let currentTime = Date.now();
    const access_token_expiry = (process.env.ACCESS_TOKEN_LIFETIME * 60 * 1000);
    const refresh_token_expiry =(process.env.REFRESH_TOKEN_LIFETIME * 60 * 1000);
    //create json web token
    tokenData.iat = currentTime;
    // tokenData.exp = access_token_expiry
    const access_token = jwt.sign(tokenData, process.env.ACCESS_TOKEN_SECRET, {
        algorithm: "HS256",
        expiresIn: access_token_expiry
    });

    // tokenData.exp = refresh_token_expiry
    const refresh_token = jwt.sign(tokenData, process.env.REFRESH_TOKEN_SECRET, {
        algorithm: "HS256",
        expiresIn: refresh_token_expiry
    });

    let users = db.dynamicModel("users");
    await users.updateOne({ userId: tokenData.userId }, { $set: { refresh_token: refresh_token, last_update: Date.now() } });
    res.cookie("access_token", access_token, {
        maxAge: process.env.ACCESS_TOKEN_LIFETIME * 60 * 1000,
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", //https
        sameSite: "Strict",
        // domain: process.env.MINERVA_BASE_DOMAIN,
    });

    res.cookie("refresh_token", refresh_token, {
        maxAge: process.env.REFRESH_TOKEN_LIFETIME * 60 * 1000,
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", //https
        sameSite: "Strict",
        // domain: process.env.MINERVA_BASE_DOMAIN,
    });
    return { access_token_expiry: access_token_expiry };
};

async function setBinanceConnection(userId) {
    let users = db.dynamicModel("users");
    let user = (await users.aggregate([{ $match: { userId: userId } }]))[0];
    let baseUrl;
    if (userId != "Bob617") {
        baseUrl = process.env.TESTNET_BASE_URL;
    } else {
        baseUrl = process.env.BINANCE_BASE_URL;
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    }

    let apiKey = user.API_KEY;
    let apiSecret = user.API_SECRET;
    const spotClient = new Spot(apiKey, apiSecret, { baseURL: baseUrl });
    global.binanceConnections[userId] = spotClient;
}

let refresh = async (refresh_token, access_token, res) => {
    let users = db.dynamicModel("users");
    try {
        //controlla se access_token valido e non scaduto
        let oldAccess = jwt.verify(access_token, process.env.ACCESS_TOKEN_SECRET);
        let userId = oldAccess.userId;
        //controlla se access_token valido e non scaduto
        let oldRefresh = jwt.verify(refresh_token, process.env.REFRESH_TOKEN_SECRET);
        let user = await users.aggregate([{ $match: { userId: userId } }]);

        if (oldRefresh == user.refresh_token) {
            // create new access_token
            let tokenData = { userId: userId };
            const access_token_expiry = Date.now() + process.env.ACCESS_TOKEN_LIFETIME * 60 * 1000;
            access_token = jwt.sign(tokenData, process.env.ACCESS_TOKEN_SECRET, {
                algorithm: "HS256",
                expiresIn: process.env.ACCESS_TOKEN_LIFETIME + "m", //m = minutes
            });
            res.cookie("access_token", access_token, {
                maxAge: process.env.ACCESS_TOKEN_LIFETIME * 60 * 1000,
                httpOnly: true,
                secure: process.env.NODE_ENV === "production", //https
                sameSite: "Strict",
            });
            res.json({
                userId,
                access_token_expiry,
            });
        } else {
            throw new Error("invalid refresh_token!");
        }
    } catch (error) {
        await revokeTokens(req, res, userId);
        res.status(403).json({ code: "INVALID_TOKEN" });
    }
};

let signup = async (req, res) => {
    let { userId, password, publicApiKey, privateApiKey } = req.body;
    if (!userId || !password) return res.json({ err: true, message: "no data received" });
    let users = db.dynamicModel("users");

    let userFound = await users.aggregate([{ $match: { userId: userId } }]);
    if (userFound.length > 0) return res.json({ error: "UserId already exists!" });

    //create json web token
    let tokenData = { userId: userId };

    // Creating a unique salt for a particular user
    let salt = crypto.randomBytes(16).toString("hex");

    // Hashing user's salt and password with 1000 iterations,
    let hash = crypto.pbkdf2Sync(password, salt, 1000, 64, `sha512`).toString(`hex`);

    let newUser = new users({ userId, password: hash, salt, API_KEY: publicApiKey, API_SECRET: privateApiKey });
    await newUser.save();

    return res.json({ err: null, message: "Account created successfully" });
};

let signin = async (req, res) => {
    let { userId, password } = req.body;
    let users = db.dynamicModel("users");

    let userFound = await users.aggregate([{ $match: { userId: userId } }]);
    if (userFound.length != 1) return res.json({ error: true, message: "User not found!" });

    userFound = userFound[0];

    //create json web token
    let tokenData = { userId: userId };

    let hash = crypto.pbkdf2Sync(password, userFound.salt, 1000, 64, `sha512`).toString(`hex`);

    if (userFound.password === hash) {
        let access_token = await setTokens(tokenData, req, res);
        await setBinanceConnection(userId);
        return res.json({ error: false, message: "Successfully logged in!", userId: userId, access_token_expiry: access_token.access_token_expiry });
    }
    return res.json({ error: true, message: "Wrong password!" });
};

let isLoggedIn = async (req, res) => {
    const access_token = req.cookies?.access_token;
    if (access_token) {
        try {
            //controlla se access_token valido e non scaduto
            let decoded = jwt.verify(access_token, process.env.ACCESS_TOKEN_SECRET);
            res.json({isLoggedIn: true, message: "User is logged in!", sessionInfo: decoded });
        } catch (error) {
            console.logError(error);
            await revokeTokens(req, res);
            res.json({isLoggedIn: false, message: "User not logged in!" });
        }
    } else {
        //manca access_token
        await revokeTokens(req, res);
        res.json({isLoggedIn: false, message: "User not logged in!" });
    }
};

module.exports = {
    setBinanceConnection,
    refresh,
    signin,
    signup,
    setTokens,
    revokeTokens,
    isLoggedIn,
};
