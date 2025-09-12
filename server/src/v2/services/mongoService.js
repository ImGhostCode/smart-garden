const mongoose = require('mongoose');

class MongoService {
    constructor() {
        this.isConnected = false;
        this.connectionRetries = 0;
        this.maxRetries = 5;
    }

    async connect(uri = process.env.MONGODB_URI || 'mongodb://root:password@localhost:27017/smartgarden?authSource=admin') {
        try {
            // Set mongoose options
            mongoose.set('strictQuery', true);

            const options = {
                autoIndex: true,
                maxPoolSize: 10,
                serverSelectionTimeoutMS: 5000,
                socketTimeoutMS: 45000
            };

            await mongoose.connect(uri, options);

            this.isConnected = true;
            this.connectionRetries = 0;
            console.log('[MongoDB] Connected successfully to:', uri.replace(/\/\/.*@/, '//<credentials>@'));

            // Handle connection events
            mongoose.connection.on('error', (err) => {
                console.error('[MongoDB] Connection error:', err);
                this.isConnected = false;
            });

            mongoose.connection.on('disconnected', () => {
                console.warn('[MongoDB] Disconnected');
                this.isConnected = false;
                this.handleReconnection(uri);
            });

            mongoose.connection.on('reconnected', () => {
                console.log('[MongoDB] Reconnected');
                this.isConnected = true;
                this.connectionRetries = 0;
            });

        } catch (error) {
            console.error('[MongoDB] Connection failed:', error.message);
            this.isConnected = false;

            if (this.connectionRetries < this.maxRetries) {
                this.connectionRetries++;
                console.log(`[MongoDB] Retrying connection (${this.connectionRetries}/${this.maxRetries}) in 5 seconds...`);
                setTimeout(() => this.connect(uri), 5000);
            } else {
                console.error('[MongoDB] Max connection retries exceeded');
                throw error;
            }
        }
    }

    async handleReconnection(uri) {
        if (this.connectionRetries < this.maxRetries && !this.isConnected) {
            this.connectionRetries++;
            setTimeout(() => this.connect(uri), 5000);
        }
    }

    async disconnect() {
        try {
            await mongoose.disconnect();
            this.isConnected = false;
            console.log('[MongoDB] Disconnected successfully');
        } catch (error) {
            console.error('[MongoDB] Error during disconnect:', error);
        }
    }

    getConnectionStatus() {
        return {
            isConnected: this.isConnected,
            readyState: mongoose.connection.readyState,
            host: mongoose.connection.host,
            port: mongoose.connection.port,
            name: mongoose.connection.name
        };
    }
}

module.exports = new MongoService();