const mongodb = require('mongodb')
let client;

let getDatabaseInstance = async function (dbName) {
  const { MongoClient } = mongodb;
    const url = 'mongodb://localhost:27017/?readPreference=primary&appname=MongoDB%20Compass&directConnection=true&ssl=false';
    if (!client) {
      client = new MongoClient(url,
        {
          useNewUrlParser: true,
          useUnifiedTopology: true,
        });
      await client.connect();
    }
    const db = await client.db(dbName);
    return db;
}

let aggregate = async function (collection, query={}, dbName='binanceDB') {
  let db = await getDatabaseInstance(dbName);
  let coll = db.collection(collection);
  let curs = coll.aggregate(query);
  return await curs.toArray();
}

let insertOne = async function (collection, doc={}, dbName='binanceDB') {
  let db = await getDatabaseInstance(dbName);
  let coll = db.collection(collection);
  let result = await coll.insertOne(doc);
  return result;
}

let updateOne = async function (collection, filter=null, updateDocument=null, dbName='binanceDB') {
  if (filter == null || updateDocument == null) {
    return {data: "No data to update"}
  }
  let db = await getDatabaseInstance(dbName);
  let coll = db.collection(collection);
  let result = await coll.updateOne(filter, {$set: updateDocument});;
  return result;
}

module.exports = {
  aggregate,
  getDatabaseInstance,
  insertOne,
  updateOne
}
