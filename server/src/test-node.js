const { Spot } = require("@binance/connector");
const { aggregate, insertOne, updateOne } = require("../src/utils/mongodb");
const walletInfo = require("./wallet/walletInfo");
const trades = require("./wallet/trades");
const coinInfo = require("./coinInfo/info");
const date = require("./utils/date");

let test = async (url) => {
    let apiKey = 'bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn';
    let apiSecret = '86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY';
    let buyQty = 100;
    const binance = new Spot(apiKey, apiSecret, { baseURL: url });
    // let data = await bot(binance, buyQty);
    let klines = await coinInfo.getKlines(binance, "BTCUSDT", '1d')

    console.log(klines);
};

let bot = async (binance, buyQty) => {
  let openOrders = await trades.getOpenOrders(binance, "BNBUSDT");

  // openOrders.forEach(async (element) => {
  //   console.log(element);
  //   // await trades.cancelOpenOrders(binance, "BNBUSDT");
  // });
  let exchangeInfo = await trades.exchangeInfo(binance, "BNBUSDT");

  let marketPrice = await trades.tickerPrice(binance, "BNBUSDT");
  let buyorder = marketPrice * (1 - 0.02);
  let sellorder = marketPrice * (1 + 0.02);
  let baseAmount = await walletInfo.getSymbolQty(binance, "USDT");
  let buyvolume = buyQty / marketPrice;
  
  let decimals = 0;
  for (const filter of exchangeInfo.symbols[0].filters) {
    if (filter.filterType == "PRICE_FILTER") {
      // if (buyorder > marketPrice * filter.multiplierUp) buyorder = marketPrice * filter.multiplierUp;
      // if (buyorder < marketPrice * filter.multiplierDown) buyorder = marketPrice * filter.multiplierDown;
      // if (sellorder > marketPrice * filter.multiplierUp) sellorder = marketPrice * filter.multiplierUp;
      // if (sellorder < marketPrice * filter.multiplierDown) sellorder = marketPrice * filter.multiplierDown;

      let tickString = filter.tickSize.toString().split(".");
      if (tickString.length > 1) {
        for (const iterator of tickString[1]) {
          if (iterator != "1") {
            decimals++;
          } else {
            break;
          }
        }
      }
    }
    if (decimals > 0) {
      decimals++
    }
    break
  }
  buyorder = parseFloat(buyorder.toFixed(decimals));
  sellorder = parseFloat(sellorder.toFixed(decimals));
  buyvolume = parseFloat(buyvolume.toFixed(decimals));
  console.log("price:", marketPrice, "buy:", buyorder, "buyQty", buyvolume, "sell:", sellorder);
  return {marketPrice, buyorder, sellorder, baseAmount, buyvolume, buyorder, sellorder, exchangeInfo}

  let response = await trades.placeOrder(binance, "BNBUSDT", "BUY", "LIMIT", 290, buyvolume);
  await trades.placeOrder(binance, "BNBUSDT", "SELL", "LIMIT", sellorder, buyvolume);
  // openOrders = await trades.getOpenOrders(binance, "BNBUSDT");
  return response;
  // return {
  //     log1: "new tick form LUNAUSDT...",
  //     log2: "created limit SELL order for LUNAUSDT@" + sellorder.toString(),
  //     log3: "created limit BUY order for LUNAUSDT@" + buyorder.toString()
  // }
};

// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))

test('https://testnet.binance.vision/')