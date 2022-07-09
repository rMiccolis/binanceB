const { Spot } = require("@binance/connector");
const { aggregate, insertOne, updateOne } = require("../src/utils/mongodb");
const walletInfo = require("./wallet/walletInfo");
const trades = require("./wallet/trades");
const coinInfo = require("./coinInfo/info");
const date = require("./utils/date");
const indicators = require("./indicators/indicators");

let test = async (url) => {
    let apiKey = 'bbkiwmw84nEDlTva95ZRXTd4pU3McXQXVRFhWFzvsJZBNboLOSWML3L6hOqeF6vn';
    let apiSecret = '86bjkGEwAte6AUueEM3leL3Dn5Gt1axHz6fzF0LqyOPFT02HM4DHvgOWKAJTKZHY';
    let buyQty = 100;
    const binance = new Spot(apiKey, apiSecret, { baseURL: url });
    // let data = await bot(binance, buyQty);
    let klines = await coinInfo.getKlines(binance, "BTCUSDT", '1h')
    // indicators.applyATR(klines);
    indicators.applyDMI(klines);
    console.log(klines);
};

// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))

test('https://testnet.binance.vision/')