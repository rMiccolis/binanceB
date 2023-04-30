let savingsAccount = async (binance) => {
    try {
        let savingsAccount = await binance.savingsAccount()
        return savingsAccount.data;
    } catch (error) {
        console.log(error.response.data);
        return "Error - Unable to retrieve savings info!"
    }
}

let getBlockedStaking = async (binance) => {
    try {
        let blockedStaking = await binance.stakingProductPosition('STAKING')
        return blockedStaking.data;
    } catch (error) {
        console.logError("getBlockedStaking error");
        console.logError(error.message || error.data);
        console.logError(error.config || error);
        return "Error - Unable to retrieve blocked staking info!";
    }
}

module.exports = {
    savingsAccount,
    getBlockedStaking
}