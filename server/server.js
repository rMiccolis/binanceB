const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
const cors = require("cors");
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
const os = require("os");
const k8s = require('@kubernetes/client-node');
const {v4 : uuidv4} = require('uuid')
const { createJob } = require("./kubernetes/job")


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
    console.logDebug("Server hostname:", os.hostname());
    console.logDebug("Client IP address:", req.headers['x-forwarded-for']);
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
    if (process.env.NODE_ENV != 'production') console.log("list of ENV variables:\n", process.env);
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

const startJobK8s = async () => {
    try {

        const namespace = 'binance-b';

        let job_uuid = uuidv4().split('-').slice(3).join('-')
        let hostname = process.env.HOSTNAME.split('-').slice(2).join('-')
        const jobName = `bot-${hostname}-${job_uuid}`;

        // // create spec.template.spec.containers.env.valueFrom.configMapKeyRef
        // const configMapKeyRef = new k8s.V1ConfigMapKeySelector()
        // configMapKeyRef.name = 'server-configmap'
        // configMapKeyRef.key = 'JOB_IMAGE_NAME'

        // // create spec.template.spec.containers.env.valueFrom
        // const valueFrom = new k8s.V1EnvVarSource()
        // valueFrom.configMapKeyRef = configMapKeyRef

        // // create spec.template.spec.containers.env
        // const env = new k8s.V1EnvVar()
        // env.name = 'JOB_IMAGE_NAME'
        // env.valueFrom = valueFrom

        // // create spec.template.spec.containers.pod
        // const pod_spec_container = new k8s.V1Container()
        // pod_spec_container.name = 'bot'
        // pod_spec_container.image = process.env.JOB_IMAGE_NAME
        // pod_spec_container.env = [env]
        // pod_spec_container.command = ["node", "./src/engine/botActivity.js"]

        // // create spec.template.containers
        // const template_spec = new k8s.V1PodSpec()
        // template_spec.containers = [pod_spec_container]
        // template_spec.restartPolicy = "Never"

        // // create job.spec.template
        // const job_spec_template_spec = new k8s.V1PodTemplateSpec()
        // job_spec_template_spec.spec = template_spec

        // // create job.spec
        // const job_spec = new k8s.V1JobSpec();
        // job_spec.ttlSecondsAfterFinished = 180
        // job_spec.parallelism = 2
        // job_spec.backoffLimit = 4
        // job_spec.template = job_spec_template_spec

        // // create job.metadata
        // const metadata = new k8s.V1ObjectMeta();
        // metadata.name = jobName;
        // metadata.namespace = "binance-b"

        // // create job
        // const job = new k8s.V1Job();
        // job.apiVersion = 'batch/v1';
        // job.kind = 'Job';
        // job.metadata = metadata;
        // job.spec = job_spec

        // api call to kubernetes to create job
        const kc = new k8s.KubeConfig();
        kc.loadFromCluster();
        const batchV1Api = kc.makeApiClient(k8s.BatchV1Api);
        let containers = [
            {
                name: 'bot',
                imageName: 'process.env.JOB_IMAGE_NAME',
                env: {
                    configMaps: [{envName: 'JOB_IMAGE_NAME', configMapName: 'server-configmap', configMapKey: 'JOB_IMAGE_NAME'}],
                },
                command: ["node", "./src/engine/botActivity.js"]
            }
        ]
        const job = createJob(jobName, namespace, containers, "Never", 180, 2, 4)
        const createJobRes = await batchV1Api.createNamespacedJob(namespace, job);

        console.log(createJobRes.body);
    } catch (err) {
        console.error(err);
    }
};

startJobK8s();

// app.addListener();
