const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const date = require("./utils/date");
const db = require("../mongodb/database");
const trades = require("./trades/trades");

let test = async (user = "test", url = "https://testnet.binance.vision/", tradeQuantity = 30, couple = "BNBUSDT") => {
  let plans = db.dynamicModel("plans");
  let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  let usdtInvest = 100; //USDT
  let targetPrice = 300;

  const binance = new Spot(apiKey, apiSecret, { baseURL: url });

  let coinInfo = await walletInfo.exchangeInfo(binance, 'BNBUSDT')
  let filtersInfo = coinInfo.symbols[0].filters;
  let decimalPlaces  = (filtersInfo.find( element => element.filterType == 'PRICE_FILTER')).tickSize.split('.')[1].split(1)[0].length + 1;
  let buyAmount = (usdtInvest / targetPrice).toFixed(decimalPlaces);
  console.log(buyAmount);

  let plansDb = db.dynamicModel("plans");
  let plan = plansDb.aggregate([{ $match: { user: user } }]);

  let wallet = await walletInfo.getAccountData(binance);
  let freeUsdt = 0;
  for (const balance of wallet.balances) {
    if (balance.asset == "USDT") freeUsdt = balance.free;
  }

  
  if (usdtInvest <= freeUsdt) {
    // Place a new order
    let order = await trades.placeOrder(binance, couple, 'BUY', 'LIMIT', targetPrice, buyAmount)
    console.log("order", order);
    let coupleTrades = await trades.getOpenOrders(binance, couple);
    console.log("coupleTrades", coupleTrades);

    await trades.cancelAllOpenOrders(binance)
  }
  // let {recallsNumber, sellPositive, recallsBuy, recallsQuantity} = plan;

  return await walletInfo.getAccountData(binance);
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
