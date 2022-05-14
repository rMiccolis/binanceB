let accountCheck = async (req, res, next) => {
    let userId = req.params.userId;
    let dbUser = await db.aggregate("users", [{ $match: { id: userId } }]);
    if (dbUser.length < 1) {
        return { err: "no APY_KEY found!" };
    }
    if (userId != 'test') {
        console.log("ATTENZIONE STAI USANDO L'ACCOUNT REALE");
    }
    req.params.userId = dbUser[0]
}