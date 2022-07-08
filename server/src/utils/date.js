
/**
 *converts seconds to a date like dd/mm/yyyy
 *
 * @param {Integer} seconds
 * @return {String} the date into string format
 */
let fromSecsToDate = function (seconds) {
    let date = new Date(seconds)
    console.log(date.toISOString());
    let yyyy = String(date.getFullYear()).padStart(2, '0')
    let mm = String(date.getMonth() + 1).padStart(2, '0')
    let dd = String(date.getDate()).padStart(2, '0')
    return `${dd}/${mm}/${yyyy}`;
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