let coinInfo = async (binance, couple='BNBUSDT') => {
    try {
        let coinInfo = await binance.exchangeInfo({ symbol: couple })
        return coinInfo.data;
    } catch (error) {
        return "Error - Unable to retrieve " + couple + " info!"
    }
}

module.exports = {
    coinInfo,
}