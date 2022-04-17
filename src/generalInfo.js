let coinInfo = async (binance, couple='BNBUSDT') => {
    let coinInfo = await binance.exchangeInfo({ symbol: couple })
    return coinInfo.data;
}

module.exports = {
    coinInfo,
}