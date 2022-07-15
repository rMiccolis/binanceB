const mongoose = require("mongoose");

async function connectToMongo(connectionString, user) {
  console.log("Trying to connect to mongoDB...");
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

function dynamicModel(connection, collectionName, schema = null) {
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
};
