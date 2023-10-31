const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const db = require("./mongodb/database");
const statistics = require("./realTimeData/statistics");
const trades = require("./trades/trades");

let startBotTest = async (user = {}, url = "https://testnet.binance.vision/", tradeQuantity = 30, couple = "BNBUSDT") => {
  let { API_KEY, API_SECRET } = user;
  // let apiKey = "bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn";
  // let apiSecret = "86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY";
  // let targetPrice = 300;

  const binance = new Spot(API_KEY, API_SECRET, { baseURL: url });
  let orders = db.dynamicModel("orders");
  // delete all open orders
  await trades.cancelAllOpenOrders(binance, couple);
  let r = await orders.deleteMany({ userId: user.userId, symbol: couple });
  console.log(r, user.userId, couple);

  // retrieve info about couple
  let coinInfo = await walletInfo.exchangeInfo(binance, "BNBUSDT");
  // we need filters array to take the PRICE_FILTER element which tells how many decimal places the amount can have
  let filtersInfo = coinInfo.symbols[0].filters;
  // compute decimal places because binance PRICE_FILTER is of type '0.001', it means it can have max 3 decimal places
  let decimalPlaces =
    filtersInfo
      .find((element) => element.filterType == "PRICE_FILTER")
      .tickSize.split(".")[1]
      .split(1)[0].length + 1;

  let botStrategies = db.dynamicModel("strategies");

  let botStrategy = await botStrategies.aggregate([{ $match: { userId: user.userId } }]);
  if (botStrategy.length > 0) {
    botStrategy = botStrategy[0];
  } else {
    return {};
  }
  let wallet = await walletInfo.getAccountData(binance);
  let freeUsdt = 0;
  for (const balance of wallet.balances) {
    if (balance.asset == "USDT") freeUsdt = balance.free;
  }

  let currentPrice = await statistics.tickerPrice(binance, couple);
  // place all negative buy orders:
  for (const [index, perc] of botStrategy.buyNegativePerc.entries()) {
    let buyPrice = parseFloat(currentPrice - currentPrice * perc).toFixed(2);
    usdtAmount = tradeQuantity * botStrategy.recallsQuantity[index];
    // compute the actual buyAmount and fix decimal places
    let buyAmount = parseFloat(usdtAmount / buyPrice).toFixed(decimalPlaces);
    let order = null;
    try {
      order = await trades.placeOrder(binance, couple, "BUY", "LIMIT", buyPrice, buyAmount);
    } catch (error) {
      continue;
    }

    buyPrice = parseFloat(buyPrice);
    // calculate price sell for this order: when the buy order is fired, place a sell order:
    let sellPrice = parseFloat(buyPrice + buyPrice * botStrategy.sellPositivePerc).toFixed(2);
    console.log(`BUY: ${buyPrice}, SELL: ${sellPrice}`);
    order.userId = user.userId;
    order.sellPrice = sellPrice;
    // // Save order to db
    order = new orders(order);
    await order.save();
  }

  wallet = await walletInfo.getAccountData(binance);
  let coupleTrades = await trades.getOpenOrders(binance, couple);
  await trades.cancelAllOpenOrders(binance, couple);
  return { coupleTrades, wallet };
};

let setBotStrategy = async function (user, strategy) {
  strategy.userId = user.userId;
  let botStrategies = db.dynamicModel("strategies");
  strategy = new botStrategies(strategy);
  await strategy.save();
};

module.exports = {
  startBotTest,
};
