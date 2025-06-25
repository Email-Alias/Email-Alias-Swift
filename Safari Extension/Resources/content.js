async function setCurrentEmail() {
    const currentDomain = document.URL.split('/')[2].split('.').reverse()[1];
    let emails = JSON.parse((await browser.runtime.sendMessage({ type: "alias" })).emails);
    let selectedEmails = []
    for (let email of emails) {
        if (email.privateComment.replace(' ', '').toLowerCase().includes(currentDomain)) {
            selectedEmails.push(email)
        }
    }
    if (selectedEmails.length == 1) {
        const inputs = document.querySelectorAll("input[type='email']");
        for (let input of inputs) {
            input.value = selectedEmails[0].address;
        }
    }
}

setCurrentEmail();
