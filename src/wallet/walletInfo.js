const { fromSecsToDate } = require('../utils/dateConverter')
let getTradesFromDate = async (binance, dateFrom=new Date(2021,0,1)) => {
    let allHistoryTime = (Date.now() - dateFrom)
    let paymentHistory = await binance.paymentHistory(0, {beginTime: allHistoryTime, endTime: Date.now()})   
    let myInfo = {totalSpent: 0, coins: {}}
    for (const iterator of paymentHistory.data.data) {
        iterator.date = fromSecsToDate(iterator.createTime)
    }
    return paymentHistory.data.data
}

let getTotalSpentHistory = async (binance, dateFrom=new Date(2021,0,1)) => {
    let allHistoryTime = (Date.now() - dateFrom)
    let paymentHistory = await binance.paymentHistory(0, {beginTime: allHistoryTime, endTime: Date.now()})   
    let myInfo = {totalSpent: 0, coins: {}}
    for (const iterator of paymentHistory.data.data) {
        if (iterator.status == "Completed"){
            myInfo.totalSpent += parseFloat(iterator.sourceAmount)
            myInfo.coins[iterator.cryptoCurrency] = 1
        }
    }
    return myInfo
}

module.exports = {
    getTradesFromDate,
    getTotalSpentHistory
}