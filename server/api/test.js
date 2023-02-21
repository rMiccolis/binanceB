var express = require('express');
var router = express.Router();
const db = require('../mongodb/database');
const testStrategy = require('../src/test');
const testws = require('../src/testws');

/* PREFIX: /test */
router.get('/', async (req, res) => {
  res.send("<div>Benvenuto sul bot di binance vai su:<br>- <a href='http://localhost:3000/test'>test generale</a> per un semplice test<br>- <a href='http://localhost:3000/testticker'>test ticker</a></div>");
});

router.get('/startBotTest', async (req, res) => {
  let user = req.locals.user;
  let data = await testStrategy.startBotTest(user);
  res.json(data);
});

router.get('/testws', async (req, res) => {
  let connections = global.users['aa'];
  let data = await testws.testws(connections);
  res.json(data);
});

module.exports = router;