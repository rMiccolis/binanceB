let logWarning = (message) => {
  //yellow message
  console.log(`\x1b[33m${message}`)
}

let logError = (message) => {
  //red message
  console.log(`\x1b[31m${message}`)
}

let logInfo = (message) => {
  //green message
  console.log(`\x1b[32m${message}`)
}

let logDebug = (message) => {
  //blue message
  console.log(`\x1b[34m${message}`)
}

module.exports = {
  logWarning,
  logError,
  logInfo,
  logDebug,
}