let getAllOrders = async (binance, couple="BNBUSDT") => {
    let openOrders = await binance.allOrders(couple, {
        orderId: 52
      });
    return openOrders;
}

let getOpenOrders = async (binance, couple="BNBUSDT") => {
    let openOrders = await binance.openOrders({ symbol: couple });
    return openOrders;
}

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
        return "Error during placeOrder!"
    }
}

let cancelOpenOrders = async (binance, couple) => {
    let cancelOrders = await binance.cancelOpenOrders(couple)
    return cancelOrders.data;
}

module.exports = {
    getOpenOrders,
    getAllOrders,
    placeOrder,
    cancelOpenOrders
}