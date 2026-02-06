const express = require('express');
const cors = require('cors');
require('dotenv').config();
const errorHandler = require('./middlewares/errorHandler');
const client = require('prom-client');

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
const schedulerRoutes = require('./routes/scheduler');
const weatherClientsRoutes = require('./routes/weatherClients');
const waterRoutineRoutes = require('./routes/waterRoutine');
const notificationClientRoutes = require('./routes/notificationClients');

const app = express();
const PORT = process.env.PORT || 3000;
const register = new client.Registry();

// Collect default metrics (CPU, memory usage, etc.)
client.collectDefaultMetrics({ register });

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
        protocol: process.env.MQTT_PROTOCOL || 'mqtt',
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
app.use('/scheduler', schedulerRoutes);
app.use('/weather_clients', weatherClientsRoutes);
app.use('/water_routines', waterRoutineRoutes);
app.use('/notification_clients', notificationClientRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    try {
        const cronScheduler = require('./services/cronScheduler');
        const activeJobs = cronScheduler.getActiveJobs();

        res.status(200).json({
            code: 200,
            status: 'success',
            message: 'Server is healthy',
            data: {
                timestamp: new Date().toISOString(),
                uptime: process.uptime(),
                mqtt_status: mqttService.getConnectionStatus(),
                database_status: db.getConnectionStatus(),
                scheduler_status: {
                    active: true,
                    active_jobs_count: activeJobs.length,
                    next_execution: activeJobs.length > 0 ? activeJobs[0].next_execution : null
                }
            },
            meta: {
                timestamp: new Date().toISOString(),
                request_id: req.headers['x-request-id'] || 'N/A'
            },
        });
    } catch (error) {
        res.json({
            code: 500,
            status: 'error',
            message: 'Server health check failed',
            data: {
                timestamp: new Date().toISOString(),
                uptime: process.uptime(),
                mqtt_status: mqttService.getConnectionStatus(),
                database_status: db.getConnectionStatus(),
                scheduler_status: {
                    active: false,
                    error: error.message
                }
            },
            meta: {
                timestamp: new Date().toISOString(),
                request_id: req.headers['x-request-id'] || 'N/A'
            },
        });
    }
});

// MQTT status endpoint
app.get('/mqtt/status', (req, res) => {
    res.status(200).json({
        code: 200,
        status: 'success',
        message: 'MQTT connection status retrieved successfully',
        data: {
            mqtt_status: mqttService.getConnectionStatus(),
            broker_url: process.env.MQTT_BROKER_URL || 'mqtt://localhost:1883'
        }, meta: {
            timestamp: new Date().toISOString(),
            request_id: req.headers['x-request-id'] || 'N/A'
        },
    });
});

// MQTT reconnect endpoint (for debugging)
app.post('/mqtt/reconnect', (req, res) => {
    try {
        mqttService.disconnect();
        setTimeout(() => {
            initializeMQTT();
        }, 1000);

        res.status(200).json({
            code: 200,
            status: 'success',
            message: 'MQTT reconnection initiated'
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            status: 'error',
            message: 'Failed to initiate MQTT reconnection',
        });
    }
});

// Metrics endpoint for Prometheus to scrape
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});


// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        status: 'error',
        code: 404,
        message: `Route ${req.method} ${req.path} not found`,
        errors: [],
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

    // Initialize Cron Scheduler after database is ready
    setTimeout(async () => {
        const cronScheduler = require('./services/cronScheduler');
        const success = await cronScheduler.initialize();
        if (success) {
            console.log('✓ Cron scheduler initialized successfully');
        } else {
            console.error('✗ Failed to initialize cron scheduler');
        }
    }, 2000);

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
    console.log('  GET    /water_schedules/:waterScheduleID/preview');
    console.log('  POST   /water_schedules/:waterScheduleID/execute');
    console.log('\nScheduler:');
    console.log('  GET    /scheduler');
    console.log('  POST   /scheduler/initialize');
    console.log('  POST   /scheduler/stop');
    console.log('  POST   /scheduler/water_schedules/:id/schedule');
    console.log('  DELETE /scheduler/water_schedules/:id/schedule');
    console.log('  PUT    /scheduler/water_schedules/:id/schedule');
    console.log('  POST   /scheduler/water_schedules/:id/trigger');
    console.log('Weather Clients:');
    console.log('  GET    /weather_clients');
    console.log('  POST   /weather_clients');
    console.log('  GET    /weather_clients/:weatherClientID');
    console.log('  PATCH  /weather_clients/:weatherClientID');
    console.log('  DELETE /weather_clients/:weatherClientID');
    console.log('Notification Clients:');
    console.log('  GET    /notification_clients');
    console.log('  POST   /notification_clients');
    console.log('  GET    /notification_clients/:notificationClientID');
    console.log('  PATCH  /notification_clients/:notificationClientID');
    console.log('  DELETE /notification_clients/:notificationClientID');
    console.log('Water Routines:');
    console.log('  GET    /water_routines');
    console.log('  POST   /water_routines');
    console.log('  GET    /water_routines/:waterRoutineID');
    console.log('  PATCH  /water_routines/:waterRoutineID');
    console.log('  DELETE /water_routines/:waterRoutineID');
    console.log('  POST   /water_routines/:waterRoutineID/run');
});

module.exports = app;