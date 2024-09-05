const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
const cors = require("cors");
const dotenv = require("dotenv");
const helmet = require("helmet");
const testApi = require("./src/api/test");
const walletApi = require("./src/api/wallet.api");
const db = require("./src/mongodb/database");
const exitHandler = require("./src/handlers/exit.handler");
const authApi = require("./src/api/auth.api");
const logHandler = require("./src/handlers/log.handler");
const utilsApi = require("./src/api/utils.api");
const generalRouter = require("./src/api/general.api");
const os = require("os");
const k8s = require('@kubernetes/client-node');
const {v4 : uuidv4} = require('uuid')
const { createJob } = require("./src/kubernetes/job")


// Initialize global session variable
global.globalDBConnection = {};
global.users = {};

dotenv.config();
const app = express();

//insert logging functions
console.logDebug = logHandler.logDebug;
console.logWarning = logHandler.logWarning;
console.logError = logHandler.logError;
console.logSuccess = logHandler.logSuccess;

// const corsOptions = { origin: ['http://10.11.1.1', 'http://bob617.ddns.net/', 'https://bob617.ddns.net/', 'http://bob617.ddns.net', 'https://bob617.ddns.net', 'http://localhost:8080/', 'http://localhost:8080'], credentials: true };
// const corsOptions = { origin: true, credentials: true, origin: "*" };
const corsOptions = { origin: true, credentials: true};

//middlewares
app.use(logger("dev"));
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use((req, res, next) => {
    req.locals = {};
    console.logDebug("Server hostname:", os.hostname());
    console.logDebug("Client IP address:", req.headers['x-forwarded-for']);
    next();
});

//routes
app.use(cors(corsOptions));
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
    // if (process.env.NODE_ENV != 'production') console.log("list of ENV variables:\n", process.env);
});

db.connectToMongo(process.env.MONGODB_URI, process.env.MONGODB_PORT, process.env.MONGODB_USERNAME, process.env.MONGODB_PASSWORD, process.env.MONGODB_DB_NAME)
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

/**
 * This is a test function to create a namespaced job that simply lists all pods in the same namespace (./src/engine/botActivity.js) with parallelism 2
 *
 */
const startJobK8s = async () => {
    try {

        const namespace = 'binance-b';

        // create job name
        let job_uuid = uuidv4().split('-').slice(3).join('-')
        let hostname = process.env.HOSTNAME.split('-').slice(2).join('-')
        const jobName = `bot-${hostname}-${job_uuid}`;

        // init k8s object configuration
        const kc = new k8s.KubeConfig();

        // loadFromCluster to load configuration when the process launching 'kc.loadFromCluster();' is inside the cluster (from a pod like in this case)
        kc.loadFromCluster();

        // create BatchV1Api object
        const batchV1Api = kc.makeApiClient(k8s.BatchV1Api);

        // create containers list
        let containers = [
            {
                name: 'bot',
                imageName: process.env.JOB_IMAGE_NAME,
                env: {
                    configMaps: [{envName: 'JOB_IMAGE_NAME', configMapName: 'server-configmap', configMapKey: 'JOB_IMAGE_NAME'}],
                },
                command: ["node", "./src/engine/botActivity.js"]
            }
        ]

        // create the job object
        const job = createJob(jobName, namespace, containers, "Never", 180, 2, 4)
        
        // api call to kubernetes to create job
        const createJobRes = await batchV1Api.createNamespacedJob(namespace, job);

        console.log(createJobRes.body);
    } catch (err) {
        console.error(err.body || err);
    }
};

// startJobK8s();

// app.addListener();
