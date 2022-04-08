var express = require('express');
var router = express.Router();
const test = require('../src/test')
const { aggregate, insertOne } = require('../src/mongodb')

/* GET home page. */
router.get('/', async (req, res, next) => {
  res.send("Benvenuto sul bot di binance vai su <a href='http://localhost:3000/test'>pagina test</a> per testare");
});

router.get('/test', async (req, res, next) => {
  let data = await test.test()
  res.json(data);
});

router.get('/getusers', async (req, res, next) => {
  let data = await aggregate('users')
  res.json(data);
});

router.get('/mongo', async (req, res, next) => {
  let data = await insertOne('users', {id: 'ProvaAdmin', psw: 'ciao'})
  res.json(data);
});



module.exports = router;
