const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const db = require("../mongodb/database");


let test = async (user = {}, url = "https://testnet.binance.vision/", tradeQuantity = 30, couple = "BNBUSDT") => {
  
  let { APY_KEY, APY_SECRET } = user
  console.log(user);
  // let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  // let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  let targetPrice = 300;

  const binance = new Spot(APY_KEY, APY_SECRET, { baseURL: url });
  let coinInfo = await walletInfo.exchangeInfo(binance, 'BNBUSDT')
  let filtersInfo = coinInfo.symbols[0].filters;
  let decimalPlaces  = (filtersInfo.find( element => element.filterType == 'PRICE_FILTER')).tickSize.split('.')[1].split(1)[0].length + 1;
  let buyAmount = (usdtInvest / targetPrice).toFixed(decimalPlaces);
  console.log(buyAmount);

  let plans = db.dynamicModel("plans");
  let plan = plans.aggregate([{ $match: { userId: userId } }]);

  let wallet = await walletInfo.getAccountData(binance);
  let freeUsdt = 0;
  for (const balance of wallet.balances) {
    if (balance.asset == "USDT") freeUsdt = balance.free;
  }

  let coupleTrades = null;
  let canceledOrdersInfo = null;
  if (usdtInvest <= freeUsdt) {
    // Place a new order
    let order = await trades.placeOrder(binance, couple, 'BUY', 'LIMIT', targetPrice, buyAmount)
    coupleTrades = await trades.getOpenOrders(binance, couple);

    canceledOrdersInfo = await trades.cancelAllOpenOrders(binance, couple)
  }
  // let {recallsNumber, sellPositive, decreasePricePerc, recallsQuantity} = plan;

  //update wallet status
  wallet = await walletInfo.getAccountData(binance);
  return {opened: coupleTrades, closed: canceledOrdersInfo, wallet};
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
