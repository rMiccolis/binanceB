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

      pdm = pdm > ndm && pdm > 0 ? pdm : 0;
      ndm = ndm > pdm && ndm > 0 ? ndm : 0;

      candle.positiveDirection = pdm
      candle.negativeDirection = ndm

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
    data[period - 1].positiveDirection = firstPeriodPDM;
    data[period - 1].negativeDirection = firstPeriodNDM;


  

    data[period - 1].positiveDMI = (data[period - 1].positiveDirection / data[period - 1].atr) * 100
    data[period - 1].negativeDMI = (data[period - 1].negativeDirection / data[period - 1].atr) * 100
      
    data[period - 1].directionIndex = ((Math.abs(data[period - 1].positiveDMI - data[period - 1].negativeDMI) / Math.abs(data[period - 1].positiveDMI + data[period - 1].negativeDMI)) * 100)
    data[period - 1].averageDirectionIndex = ((Math.abs(data[period - 1].positiveDMI - data[period - 1].negativeDMI) / Math.abs(data[period - 1].positiveDMI + data[period - 1].negativeDMI)) * 100) / period


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
      candle.positiveDirection = (prevCandle.positiveDirection * (period - 1) + pdm) / period
      candle.negativeDirection = (prevCandle.negativeDirection * (period - 1) + ndm) / period

      candle.positiveDMI = (candle.positiveDirection / candle.atr) * 100
      candle.negativeDMI = (candle.negativeDirection / candle.atr) * 100
      
      candle.directionIndex = (Math.abs(candle.positiveDMI - candle.negativeDMI) / Math.abs(candle.positiveDMI + candle.negativeDMI)) * 100
      candle.averageDirectionIndex = (prevCandle.averageDirectionIndex * (period - 1) + candle.directionIndex) / period

      prevCandle = candle;
      i++;
    }
  }
};

module.exports = {
  applyATR,
  applyDMI,
};
