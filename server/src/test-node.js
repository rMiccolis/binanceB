const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const trades = require("./wallet/trades");
const coinInfo = require("./coinInfo/info");
const date = require("./utils/date");
const db = require('../mongodb/database');
// const indicators = require("./indicators/indicators");

let test = async (user='test', url="https://testnet.binance.vision/", tradeQuantity=30, couple="BTCUSDT") => {
  let plans = db.dynamicModel('plans')
  let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  let buyQty = 100;
  const binance = new Spot(apiKey, apiSecret, { baseURL: url });

  let plan = {
    user,
    couple,
    tradeQuantity,
    recallsNumber: 27,
    sellPositive: 0.013,
    recallsBuy: [0.025, 0.005, 0.0075, 0.01, 0.012, 0.014, 0.016, 0.018, 0.02, 0.022, 0.024, 0.026, 0.028, 0.03, 0.035, 0.04, 0.05, 0.065, 0.075, 0.09, 0.11, 0.13, 0.15, 0.18, 0.21, 0.24, 0.27],
    recallsQuantity: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.4, 1.4, 2, 2],
  };

  plan = new plans(plan);
  let res = await plan.save()
  // console.log(res);

  // let {recallsNumber, sellPositive, recallsBuy, recallsQuantity} = plan;

  // let coupleTrades = await trades.getOpenOrders(binance, couple);
  // console.log(coupleTrades);

  //place first order
  // process.exit()
  console.log(process._getActiveHandles().length);
  return res;
  // console.log(, process._getActiveRequests());
};

// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))

module.exports = test
