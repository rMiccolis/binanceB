var express = require('express');
var router = express.Router();
const test = require('../src/test')
const realTest = require('../src/realTest')

/* GET home page. */
router.get('/test', async (req, res, next) => {
  let data = await test.test()
  // console.log(data);
  res.json(data);
});

router.get('/realTest', async (req, res, next) => {
  let data = await realTest.test()
  // console.log(data);
  res.json(data);
});

module.exports = router;
