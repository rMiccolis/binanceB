const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const date = require("./utils/date");
const db = require("../mongodb/database");

let test = async (user = "test", url = "https://testnet.binance.vision/", tradeQuantity = 30, couple = "BTCUSDT") => {
  let plans = db.dynamicModel("plans");
  let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  let buyQty = 100;
  const binance = new Spot(apiKey, apiSecret, { baseURL: url });

  let plansDb = db.dynamicModel("plans");
  let plan = plansDb.aggregate([{ $match: { user: user } }]);

  let wallet = await walletInfo.getAccountData(spotClient);
  let freeUsdt = 0;
  for (const balance of walletInfo.balances) {
    if (balance.asset == "USDT") freeUsdt = balance.free;
  }

  if (buyQty >= freeUsdt) {
    // if 
    //place order:

  }
  // let {recallsNumber, sellPositive, recallsBuy, recallsQuantity} = plan;

  // let coupleTrades = await trades.getOpenOrders(binance, couple);
  // console.log(coupleTrades);
  return plan;
};
// Save data to db
// plan = new plans(plan);
// let res = await plan.save()

// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))

module.exports = test;
