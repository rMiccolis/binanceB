const { fromSecsToDate } = require('../utils/date');

/**
 * Exchange Information<br>
 *
 * GET /api/v3/exchangeInfo<br>
 *
 * Current exchange trading rules and symbol information
 * {@link https://binance-docs.github.io/apidocs/spot/en/#exchange-information}
 *
 * @param {object} [options]
 * @param {string} [options.symbol] - symbol
 * @param {Array} [options.symbols] - an array of symbols
 *
 */
 let exchangeInfo = async (binance, symbol=null) => {
    try {
        let exchangeInfo = symbol != null ? await binance.exchangeInfo({symbol: symbol}) : await binance.exchangeInfo();
        return exchangeInfo.data;
    } catch (error) {
        console.log(error.response?.data || error);
        return "Error - Unable to get info for: " + symbol + " !";
    }
  }

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
        throw {error: true, message: "Error - No trades found!", devError: error}
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
        throw {error: true, message: "Error - No history found!", devError: error}
    }
}

let getAccountData = async (binance) => {
    try {
        let accountData = await binance.account('SPOT');
        console.log(accountData);
        return accountData.data;
    } catch (error) {
        console.log(error);
        throw {error: true, message: "Error - Unable to retrieve account info!", devError: error.response.data}
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
        throw {error: true, message: "Error - Unable to retrieve account info!", devError: error.request}
    }
}

module.exports = {
    getTradesFromDate,
    getTotalSpentHistory,
    getAccountData,
    getSymbolQty,
    exchangeInfo
}