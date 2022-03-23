const { Spot } = require('@binance/connector')
const axios = require('axios');
let test = async () => {
    console.log("test");
    const apiKey = process.env.TEST_APY_KEY
    const apiSecret = process.env.TEST_SECRET_KEY

    const spotClient = new Spot(apiKey, apiSecret, { baseURL: 'https://testnet.binance.vision'})
    const wsClient = new Spot(apiKey, apiSecret, {
        wsURL: 'wss://testnet.binance.vision' // wsURL defaults to wss://stream.binance.com:9443
    })

    const callbacks = {
        open: () => wsClient.logger.debug('open'),
        close: () => wsClient.logger.debug('closed'),
        message: data => wsClient.logger.log(data)
    }
    a = await spotClient.accountSnapshot('SPOT')
    console.log(a.data);
    // Get account information
    // spotClient.account().then((response) => spotClient.logger.log(response.data))
    let returnVal = "a"
    return returnVal
}
module.exports = {
    test
}


// Place a new order
// client.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
//   price: '350',
//   quantity: 1,
//   timeInForce: 'GTC'
// }).then(response => client.logger.log(response.data))
//   .catch(error => client.logger.error(error))