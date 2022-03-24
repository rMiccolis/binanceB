const { Spot } = require('@binance/connector')
let test = async () => {
    const apiKey = process.env.APY_KEY
    const apiSecret = process.env.SECRET_KEY

    const spotClient = new Spot(apiKey, apiSecret)
    let epoch = new Date(2021,0,1)
    let allHistoryTime = (Date.now() - epoch)
    let data = await spotClient.paymentHistory(0, {beginTime: allHistoryTime, endTime: Date.now()})
    let myInfo = {totalSpent: 0, coins: {}}
    for (const iterator of data.data.data) {
        let date = toDateTime(iterator.createTime)
        let yyyy = date.getFullYear()
        let mm = date.getMonth()
        let dd = date.getDay()
        iterator.date = `${yyyy}/${mm}/${dd}`
        if (iterator.status == "Completed"){
            myInfo.totalSpent += parseFloat(iterator.sourceAmount)
            myInfo.coins[iterator.cryptoCurrency] = 1
        }
    }
    console.log("miningAccountEarning");
    let ticker = await spotClient.account('SPOT')
    
    return {ticker: ticker.data}
    
}

function toDateTime(secs) {
    var t = new Date(0, 0, 0); // Epoch
    t.setSeconds(secs);
    return t;
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