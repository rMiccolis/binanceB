let db = require("./mongodb/database");

/**
 * Sets the user strategy
 *
 * @param {Object} plan
 * @return {*} 
 */
let setStrategy = async (strategy) => {
    let strategies = db.dynamicModel('strategies');
    //write strategy to db
    let userStrategy = new strategies(strategy);
    await userStrategy.save()
}

module.exports = {
    setStrategy
}