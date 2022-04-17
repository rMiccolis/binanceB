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

let getOpenOrders = async (binance, couple="BNBUSDT") => {
    try {
        let openOrders = await binance.openOrders({ symbol: couple });
        return openOrders;
    } catch (error) {
        return "Error - Unable to retrieve open orders!";
    }
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
        return "Error during " + couple + " placeOrder!";
    }
}

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
    cancelOpenOrders
}