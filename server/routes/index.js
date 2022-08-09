var express = require('express');
var router = express.Router();
const db = require('../mongodb/database');
const testNode = require('../src/test-node');
const testStrategy = require('../src/test');

/* PREFIX: /test */
router.get('/', async (req, res) => {
  res.send("<div>Benvenuto sul bot di binance vai su:<br>- <a href='http://localhost:3000/test'>test generale</a> per un semplice test<br>- <a href='http://localhost:3000/testticker'>test ticker</a></div>");
});

router.get('/test', async (req, res) => {
  let user = req.locals.user;
  let data = await testNode(user.id);
  res.json(data);
});

router.get('/testStrategy', async (req, res) => {
  let user = req.locals.user;
  let data = await testStrategy.test(user);
  res.json(data);
});

router.get('/testticker', async (req, res) => {
  let data = await test.testTicker();
  res.json(data);
});

module.exports = router;
