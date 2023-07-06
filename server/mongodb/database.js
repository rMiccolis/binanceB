const mongoose = require("mongoose");
const fs = require("fs");

async function connectToMongo(db_host="", db_port="", db_username = "", db_password = "", db_name = "") {
    let connectionString = `mongodb://${db_username}:${db_password}@${db_host}:${db_port}`
    console.log(`Trying to connect to mongoDB ${connectionString}...`);
    let connection = await mongoose.createConnection(connectionString).asPromise();
    connection.useDb(process.env.MONGODB_DB_NAME)
    connection.addListener("disconnected", function () {
        console.log("Unable to connect to mongoDB! Retrying in 5 seconds...");
        setTimeout(() => {
            connectToMongo();
        }, 5000);
    });

    connection.addListener("close", function () {
        console.log("MongoDB connection closed!");
    });
    console.log("Database connected " + connection.name + "!");
    return connection;
}

async function loadDefaultData(params) {
    let fileNames = fs.readdirSync("./mongodb/data");
    let process = dynamicModel("process");
    db_already_seeded = await process.aggregate([{ $match: { name: "database_seed" } }]);
    if (db_already_seeded.length > 0) return
    for (const fileName of fileNames) {
        let name = fileName.split(".")[0];
        let fileContent = JSON.parse(fs.readFileSync(`./mongodb/data/${name}.json`, "utf8"));
        console.log(`reading file: ${name}`);
        let collection = dynamicModel(name);
        let count = await collection.count();
        if (count === 0) {
            for (const obj of fileContent) {
                if (obj['_id']?.["$oid"]) {
                    let id = obj["_id"]["$oid"];
                    obj["_id"] = mongoose.Types.ObjectId(id);
                }
            }
            collection.insertMany(fileContent, function (error, docs) {
                if (error) console.log(error);
                else console.log(`${docs.length} documents inserted into`, name);
            });
        }
    }
    let seed_process = new process({ name: "database_seed", status: 1 });
    await seed_process.save();
}

function dynamicSchema(connection, collectionName, schema) {
    if (connection.models[collectionName]) {
        return connection.models[collectionName];
    }
    let collectionSchema;
    if (schema) {
        collectionSchema = schema;
    } else {
        collectionSchema = new mongoose.Schema({ any: {} }, { collection: collectionName, versionKey: false, strict: false });
    }

    return connection.model(collectionName, collectionSchema);
}

function dynamicModel(collectionName, connection = global.globalDBConnection, schema = null) {
    let model = null;
    try {
        model = dynamicSchema(connection, collectionName, schema);
    } catch (error) {
        console.log(error.message);
    }
    return model;
}

module.exports = {
    connectToMongo,
    dynamicModel,
    loadDefaultData,
};
