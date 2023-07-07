let logWarning = (message) => {
  //yellow message
  console.log(`\x1b[33m${JSON.stringify(message, null, 4)} \x1b[37m`)
}

let logError = (message) => {
  //red message
  console.log(`\x1b[31m${JSON.stringify(message, null, 4)} \x1b[37m`)
}

let logDebug = (message) => {
  //blue message
  console.log(`\x1b[1;34m${JSON.stringify(message, null, 4)} \x1b[37m`)
}

let logSuccess = (message) => {
  //green message
  console.log(`\x1b[32m${JSON.stringify(message, null, 4)} \x1b[37m`)
}

module.exports = {
  logWarning,
  logError,
  logSuccess,
  logDebug,
}