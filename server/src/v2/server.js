const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Import MQTT service
const mqttService = require('./services/mqttService');
const influxdbService = require('./services/influxdbService');

// Import database
const db = require('./models/database');

// Import routes
const gardenRoutes = require('./routes/gardens');
const plantRoutes = require('./routes/plants');
const zoneRoutes = require('./routes/zones');
const waterScheduleRoutes = require('./routes/waterSchedules');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
if (process.env.NODE_ENV !== 'production') {
    app.use((req, res, next) => {
        console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
        next();
    });
}

// Initialize MQTT connection
const initializeMQTT = () => {
    const brokerUrl = process.env.MQTT_BROKER_URL || 'mqtt://localhost:1883';
    const mqttOptions = {
        host: brokerUrl,
        port: process.env.MQTT_PORT || 1883,
        protocol: 'mqtts',
        // ca: process.env.MQTT_BROKER_CA,
        rejectUnauthorized: true,
        clientId: process.env.MQTT_CLIENT_ID || `garden-server-${Date.now()}`,
        username: process.env.MQTT_USERNAME || '',
        password: process.env.MQTT_PASSWORD || '',
        reconnectPeriod: parseInt(process.env.MQTT_RECONNECT_PERIOD) || 1000,
        connectTimeout: parseInt(process.env.MQTT_CONNECT_TIMEOUT) || 4000,
        clean: true,
    };

    mqttService.connect(brokerUrl, mqttOptions);

    // Setup MQTT event listeners
    mqttService.on('connected', () => {
        console.log('✓ MQTT service connected successfully');
    });

    mqttService.on('error', (error) => {
        console.error('✗ MQTT connection error:', error.message);
    });

    mqttService.on('disconnected', () => {
        console.warn('⚠ MQTT service disconnected');
    });

    // Log real-time data from ESP32
    mqttService.on('healthUpdate', (gardenId, healthData) => {
        console.log(`[${gardenId}] Health update:`, healthData);
    });

    mqttService.on('temperatureUpdate', (gardenId, temperature) => {
        console.log(`[${gardenId}] Temperature: ${temperature}°C`);
    });

    mqttService.on('humidityUpdate', (gardenId, humidity) => {
        console.log(`[${gardenId}] Humidity: ${humidity}%`);
    });

    mqttService.on('waterEvent', (zoneId, waterData) => {
        console.log(`[${zoneId}] Water event:`, waterData);
    });

    mqttService.on('lightUpdate', (gardenId, lightData) => {
        console.log(`[${gardenId}] Light update:`, lightData);
    });

    mqttService.on('logEvent', (gardenId, logMessage) => {
        console.log(`[ESP32-${gardenId}]`, logMessage);
    });
};

// Initialize MongoDB connection
const initializeMongoDB = async () => {
    try {
        const mongoUri = process.env.MONGODB_URI || 'mongodb://root:password@localhost:27017/smartgarden?authSource=admin';
        console.log('Initializing MongoDB connection...');
        await db.connect(mongoUri);
        console.log('✅ MongoDB connected successfully');
    } catch (error) {
        console.error('❌ MongoDB connection failed:', error.message);
        // Don't exit the process, let the retry mechanism in mongoService handle it
    }
};

// Initialize Influxdb connection
const initializeInfluxDB = async () => {
    try {
        influxdbService.connect({
            url: process.env.INFLUXDB_URL,
            token: process.env.INFLUXDB_TOKEN,
            org: process.env.INFLUXDB_ORG,
            bucket: process.env.INFLUXDB_BUCKET || 'garden'
        });
        console.log('✅ InfluxDB connected successfully');
    } catch (error) {
        console.error('❌ InfluxDB connection failed:', error.message);
        // Don't exit the process, let the retry mechanism in mongoService handle it
    }
};


// Routes
app.use('/gardens', gardenRoutes);
app.use('/gardens', plantRoutes);
app.use('/gardens', zoneRoutes);
app.use('/water_schedules', waterScheduleRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        mqtt_status: mqttService.getConnectionStatus(),
        database_status: db.getConnectionStatus()
    });
});

// MQTT status endpoint
app.get('/mqtt/status', (req, res) => {
    res.json({
        mqtt_status: mqttService.getConnectionStatus(),
        broker_url: process.env.MQTT_BROKER_URL || 'mqtt://localhost:1883'
    });
});

// MQTT reconnect endpoint (for debugging)
app.post('/mqtt/reconnect', (req, res) => {
    try {
        mqttService.disconnect();
        setTimeout(() => {
            initializeMQTT();
        }, 1000);

        res.json({
            message: 'MQTT reconnection initiated'
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to reconnect MQTT',
            details: error.message
        });
    }
});


// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: err.message
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not found',
        message: `Route ${req.method} ${req.path} not found`
    });
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down server...');

    mqttService.disconnect();
    await db.disconnect();
    await influxdbService.close();

    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('🛑 SIGTERM received, shutting down gracefully...');

    mqttService.disconnect();
    await db.disconnect();
    await influxdbService.close();

    process.exit(0);
});

// Start server
app.listen(PORT, async () => {
    console.log(`🚀 Garden App Server is running on port ${PORT}`);
    console.log(`📍 Health check: http://localhost:${PORT}/health`);
    console.log(`📍 MQTT status: http://localhost:${PORT}/mqtt/status`);

    // Initialize MongoDB first
    await initializeMongoDB();
    await initializeInfluxDB();

    // Initialize MQTT after MongoDB and server starts
    setTimeout(() => {
        initializeMQTT();
    }, 1000);

    console.log(`Garden App Server is running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log('\nAvailable endpoints:');
    console.log('Gardens:');
    console.log('  GET    /gardens');
    console.log('  POST   /gardens');
    console.log('  GET    /gardens/:gardenID');
    console.log('  PATCH  /gardens/:gardenID');
    console.log('  DELETE /gardens/:gardenID');
    console.log('  POST   /gardens/:gardenID/action');
    console.log('\nPlants:');
    console.log('  GET    /gardens/:gardenID/plants');
    console.log('  POST   /gardens/:gardenID/plants');
    console.log('  GET    /gardens/:gardenID/plants/:plantID');
    console.log('  PATCH  /gardens/:gardenID/plants/:plantID');
    console.log('  DELETE /gardens/:gardenID/plants/:plantID');
    console.log('\nZones:');
    console.log('  GET    /gardens/:gardenID/zones');
    console.log('  POST   /gardens/:gardenID/zones');
    console.log('  GET    /gardens/:gardenID/zones/:zoneID');
    console.log('  PATCH  /gardens/:gardenID/zones/:zoneID');
    console.log('  DELETE /gardens/:gardenID/zones/:zoneID');
    console.log('  POST   /gardens/:gardenID/zones/:zoneID/action');
    console.log('  GET    /gardens/:gardenID/zones/:zoneID/history');
    console.log('\nWater Schedules:');
    console.log('  GET    /water_schedules');
    console.log('  POST   /water_schedules');
    console.log('  GET    /water_schedules/:waterScheduleID');
    console.log('  PATCH  /water_schedules/:waterScheduleID');
    console.log('  DELETE /water_schedules/:waterScheduleID');
});

module.exports = app;