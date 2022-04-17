let savingsAccount = async (binance) => {
    try {
        let savingsAccount = await binance.savingsAccount()
        return savingsAccount.data;
    } catch (error) {
        console.log(error);
        return "Error - Unable to retrieve savings info!"
    }
}

module.exports = {
    savingsAccount,
}