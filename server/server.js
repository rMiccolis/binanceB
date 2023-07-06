const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
var cors = require("cors");
const dotenv = require("dotenv");
const helmet = require("helmet");
const testApi = require("./api/test");
const walletApi = require("./api/wallet.api");
const db = require("./mongodb/database");
const exitHandler = require("./handlers/exit.handler");
const authApi = require("./api/auth.api");
const logHandler = require("./handlers/log.handler");
const utilsApi = require("./api/utils.api");
const generalRouter = require("./api/general.api");

// Initialize global session variable
global.globalDBConnection = {};
global.users = {};

dotenv.config();
const app = express();

//insert logging functions
console.logDebug = logHandler.logDebug;
console.logWarning = logHandler.logWarning;
console.logError = logHandler.logError;
console.logInfo = logHandler.logInfo;

const corsOptions = { origin: true, credentials: true };

//middlewares
app.use(cors(corsOptions));
app.use(logger("dev"));
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use((req, res, next) => {
    req.locals = {};
    console.log(req.headers['x-forwarded-for']);
    next();
});

//routes
app.use("/", generalRouter);

app.use("/auth", authApi);
app.use("/api/utils", utilsApi);
app.use("/test", testApi);
app.use("/api/wallet", walletApi);

// process.stdin.resume(); //so the program will not close instantly

// //do something when app is closing
// process.on("exit", exitHandler);

// //catches ctrl+c event
// process.on("SIGINT", exitHandler);

// // catches "kill pid" (for example: nodemon restart)
// process.on("SIGUSR1", exitHandler);
// process.on("SIGUSR2", exitHandler);

// //catches uncaught exceptions
// process.on("uncaughtException", exitHandler);

let port = process.env.SERVER_PORT | 3000;
app.listen(port, () => {
    console.log(`Listening on port ${port}`);
    if (process.env.NODE_ENV== 'production') console.log("list of ENV variables:\n", process.env);
});

db.connectToMongo(process.env.MONGODB_URI, process.env.MONGODB_PORT, process.env.MONGODB_USERNAME, process.env.MONGODB_PASSWORD, process.env.MONGODB_DB_NAME, "app")
    .then(async (connection) => {
        global.globalDBConnection = connection;
        if (process.env.NODE_ENV === "develop") {
            //mongodb Initialize data
            await db.loadDefaultData();
        }
    })
    .catch((error) => {
        console.logError(error.message);
        console.logError("unable to connect to db!");
        process.exit(1);
    });

// app.addListener();
