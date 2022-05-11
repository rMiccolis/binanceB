const { fromSecsToDate } = require('../utils/dateConverter')
let getTradesFromDate = async (binance, dateFrom=new Date(2021,0,1)) => {
    try {
        let allHistoryTime = (Date.now() - dateFrom)
        let paymentHistory = await binance.paymentHistory(0, {beginTime: allHistoryTime, endTime: Date.now()})   
        let myInfo = {totalSpent: 0, coins: {}}
        for (const iterator of paymentHistory.data.data) {
            iterator.date = fromSecsToDate(iterator.createTime)
        }
        return paymentHistory.data.data
    } catch (error) {
        return "Error - No trades found!";
    }
}

let getTotalSpentHistory = async (binance, dateFrom=new Date(2021,0,1)) => {
    try {
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
    } catch (error) {
        return "Error - No history found!";
    }
}

let getAccountData = async (binance) => {
    try {
        let accountData = await binance.account('SPOT');
        return accountData.data;
    } catch (error) {
        console.log(error);
        return "Error - Unable to retrieve account info!"
    }
}

let getSymbolQty = async (binance, symbol) => {
    try {
        let accountData = await binance.account('SPOT');
        for (const asset of accountData.data.balances) {
            if (asset.asset == symbol) {
                return asset.free
            }
        }
        return 0;
    } catch (error) {
        console.log(error);
        return "Error - Unable to retrieve account info!"
    }
}

module.exports = {
    getTradesFromDate,
    getTotalSpentHistory,
    getAccountData,
    getSymbolQty
}