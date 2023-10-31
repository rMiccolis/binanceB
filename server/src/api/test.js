var express = require('express');
var router = express.Router();
const db = require('../mongodb/database');
const testStrategy = require('../test');
const testws = require('../testws');

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

router.route("/test").post(async function (req, res) {
  try {
      res.json({
          test: "passed!",
          params: req.params,
          query: req.query,
          body: req.body})
  } catch (error) {
      res.json({ test: "not passed :("});
  }
});

module.exports = router;
