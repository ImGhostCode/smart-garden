const { ApiError } = require("../utils/apiResponse");
const PushoverClient = require("../utils/pushoverClient");
const FakeNotificationClient = require("../utils/fakeNotificationClient");

class NotificationClient {
    constructor(client) {
        this.client = client;

        switch (client.type) {
            case 'pushover':
                this.client = new PushoverClient(client.options);
                break;
            case 'fake':
                this.client = new FakeNotificationClient(client.options);
                break;
            default:
                throw new ApiError(400, `Invalid client type: ${client.type}`);
        }
    }

    async sendMessage(title, message) {
        return await this.client.sendMessage(title, message);
    }
}

module.exports = NotificationClient;