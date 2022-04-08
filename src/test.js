const { Spot } = require('@binance/connector')

const walletInfo = require('./wallet/walletInfo')

let test = async () => {
    let testApy = false
    let apiKey = process.env.TEST_APY_KEY
    let apiSecret = process.env.TEST_SECRET_KEY
    if (!testApy) {
        apiKey = process.env.APY_KEY
        apiSecret = process.env.SECRET_KEY
    }  

    const spotClient = new Spot(apiKey, apiSecret)
    
    let coinInfo = (await spotClient.exchangeInfo({ symbol: 'BNBUSDT' })).data
    // return coinInfo

    return (await spotClient.newOrderTest('BNBUSDT', 'BUY', 'LIMIT', {
        price: '500',
        quantity: 0.1,
        timeInForce: 'GTC'
      })).data
    
    // let account = await spotClient.account('SPOT')
    // account.data.balances = account.data.balances.filter(elem => parseFloat(elem.free) > 0 )

    // let paymentHistory = await walletInfo.getTradesFromDate(spotClient)
    // let totalSpentHistory = await walletInfo.getTotalSpentHistory(spotClient)
    
    // return {
    //     account: account.data,
    //     paymentHistory: paymentHistory,
    //     totalSpentHistory: totalSpentHistory
    // }
    
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