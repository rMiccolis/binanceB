/**
 * Get all Orders (USER_DATA)
 *
 * GET /api/v3/allOrders
 *
 * {@link https://binance-docs.github.io/apidocs/spot/en/#all-orders-user_data}
 * 
 * @param {*} binance The binance spot client Object
 * @param {string} [couple="BNBUSDT"] The couple to buy/sell: 'BNBUSDT' => buy/sell BNB with USDT
 * @return {*} Binance response data
 */
let getAllOrders = async (binance, couple="BNBUSDT") => {
    try {
        let allOrders = await binance.allOrders(couple, {
            orderId: 52
          });
        return allOrders;
    } catch (error) {
        return "Error - Unable to retrieve all orders!";
    }
}

/**
 * Get current Open Orders (USER_DATA)
 *
 * GET /api/v3/openOrders
 *
 * {@link https://binance-docs.github.io/apidocs/spot/en/#current-open-orders-user_data}
 * 
 * @param {*} binance The binance spot client Object
 * @param {string} [couple="BNBUSDT"] The couple to buy/sell: 'BNBUSDT' => buy/sell BNB with USDT
 * @return {*} Binance response data
 */
let getOpenOrders = async (binance, couple="BNBUSDT") => {
    try {
        let openOrders = await binance.openOrders({ symbol: couple });
        return openOrders;
    } catch (error) {
        return "Error - Unable to retrieve open orders!";
    }
}

/**
 *
 * Place new Order (TRADE)
 *
 * POST /api/v3/order
 *
 * {@link https://binance-docs.github.io/apidocs/spot/en/#new-order-trade}
 *
 * @param {Object} binance The binance spot client Object
 * @param {String} couple The couple to buy/sell: 'BNBUSDT' => buy/sell BNB with USDT
 * @param {String} sellBuy 'SELL' or 'BUY'
 * @param {string} [limit='LIMIT'] 'LIMIT', 'STOP-LIMIT', 'MARKET'
 * @param {Float} price The price of base asset to buy the principal asset. EX: 1 BNB at 300 USDT (300 is the price)
 * @param {Float} qty The quantity of principal asset to buy
 * @return {Object} Binance response data
 */
let placeOrder = async (binance, couple, sellBuy, limit='LIMIT', price, qty) => {
    try {
        if (typeof price == 'string') {
            price = parseFloat(price)
        }
        if (typeof qty == 'string') {
            qty = parseFloat(qty)
        }
        let order = await binance.newOrder(couple, sellBuy, limit, {
            price: price,
            quantity: qty,
            timeInForce: 'GTC'
            });
        return order.data;
    } catch (error) {
        return "Error during " + couple + " placeOrder!";
    }
}

/**
 * Test New Order (TRADE)<br>
 *
 * POST /api/v3/order/test<br>
 *
 * {@link https://binance-docs.github.io/apidocs/spot/en/#test-new-order-trade}
 *
 * @param {Object} binance The binance spot client Object
 * @param {String} couple The couple to buy/sell: 'BNBUSDT' => buy/sell BNB with USDT
 * @param {String} sellBuy 'SELL' or 'BUY'
 * @param {string} [limit='LIMIT'] 'LIMIT', 'STOP-LIMIT', 'MARKET'
 * @param {Float} price The price of base asset to buy the principal asset. EX: 1 BNB at 300 USDT (300 is the price)
 * @param {Float} qty The quantity of principal asset to buy
 * @return {Object} Binance response data
 */
let testOrder = async (binance, couple, sellBuy, limit='LIMIT', price, qty) => {
    try {
        if (typeof price == 'string') {
            price = parseFloat(price)
        }
        if (typeof qty == 'string') {
            qty = parseFloat(qty)
        }
        let order = await binance.newOrderTest(couple, sellBuy, limit, {
            price: price,
            quantity: qty,
            timeInForce: 'GTC'
            });
        return order.data;
    } catch (error) {
        return "Error during " + couple + " placeOrder!";
    }
}

/**
 * Cancel all Open Orders on a Symbol (TRADE)
 *
 * DELETE /api/v3/openOrders
 *
 * {@link https://binance-docs.github.io/apidocs/spot/en/#cancel-all-open-orders-on-a-symbol-trade}
 *
 * @param {*} binance The binance spot client Object
 * @param {string} [couple="BNBUSDT"] The couple to buy/sell: 'BNBUSDT' => buy/sell BNB with USDT
 * @return {*} Binance response data
 */
let cancelOpenOrders = async (binance, couple) => {
    try {
        let cancelOrders = await binance.cancelOpenOrders(couple)
        return cancelOrders.data;
    } catch (error) {
        return "Error - Unable to cancel " + couple + " orders!";
    }
}

module.exports = {
    getOpenOrders,
    getAllOrders,
    placeOrder,
    testOrder,
    cancelOpenOrders
}