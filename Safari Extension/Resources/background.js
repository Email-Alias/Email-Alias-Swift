browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.type === "alias") {
        return new Promise(resolve => {
            browser.runtime.sendNativeMessage("com.opdehipt.Email-Alias", "getAliases", function(response) {
                resolve(response);
            });
        });
    }
});
