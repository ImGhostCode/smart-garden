const { ApiError } = require("./apiResponse");

let messagesSent = [];

class FakeNotificationClient {
    constructor(options) {
        this.config = {
            create_error: options.create_error || null,
            send_message_error: options.send_message_error || null
        };

        if (this.config.create_error) {
            throw new ApiError(400, this.config.create_error);
        }
    }

    sendMessage(title, message) {
        if (this.config.send_message_error) {
            throw new ApiError(400, this.config.send_message_error);
        }
        messagesSent.push({ title, message });
    }

    static lastMessage() {
        if (messagesSent.length === 0) {
            return null;
        }
        return messagesSent[messagesSent.length - 1];
    }

    static allMessages() {
        return messagesSent.slice();
    }

    static reset() {
        messagesSent = [];
    }
}

module.exports = FakeNotificationClient;