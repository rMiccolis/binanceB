var express = require('express');
var router = express.Router();
const test = require('../src/test')
const { aggregate, insertOne, updateOne } = require('../src/utils/mongodb')

/* GET home page. */
router.get('/', async (req, res, next) => {
  res.send("<div>Benvenuto sul bot di binance vai su:<br>- <a href='http://localhost:3000/test'>test generale</a> per un semplice test<br>- <a href='http://localhost:3000/testticker'>test ticker</a></div>");
});

router.get('/test', async (req, res, next) => {
  let data = await test.test();
  res.json(data);
});

router.get('/testticker', async (req, res, next) => {
  let data = await test.testTicker();
  res.json(data);
});

router.get('/getusers', async (req, res, next) => {
  let data = await aggregate('users')
  res.json(data);
});

router.get('/insertOne', async (req, res, next) => {
  let data = await insertOne('users', {id: 'ProvaAdmin', psw: 'ciao'})
  res.json(data);
});

router.get('/mongo', async (req, res, next) => {
TEST_SECRET_KEY='1k6vBgvBZkTBN7Q0dz369uvemrEDdmzxC8UpkGKDUi7wg16gvOntZGWwshKuHcaM'
  let data = await updateOne('users', {id: 'ProvaAdmin'}, {id: 'test', psw: 'test'})
  res.json(data);
});


module.exports = router;
