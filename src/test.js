const { Spot } = require('@binance/connector')
const { aggregate, insertOne, updateOne } = require('../src/utils/mongodb')
const walletInfo = require('./wallet/walletInfo')
const trades = require('./wallet/trades')

let test = async () => {
    // let dbUser = (await aggregate("users", [{$match: {id: 'Bob617'}}]))
    let dbUser = (await aggregate("users", [{$match: {id: 'test'}}]))
    if (dbUser.length < 1) {
        return {err: "no APY_KEY found!"}
    }
    dbUser = dbUser[0]
    let apiKey = dbUser.APY_KEY
    let apiSecret = dbUser.SECRET_KEY

    // const spotClient = await new Spot(apiKey, apiSecret)
    const spotClient = new Spot(apiKey, apiSecret, { baseURL: process.env.testNetBaseUrl})

    let openOrders = await trades.getOpenOrders(spotClient)

    let testOrReal = (dbUser.id == 'test') ? "SPOTNET TEST DATA" : "Bob617 REAL DATA";
    return {
        testOrReal,
        openOrders: openOrders.data,
        account: account.data,
        // paymentHistory: paymentHistory,
        // totalSpentHistory: totalSpentHistory
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