var express = require('express');
var router = express.Router();
const test = require('../src/test')

/* GET home page. */
router.get('/', async (req, res) => {
  res.send("<div>Benvenuto sul bot di binance vai su:<br>- <a href='http://localhost:3000/test'>test generale</a> per un semplice test<br>- <a href='http://localhost:3000/testticker'>test ticker</a></div>");
});

router.get('/test', async (req, res) => {
  let data = await test.test(req.locals.user, req.locals.url);
  res.json(data);
});

router.get('/testticker', async (req, res) => {
  let data = await test.testTicker();
  res.json(data);
});

router.get('/getusers', async (req, res) => {
  let data = await global.db.aggregate('users')
  res.json(data);
});

router.get('/insertOne', async (req, res) => {
  let data = await global.db.insertOne('users', {id: 'ProvaAdmin', psw: 'ciao'})
  res.json(data);
});

router.get('/mongo', async (req, res) => {
TEST_SECRET_KEY='1k6vBgvBZkTBN7Q0dz369uvemrEDdmzxC8UpkGKDUi7wg16gvOntZGWwshKuHcaM'
  let data = await global.db.updateOne('users', {id: 'ProvaAdmin'}, {id: 'test', psw: 'test'})
  res.json(data);
});


module.exports = router;
