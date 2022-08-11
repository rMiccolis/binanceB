const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const db = require("../mongodb/database");
const statistics = require("./realTimeData/statistics");
const trades = require("./trades/trades");

let test = async (user = {}, url = "https://testnet.binance.vision/", tradeQuantity = 30, couple = "BNBUSDT") => {
  
  let { APY_KEY, APY_SECRET } = user
  // let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  // let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  // let targetPrice = 300;

  const binance = new Spot(APY_KEY, APY_SECRET, { baseURL: url });

  // retrieve info about couple
  let coinInfo = await walletInfo.exchangeInfo(binance, 'BNBUSDT')
  // we need filters array to take the PRICE_FILTER element which tells how many decimal places the amount can have
  let filtersInfo = coinInfo.symbols[0].filters;
  // compute decimal places because binance PRICE_FILTER is of type '0.001', it means it can have max 3 decimal places
  let decimalPlaces  = (filtersInfo.find( element => element.filterType == 'PRICE_FILTER')).tickSize.split('.')[1].split(1)[0].length + 1;
  

  let plans = db.dynamicModel("plans");
  let plan = await plans.aggregate([{ $match: { userId: user.userId } }]);
  plan = plan.length > 0 ? plan[0] :{}
  let wallet = await walletInfo.getAccountData(binance);
  let freeUsdt = 0;
  for (const balance of wallet.balances) {
    if (balance.asset == "USDT") freeUsdt = balance.free;
  }

  let coupleTrades = null;
  let canceledOrdersInfo = null;
  let currentPrice = await statistics.tickerPrice(binance, couple)
  // place all negative buy orders:
  for (const [index, perc] of plan.decreasePricePerc.entries()) {
    let targetPrice = currentPrice - (currentPrice * perc);
    usdtAmount = tradeQuantity * plan.recallsQuantity[index];
    // compute the actual buyAmount and fix decimal places
    let buyAmount = parseFloat((usdtAmount / targetPrice).toFixed(decimalPlaces))
    await trades.placeOrder(binance, couple, 'BUY', 'LIMIT', targetPrice, buyAmount)
  }

  wallet = await walletInfo.getAccountData(binance);
  coupleTrades = await trades.getOpenOrders(binance, couple);
  // await trades.cancelAllOpenOrders(binance, couple)
  return { wallet, coupleTrades}

  // place positive sell orders


};

module.exports = {
  test,
};

// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))
