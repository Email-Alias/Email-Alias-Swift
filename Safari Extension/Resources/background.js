browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request: ", request);

    if (request.type === "alias") {
        return new Promise(resolve => {
            browser.runtime.sendNativeMessage("com.opdehipt.Email-Alias", "getAliases", function(response) {
                resolve(response);
            });
        });
    }
});
