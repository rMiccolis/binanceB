var express = require('express');
var router = express.Router();
const test = require('../src/test')

/* GET home page. */
router.get('/', function(req, res, next) {
  test.test()
  res.send("ciao");
});

module.exports = router;
