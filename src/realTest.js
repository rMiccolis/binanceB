const { Spot } = require('@binance/connector')

const walletInfo = require('./wallet/walletInfo')
let test = async () => {
    const apiKey = process.env.APY_KEY
    const apiSecret = process.env.SECRET_KEY

    const spotClient = new Spot(apiKey, apiSecret)
    
    
    
    let account = await spotClient.account('SPOT')
    account.data.balances = account.data.balances.filter(elem => parseFloat(elem.free) > 0 )

    let paymentHistory = await walletInfo.getTradesFromDate(spotClient)
    let totalSpentHistory = await walletInfo.getTotalSpentHistory(spotClient)
    
    return {
        account: account.data,
        paymentHistory: paymentHistory,
        totalSpentHistory: totalSpentHistory
    }
    
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