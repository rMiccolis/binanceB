
/**
 *converts seconds to a date like dd/mm/yyyy
 *
 * @param {Integer} seconds
 * @return {String} the date into string format
 */
let fromSecsToDate = function (seconds) {
    let date = toDateTime(seconds)
    let yyyy = date.getFullYear()
    let mm = date.getMonth()
    let dd = date.getDay()
    return `${dd}/${mm}/${yyyy}`
}

/**
 * returns a date object from input seconds
 *
 * @param {*} secs
 * @return {*} 
 */
function toDateTime(secs) {
    var date = new Date(0, 0, 0); // Epoch
    date.setSeconds(secs);
    return date;
}

module.exports = {
    fromSecsToDate
}