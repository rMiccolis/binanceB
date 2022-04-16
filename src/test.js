const { Spot } = require('@binance/connector')
const { aggregate, insertOne, updateOne } = require('../src/utils/mongodb')
const walletInfo = require('./wallet/walletInfo')

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
    
    // let coinInfo = (await spotClient.exchangeInfo({ symbol: 'BNBUSDT' })).data
    // return coinInfo
    // try {
    //     let order = (await spotClient.newOrder('BNBUSDT', 'BUY', 'LIMIT', {
    //         price: '300',
    //         quantity: 0.1,
    //         timeInForce: 'GTC'
    //       })).data;
    //       console.log(order);
    // } catch (error) {
    //     console.log(error);
    //     return {}
    // }


    let account = await spotClient.account('SPOT');
    
    // account.data.balances = account.data.balances.filter(elem => parseFloat(elem.free) > 0 )

    // let paymentHistory = await walletInfo.getTradesFromDate(spotClient)
    // let totalSpentHistory = await walletInfo.getTotalSpentHistory(spotClient)

    // await spotClient.cancelOpenOrders('BNBUSDT')

    let openOrders = await spotClient.allOrders('BNBUSDT', {
        orderId: 52
      })
    openOrders.data = openOrders.data.filter(elem => elem.status != "CANCELED" )
    return {
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