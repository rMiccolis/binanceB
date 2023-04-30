let logWarning = (message) => {
  //yellow message
  console.log(`\x1b[33m${JSON.stringify(message, null, 4)}`)
}

let logError = (message) => {
  //red message
  console.log(`\x1b[31m${JSON.stringify(message, null, 4)}`)
}

let logInfo = (message) => {
  //green message
  console.log(`\x1b[32m${JSON.stringify(message, null, 4)}`)
}

let logDebug = (message) => {
  //blue message
  console.log(`\x1b[34m${JSON.stringify(message, null, 4)}`)
}

module.exports = {
  logWarning,
  logError,
  logInfo,
  logDebug,
}