var express = require("express");
var router = express.Router();
const db = require("../mongodb/database");
const testStrategy = require("../src/test");
const crypto = require('node:crypto');
/* PREFIX: /auth */

router.post("/signin", async (req, res) => {
  let { userId, password } = req.body;
  let users = db.dynamicModel("users");

  let userFound = await users.aggregate([{$match: {userId: userId}}]);
  if (userFound.length != 1) return res.json({error: true, message: "User not found!"})

  userFound = userFound[0]

  let hash = crypto.pbkdf2Sync(password,  
  userFound.salt, 1000, 64, `sha512`).toString(`hex`); 
  
  if (userFound.password === hash) {
    return res.json({error: false, message: "Successfully logged in!"})
  }
  return res.json({error: true, message: "Wrong password!"})

});

router.post("/signup", async (req, res) => {
  let { userId, password } = req.body;
  console.log(userId, password);
  if (!userId || !password) return res.json({err: true, message: "no data received"})
  let users = db.dynamicModel("users");

  let userFound = await users.aggregate([{$match: {userId: userId}}]);
  if (userFound.length > 0) return res.json({error: "UserId already exists!"})

  // Creating a unique salt for a particular user 
  let salt = crypto.randomBytes(16).toString('hex'); 
  
  // Hashing user's salt and password with 1000 iterations, 
  let hash = crypto.pbkdf2Sync(password, salt,  
  1000, 64, `sha512`).toString(`hex`); 

  let newUser = new users({userId, password: hash, salt})
  newUser.save()
  
  return res.json({err: null, message: "Account created successfully"})

});

module.exports = router;
