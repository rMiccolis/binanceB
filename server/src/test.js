const { Spot } = require("@binance/connector");
const { aggregate, insertOne, updateOne } = require("../src/utils/mongodb");
const walletInfo = require("./wallet/walletInfo");
const trades = require("./wallet/trades");

let test = async (user) => {
  // let dbUser = (await aggregate("users", [{$match: {id: 'Bob617'}}]))
  let apiKey = user.APY_KEY;
  let apiSecret = user.SECRET_KEY;
  let buyQty = 100;
  // const spotClient = await new Spot(apiKey, apiSecret)
  const spotClient = new Spot(apiKey, apiSecret, { baseURL: process.env.testNetBaseUrl });

  let testOrReal = dbUser.id == "test" ? "SPOTNET TEST DATA" : "Bob617 REAL DATA";
  return await walletInfo.getAccountData(spotClient)
  let strings = await bot(spotClient, buyQty);
  console.log(strings);
  //   setInterval(bot, 2000, spotClient);
  return {
    strings: strings,
    testOrReal,
    // tickerPrice: tickerPrice,
    // openOrders: openOrders,
    // account: account.data,
    // paymentHistory: paymentHistory,
    // totalSpentHistory: totalSpentHistory
  };
};

let bot = async (spotClient, buyQty) => {
  let openOrders = await trades.getOpenOrders(spotClient, "BNBUSDT");
  return openOrders
  openOrders.forEach(async (element) => {
    console.log(element);
    // await trades.cancelOpenOrders(spotClient, "BNBUSDT");
  });

  let marketPrice = await trades.tickerPrice(spotClient, "BNBUSDT");
  let buyorder = marketPrice * (1 + 0.2);
  let sellorder = marketPrice * (1 - 0.2);
  let baseAmount = await walletInfo.getSymbolQty(spotClient, "USDT");
  let buyvolume = buyQty / marketPrice;

  let exchangeInfo = await trades.exchangeInfo(spotClient, "BNBUSDT");
  // console.log(exchangeInfo);
  // console.log(exchangeInfo);
  let decimals = 0;
  for (const filter of exchangeInfo.symbols[0].filters) {
    if (filter.filterType == "PRICE_FILTER") {
      // if (buyorder > marketPrice * filter.multiplierUp) buyorder = marketPrice * filter.multiplierUp;
      // if (buyorder < marketPrice * filter.multiplierDown) buyorder = marketPrice * filter.multiplierDown;
      // if (sellorder > marketPrice * filter.multiplierUp) sellorder = marketPrice * filter.multiplierUp;
      // if (sellorder < marketPrice * filter.multiplierDown) sellorder = marketPrice * filter.multiplierDown;

      let tickString = filter.tickSize.toString().split(".");
      if (tickString.length > 1) {
        for (const iterator of tickString) {
          if (iterator != "1") {
            decimals++;
          } else {
            break;
          }
        }
      }
    }
  }
  buyorder = parseFloat(buyorder.toFixed(decimals));
  sellorder = parseFloat(sellorder.toFixed(decimals));
  buyvolume = parseFloat(buyvolume.toFixed(decimals));
  console.log("price:", marketPrice, "buy:", buyorder, "buyQty", buyvolume, "sell:", sellorder);
  // return exchangeInfo;

  let response = await trades.placeOrder(spotClient, "BNBUSDT", "BUY", "LIMIT", 290, buyvolume);
  await trades.placeOrder(spotClient, "BNBUSDT", "SELL", "LIMIT", sellorder, buyvolume);
  // openOrders = await trades.getOpenOrders(spotClient, "BNBUSDT");
  return response;
  // return {
  //     log1: "new tick form LUNAUSDT...",
  //     log2: "created limit SELL order for LUNAUSDT@" + sellorder.toString(),
  //     log3: "created limit BUY order for LUNAUSDT@" + buyorder.toString()
  // }
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
