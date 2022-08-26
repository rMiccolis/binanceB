const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
var cors = require("cors");
const dotenv = require("dotenv");
const helmet = require("helmet");
const auth = require("./middleware/auth.middleware");
const indexRouter = require("./routes/index");
const accountApiRouter = require("./api/account.api");
const earnApiRouter = require("./api/earn.api");
const db = require("./mongodb/database");
const exitHandler = require("./handlers/exit.handler");
const authRouter = require("./routes/auth.router");

dotenv.config();
const app = express();

// Initialize global session variable
global.usersDBConnections = {};
global.db = {};
global.binanceConnections = {}

const corsOptions = { origin: true, credentials: true };

//middlewares
app.use(cors(corsOptions));
app.use(logger("dev"));
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

const generalRouter = express.Router();
generalRouter.route("/").get(async function (req, res) {
  try {
    if (global.db.readyState === 1) res.json({ health: "OK", message: "App is running!" });
  } catch (error) {
    res.json({ health: "KO", message: "App running but something goes wrong!" })
  }
});

generalRouter.route("/healthCheck").get(async function (req, res) {
  try {
    if (global.db.readyState === 1){
      let healthCheck = db.dynamicModel('healthCheck');
      let healt = await healthCheck.aggregate([{$match: {}}])
      res.json({ health: "OK", message: "DB is correctly running!", healthCheck: healt });
    } 
      
  } catch (error) {
    res.json({ health: "KO", message: "DB is is not running!" })
  }
});


app.use((req, res, next) => {
  req.locals = {}
  next()
});

//routes
app.use("/", generalRouter);
app.use("/auth", authRouter)

app.use(auth.checkJWT);
app.use("/test", indexRouter);
app.use("/api/account", accountApiRouter);
app.use("/api/earn", earnApiRouter);

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

let port = 3000;
app.listen(port, () => {
  console.log(`Listening on port ${port}`);
  console.log("try it out on", "http://localhost:3000");
});

db.connectToMongo(process.env.MONGODB_URI, "app").then((connection) => {
  global.db = connection;
});

// app.addListener();
