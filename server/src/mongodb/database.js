const mongoose = require("mongoose");
const fs = require("fs");

async function connectToMongo(db_host = "", db_port = "", db_username = "", db_password = "", db_name = "") {
    let connectionString = ""
    let printConnectionString = ""
    if (!db_username || !db_password) {
        connectionString = `mongodb://${db_host}:${db_port}/${db_name}?authSource=admin`;
        printConnectionString = `mongodb://${db_host}:${db_port}/${db_name}?authSource=admin`;
    } else {
        connectionString = `mongodb://${db_username}:${db_password}@${db_host}:${db_port}/${db_name}?authSource=admin`;
        printConnectionString = `mongodb://${db_username}:********@${db_host}:${db_port}/${db_name}?authSource=admin`;
    }
    console.log(connectionString);
    console.log(`Trying to connect to mongoDB ${printConnectionString} ...`);
    let connection = await mongoose.createConnection(connectionString).asPromise();
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
    let fileNames = fs.readdirSync("./src/mongodb/data");

    for (const fileName of fileNames) {
        let name = fileName.split(".")[0];
        let fileContent = JSON.parse(fs.readFileSync(`./src/mongodb/data/${name}.json`, "utf8"));
        console.log(`reading file: ${name}`);
        let collection = dynamicModel(name);
        let count = await collection.count();
        if (count === 0) {
            for (const obj of fileContent) {
                let res = await collection.findOneAndUpdate(filter=obj, update=obj, options={upsert: true, returnDocument: 'after'});
            }
        }
    }
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
