/**
 * apply AVERAGE TRUE RANGE (ATR)
 * measures market volatility
 *
 * a high level of volatility has a higher ATR, and a low volatility stock has a lower ATR
 * @param {Array} data
 * @param {number} [smoothing=14]
 */
let applyATR = async function (data, period = 14) {
  if (Array.isArray(data) && data.length > period) {
    let prevCandle = data[0];
    prevCandle.tr = prevCandle.high - prevCandle.low;
    let i = 1;
    firstPeriodATR = prevCandle.tr;
    while (i < period) {
      let candle = data[i];
      let { high, low, close } = candle;
      let prevClose = prevCandle.close;
      let tr = Math.max(high - low, Math.abs(high - prevClose), Math.abs(low - prevClose));
      candle.tr = tr;
      prevCandle = candle;
      firstPeriodATR += tr;
      i++;
    }
    firstPeriodATR = firstPeriodATR / period;

    data[period - 1].atr = firstPeriodATR;
    prevCandle = data[period - 1];
    i = period;
    while (i < data.length) {
      let candle = data[i];
      let { high, low, close } = candle;
      let prevClose = prevCandle.close;
      let tr = Math.max(high - low, Math.abs(high - prevClose), Math.abs(low - prevClose));
      candle.atr = (prevCandle.atr * (period - 1) + tr) / period;
      prevCandle = candle;
      i++;
    }
  }
};

let applyDMI = function (data, period=14) {
  // PDM = positive direction index
  // NDM = negative direction index
  if (Array.isArray(data) && data.length > period) {
    let prevCandle = data[0];
    prevCandle.tr = prevCandle.high - prevCandle.low;
    let i = 1;
    firstPeriodATR = prevCandle.tr;
    firstPeriodPDM = prevCandle.high;
    firstPeriodNDM = prevCandle.low;
    while (i < period) {
      let candle = data[i];
      let { high, low, close } = candle;
      let prevClose = prevCandle.close;
      let tr = Math.max(high - low, Math.abs(high - prevClose), Math.abs(low - prevClose));
      candle.tr = tr;

      let pdm = candle.high - prevCandle.high;
      let ndm = candle.low - prevCandle.low;

      prevCandle = candle;
      firstPeriodATR += tr;
      firstPeriodPDM += pdm;
      firstPeriodNDM += ndm;
      i++;
    }
    firstPeriodATR = firstPeriodATR / period;
    firstPeriodPDM = firstPeriodPDM / period
    firstPeriodNDM = firstPeriodNDM / period


    data[period - 1].atr = firstPeriodATR;
    data[period - 1].pdm = firstPeriodPDM;
    data[period - 1].ndm = firstPeriodNDM;
    prevCandle = data[period - 1];
    i = period;
    while (i < data.length) {
      let candle = data[i];
      let { high, low, close } = candle;
      let prevClose = prevCandle.close;
      let tr = Math.max(high - low, Math.abs(high - prevClose), Math.abs(low - prevClose));
      let pdm = (candle.high - prevCandle.high) / period;
      let ndm = (candle.low - prevCandle.low) / period;

      candle.atr = (prevCandle.atr * (period - 1) + tr) / period;


      candle.posDirectionIdx = (pdm / candle.atr) * 100
      candle.negDirectionIdx = (ndm / candle.atr) * 100
      candle.directionalMovementIdx = (Math.abs(candle.posDirectionIdx - candle.negDirectionIdx) / Math.abs(candle.posDirectionIdx + candle.negDirectionIdx)) * 100


      prevCandle = candle;
      i++;
    }
  }
};

module.exports = {
  applyATR,
  applyDMI,
};
