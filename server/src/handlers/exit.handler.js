let exitHandler = function (code = "unknown code") {
    console.log("Exit handler!" + " Reason: " + code);
}

module.exports = exitHandler;