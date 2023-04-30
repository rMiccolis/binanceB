/**
 * Get the Candlestick data for a couple
 *
 * @param {*} binance
 * @param {string} [couple='BNBUSDT']
 * @param {string} [interval='1d'] Example:
 *  Kline/Candlestick chart intervals:
 *
 *  m -> minutes; h -> hours; d -> days; w -> weeks; M -> months
 *  1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
 * 
 * @param {Object} [options={}] Example: { limit: 1000, startTime: '0' }
 * @return {Array}:
 * [
 *  [
 *    1499040000000,      // Open time
 *    "0.01634790",       // Open
 *    "0.80000000",       // High
 *    "0.01575800",       // Low
 *    "0.01577100",       // Close
 *    "148976.11427815",  // Volume
 *    1499644799999,      // Close time
 *    "2434.19055334",    // Quote asset volume
 *    308,                // Number of trades
 *    "1756.87402397",    // Taker buy base asset volume
 *    "28.46694368",      // Taker buy quote asset volume
 *    "17928899.62484339" // Ignore.
 *  ]
 * ]
 */
 let getKlines = async (binance, couple='BNBUSDT', interval='1d', options={}) => {
    try {
        let klines = await binance.klines(couple, interval, options)
        //enrich array response
        klinesEnriched = []
        for (const intervalData of klines.data) {
            enrichedElement = {}
            enrichedElement.openTime = date.fromSecsToDate(intervalData[0])
            enrichedElement.open = parseFloat(intervalData[1])
            enrichedElement.high = parseFloat(intervalData[2])
            enrichedElement.low = parseFloat(intervalData[3])
            enrichedElement.close = parseFloat(intervalData[4])
            enrichedElement.volume = parseFloat(intervalData[5])
            enrichedElement.closeTime = date.fromSecsToDate(intervalData[6])
            enrichedElement.quoteAssetVolume = parseFloat(intervalData[7])
            enrichedElement.tradesNumber = parseInt(intervalData[8])
            enrichedElement.takerBuyBaseAssetVolume = parseFloat(intervalData[9])
            enrichedElement.takerBuyQuoteAssetVolume = parseFloat(intervalData[10])

            klinesEnriched.push(enrichedElement);
        }
        return klinesEnriched;
    } catch (error) {
        return "Error - Unable to retrieve " + couple + " klines info!"
    }
}

/**
 * Current Average Price<br>
 *
 * GET /api/v3/avgPrice<br>
 *
 * Current average price for a symbol.<br>
 * {@link https://binance-docs.github.io/apidocs/spot/en/#current-average-price}
 * @param {*} binance
 * @param {string} [couple='BNBUSDT']
 */
 let avgPrice = async (binance, couple = "BNBUSDT") => {
    try {
      let avgPrice = await binance.avgPrice({ symbol: couple });
      return avgPrice.data;
    } catch (error) {
      return "Error - Unable to retrieve " + couple + " average price!";
    }
  };
  
  /**
     * Symbol Price Ticker<br>
     *
     * GET /api/v3/ticker/price
     *
     * {@link https://binance-docs.github.io/apidocs/spot/en/#symbol-price-ticker}
     *
     * @param {string} [symbol]
    */
   let tickerPrice = async (binance, couple='') => {
    try {
        let tickerPrice = await binance.tickerPrice(couple);
        return parseFloat(tickerPrice.data.price);
    } catch (error) {
        console.log(error.response.data);
        return "Error - Unable to get ticker price for: " + couple + " !";
    }
  }

module.exports = {
    getKlines,
    avgPrice,
    tickerPrice
};
