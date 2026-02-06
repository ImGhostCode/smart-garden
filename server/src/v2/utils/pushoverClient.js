const { ApiError } = require("./apiResponse");

class PushoverClient {
    constructor(options) {
        this.baseURI = process.env.PUSHOVER_BASE_URL || 'https://api.pushover.net/1/messages.json';
        this.config = options;
        if (!this.config.user || !this.config.token) {
            throw new ApiError(400, 'Authentication and client credentials are required');
        }
    }

    async sendMessage(title, message) {
        const msg = {
            user: this.config.user,
            token: this.config.token,
            message: message,
            title: title,
            device: this.config.device_name || undefined,
        };

        const res = await fetch(this.baseURI, {
            method: 'POST',
            body: new URLSearchParams(msg),
        });
        if (!res.ok) {
            console.error('Pushover send message error', await res.text());
            throw new ApiError(500, `Pushover message send failed`);
        }
    }

}
module.exports = PushoverClient;