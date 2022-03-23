var express = require('express');
var router = express.Router();
const test = require('../src/test')
const realTest = require('../src/realTest')

/* GET home page. */
router.get('/test', function(req, res, next) {
  test.test()
  res.send("ciao");
});

router.get('/realTest', async (req, res, next) => {
  let data = await realTest.test()
  // console.log(data);
  res.json(data);
});

module.exports = router;
