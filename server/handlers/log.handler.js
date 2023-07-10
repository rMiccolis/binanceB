let logWarning = (...strings) => {
  //yellow message
  console.log(`\x1b[33m${strings} \x1b[37m`)
}

let logError = (...strings) => {
  //red message
  console.log(`\x1b[31m${strings} \x1b[37m`)
}

let logDebug = (...strings) => {
  //blue message
  console.log(`\x1b[1;34m${strings} \x1b[37m`)
}

let logSuccess = (...strings) => {
  //green message
  console.log(`\x1b[32m${strings} \x1b[37m`)
}

module.exports = {
  logWarning,
  logError,
  logSuccess,
  logDebug,
}