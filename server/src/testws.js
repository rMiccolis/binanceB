const { Spot } = require("@binance/connector");
const walletInfo = require("./wallet/walletInfo");
const db = require("./mongodb/database");
const statistics = require("./realTimeData/statistics");
const trades = require("./trades/trades");
const childProcess = require('child_process')

let testws = async (connections, tradeQuantity = 30, couple = "BNBUSDT") => {
    const callbacks = {
        open: () => console.logDebug("Connected with Websocket server"),
        close: () => console.logDebug("Disconnected with Websocket server"),
        message: (data) => console.logDebug("data: " + data),
    };

    let client = connections.binanceSpotConnection;
    let listenKey = (await client.createListenKey()).data;
    const ws = client.userData(listenKey, callbacks);
    await syncSetTimeout(20000, client.unsubscribe, ws)
    // await syncSetTimeout(20000);
    return { ciao: 1 };
};

const syncSetTimeout = (ms, f, params = null) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (f) {
                if (params) f(params);
                else f();
            }
            resolve();
        }, ms);
    });
};

module.exports = {
    testws,
};
