
/**
 *converts seconds to a date like dd/mm/yyyy
 *
 * @param {Integer} seconds
 * @return {String} the date into string format
 */
let fromSecsToDate = function (seconds, time=true) {
    let date = new Date(seconds)
    console.log(date.toISOString());
    let yyyy = String(date.getFullYear()).padStart(2, '0')
    let mm = String(date.getMonth() + 1).padStart(2, '0')
    let dd = String(date.getDate()).padStart(2, '0')
    let hh = String(date.getHours()).padStart(2, '0')
    let min = String(date.getMinutes()).padStart(2, '0')
    let timeStr = time == true ? `-${hh}:${min}` : ''
    return `${dd}/${mm}/${yyyy}${timeStr}`;
}

let fromDateToSecs = function (dd, mm, yyyy) {
    let date = new Date();
    date.setFullYear(yyyy);
    date.setMonth(parseInt(mm) - 1);
    date.setDate(dd);
    return date.getTime();
}

module.exports = {
    fromSecsToDate,
    fromDateToSecs
}