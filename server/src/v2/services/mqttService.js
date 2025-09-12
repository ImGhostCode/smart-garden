const mqtt = require('mqtt');
const EventEmitter = require('events');
const db = require('../models/database');
const { generateXid } = require('../utils/helpers');
const InfluxDBService = require('./influxdbService');

class MQTTService extends EventEmitter {
    constructor() {
        super();
        this.client = null;
        this.isConnected = false;
        this.subscribedTopics = new Set();
        this.influxDB = null;

        // Initialize InfluxDB if configured
        if (process.env.INFLUXDB_URL) {
            this.influxDB = new InfluxDBService({
                url: process.env.INFLUXDB_URL,
                token: process.env.INFLUXDB_TOKEN,
                org: process.env.INFLUXDB_ORG,
                bucket: process.env.INFLUXDB_BUCKET || 'garden'
            });
        }

        // MQTT Topics constants
        this.TOPICS = {
            COMMANDS: {
                WATER: '/command/water',
                STOP: '/command/stop',
                STOP_ALL: '/command/stop_all',
                LIGHT: '/command/light',
                UPDATE_CONFIG: '/command/update_config'
            },
            DATA: {
                LIGHT: '/data/light',
                WATER: '/data/water',
                LOGGING: '/data/logs',
                HEALTH: '/data/health',
                TEMPERATURE: '/data/temperature',
                HUMIDITY: '/data/humidity'
            }
        };
    }

    // Connect to MQTT broker
    connect(brokerUrl = 'mqtt://localhost:1883', options = {}) {
        const defaultOptions = {
            // clientId: `garden-server-${Date.now()}`,
            // clean: true,
            connectTimeout: 4000,
            username: process.env.MQTT_USERNAME || '',
            password: process.env.MQTT_PASSWORD || '',
            reconnectPeriod: 1000
        };

        const mqttOptions = { ...defaultOptions, ...options };

        console.log(`Connecting to MQTT broker: ${brokerUrl}`);

        this.client = mqtt.connect(brokerUrl, mqttOptions);

        this.client.on('connect', () => {
            console.log('Connected to MQTT broker');
            this.isConnected = true;
            this.subscribeToDataTopics();
            this.emit('connected');
        });

        this.client.on('message', (topic, message) => {
            this.handleIncomingMessage(topic, message);
        });

        this.client.on('error', (error) => {
            console.error('MQTT connection error:', error);
            this.emit('error', error);
        });

        this.client.on('close', () => {
            console.log('MQTT connection closed');
            this.isConnected = false;
            this.emit('disconnected');
        });

        this.client.on('reconnect', () => {
            console.log('MQTT reconnecting...');
        });

        return this;
    }

    // Subscribe to all data topics for all gardens
    subscribeToDataTopics() {
        if (!this.isConnected) return;

        const gardens = Array.from(db.gardens.values());

        gardens.forEach(garden => {
            const topicPrefix = garden.topic_prefix;

            // Subscribe to all data topics for this garden
            Object.values(this.TOPICS.DATA).forEach(dataTopic => {
                const fullTopic = `${topicPrefix}${dataTopic}`;
                this.subscribe(fullTopic);
            });
        });
    }

    // Subscribe to a specific topic
    subscribe(topic) {
        if (!this.isConnected) {
            console.warn('Cannot subscribe - MQTT not connected');
            return;
        }

        if (this.subscribedTopics.has(topic)) {
            return; // Already subscribed
        }

        this.client.subscribe(topic, (err) => {
            if (err) {
                console.error(`Failed to subscribe to ${topic}:`, err);
            } else {
                console.log(`Subscribed to: ${topic}`);
                this.subscribedTopics.add(topic);
            }
        });
    }

    // Unsubscribe from a topic
    unsubscribe(topic) {
        if (!this.isConnected) return;

        this.client.unsubscribe(topic, (err) => {
            if (err) {
                console.error(`Failed to unsubscribe from ${topic}:`, err);
            } else {
                console.log(`Unsubscribed from: ${topic}`);
                this.subscribedTopics.delete(topic);
            }
        });
    }

    // Publish message to a topic
    publish(topic, message, options = {}) {
        if (!this.isConnected) {
            console.warn('Cannot publish - MQTT not connected');
            return Promise.reject(new Error('MQTT not connected'));
        }

        const payload = typeof message === 'object' ? JSON.stringify(message) : message.toString();

        return new Promise((resolve, reject) => {
            this.client.publish(topic, payload, options, (err) => {
                if (err) {
                    console.error(`Failed to publish to ${topic}:`, err);
                    reject(err);
                } else {
                    console.log(`Published to ${topic}:`, payload);
                    resolve();
                }
            });
        });
    }

    // Handle incoming messages from ESP32
    handleIncomingMessage(topic, message) {
        try {
            const messageStr = message.toString();
            console.log(`Received message on ${topic}:`, messageStr);

            // Parse topic to extract garden prefix and data type
            const { gardenPrefix, dataType } = this.parseDataTopic(topic);

            if (!gardenPrefix || !dataType) {
                console.warn(`Cannot parse topic: ${topic}`);
                return;
            }

            // Find garden by topic prefix
            const garden = Array.from(db.gardens.values()).find(g => g.topic_prefix === gardenPrefix);
            if (!garden) {
                console.warn(`Garden not found for topic prefix: ${gardenPrefix}`);
                return;
            }

            // Handle different data types
            this.processDataMessage(garden, dataType, messageStr);

        } catch (error) {
            console.error('Error handling MQTT message:', error);
        }
    }

    // Parse data topic to extract garden prefix and data type
    parseDataTopic(topic) {
        // Topic format: "garden_prefix/data/type"
        const parts = topic.split('/');
        if (parts.length < 3) return { gardenPrefix: null, dataType: null };

        const gardenPrefix = parts[0];
        const dataType = parts[2]; // Skip '/data/' part

        return { gardenPrefix, dataType };
    }

    // Process different types of data messages
    processDataMessage(garden, dataType, message) {
        const timestamp = new Date().toISOString();

        switch (dataType) {
            case 'health':
                this.handleHealthData(garden, message, timestamp);
                break;
            case 'temperature':
                this.handleTemperatureData(garden, message, timestamp);
                break;
            case 'humidity':
                this.handleHumidityData(garden, message, timestamp);
                break;
            case 'water':
                this.handleWaterData(garden, message, timestamp);
                break;
            case 'light':
                this.handleLightData(garden, message, timestamp);
                break;
            case 'logs':
                this.handleLogsData(garden, message, timestamp);
                break;
            default:
                console.log(`Unknown data type: ${dataType}`);
        }
    }

    // Handle health status from ESP32
    handleHealthData(garden, message, timestamp) {
        try {
            // Write to InfluxDB
            // if (this.influxDB) {
            //     this.influxDB.writeHealthData(garden.topic_prefix);
            // }

            // Update garden health in database
            const updatedGarden = {
                ...garden,
                last_health_update: timestamp,
                health_status: {
                    status: 'UP',
                    details: message || 'Garden controller responding',
                    last_contact: timestamp,
                    // ...healthData
                }
            };

            db.gardens.set(garden.id, updatedGarden);

            // Emit event for real-time updates
            this.emit('healthUpdate', garden.id, message);

        } catch (error) {
            console.error('Error parsing health data:', error);
        }
    }

    // Handle temperature data
    handleTemperatureData(garden, message, timestamp) {
        try {
            const temperature = parseFloat(message);

            // Write to InfluxDB
            if (this.influxDB) {
                this.influxDB.writeTemperatureData(garden.topic_prefix, temperature);
            }

            const updatedGarden = {
                ...garden,
                temperature_data: {
                    celsius: temperature,
                    timestamp: timestamp
                }
            };

            db.gardens.set(garden.id, updatedGarden);
            this.emit('temperatureUpdate', garden.id, temperature);

        } catch (error) {
            console.error('Error parsing temperature data:', error);
        }
    }

    // Handle humidity data
    handleHumidityData(garden, message, timestamp) {
        try {
            const humidity = parseFloat(message);

            // Write to InfluxDB
            if (this.influxDB) {
                this.influxDB.writeHumidityData(garden.topic_prefix, humidity);
            }

            const updatedGarden = {
                ...garden,
                humidity_data: {
                    percentage: humidity,
                    timestamp: timestamp
                }
            };

            db.gardens.set(garden.id, updatedGarden);
            this.emit('humidityUpdate', garden.id, humidity);

        } catch (error) {
            console.error('Error parsing humidity data:', error);
        }
    }

    // Handle water event data
    handleWaterData(garden, message, timestamp) {
        try {
            const waterData = JSON.parse(message);

            // Record watering history
            if (waterData.zone_position !== undefined) {
                // Find zone by position
                const zone = Array.from(db.zones.values())
                    .find(z => z.garden_id === garden.id && z.position === waterData.zone_position);

                if (zone) {
                    const eventId = waterData.id || generateXid();
                    // Write to InfluxDB
                    if (this.influxDB) {
                        this.influxDB.writeWaterEvent(
                            garden.topic_prefix,
                            zone.position,
                            waterData.duration || '0ms',
                            eventId,
                            waterData.status || 'complete'
                        );
                    }

                    if (!db.waterHistory.has(zone.id)) {
                        db.waterHistory.set(zone.id, []);
                    }

                    const historyRecord = {
                        id: generateXid(),
                        zone_id: zone.id,
                        duration: waterData.duration || '0ms',
                        record_time: timestamp,
                        status: waterData.status || 'completed',
                        esp32_data: waterData
                    };

                    db.waterHistory.get(zone.id).push(historyRecord);
                    this.emit('waterEvent', zone.id, waterData);
                }
            }

        } catch (error) {
            console.error('Error parsing water data:', error);
        }
    }

    // Handle light data
    handleLightData(garden, message, timestamp) {
        try {
            const lightData = JSON.parse(message);

            const updatedGarden = {
                ...garden,
                light_status: {
                    ...lightData,
                    timestamp: timestamp
                }
            };

            db.gardens.set(garden.id, updatedGarden);
            this.emit('lightUpdate', garden.id, lightData);

        } catch (error) {
            console.error('Error parsing light data:', error);
        }
    }

    // Handle logs from ESP32
    handleLogsData(garden, message, timestamp) {
        console.log(`[${garden.name}] ESP32 Log:`, message);
        this.emit('esp32Log', garden.id, message);
    }

    // Command methods to send to ESP32

    // Send water command and log to InfluxDB
    async sendWaterCommand(garden, zonePosition, duration) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.WATER}`;
        const eventId = generateXid();
        const command = {
            zone: zonePosition,
            duration: duration,
            id: eventId,
            timestamp: new Date().toISOString()
        };

        // Write command to InfluxDB
        if (this.influxDB) {
            this.influxDB.writeWaterCommand(
                garden.topic_prefix,
                zonePosition,
                duration,
                eventId,
                'api'
            );
        }

        await this.publish(topic, command);
        return eventId;
    }

    // Send stop command to specific zone
    async sendStopCommand(garden, zonePosition) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.STOP}`;
        const command = {
            zone: zonePosition,
            timestamp: new Date().toISOString()
        };

        await this.publish(topic, command);
    }

    // Send stop all command
    async sendStopAllCommand(garden) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.STOP_ALL}`;
        const command = {
            timestamp: new Date().toISOString()
        };

        await this.publish(topic, command);
    }

    // Send light command
    async sendLightCommand(garden, state, duration = null) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.LIGHT}`;
        const command = {
            state: state, // "true", "false", or ""
            timestamp: new Date().toISOString()
        };

        if (duration) {
            command.for_duration = duration;
        }

        await this.publish(topic, command);
    }

    // Send configuration update to ESP32
    async sendConfigUpdate(garden, config) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.UPDATE_CONFIG}`;
        const command = {
            ...config,
            timestamp: new Date().toISOString()
        };

        await this.publish(topic, command);
    }

    // Subscribe to data topics when new garden is created
    subscribeToGarden(garden) {
        const topicPrefix = garden.topic_prefix;

        Object.values(this.TOPICS.DATA).forEach(dataTopic => {
            const fullTopic = `${topicPrefix}${dataTopic}`;
            this.subscribe(fullTopic);
        });
    }

    // Unsubscribe from garden topics when garden is deleted
    unsubscribeFromGarden(garden) {
        const topicPrefix = garden.topic_prefix;

        Object.values(this.TOPICS.DATA).forEach(dataTopic => {
            const fullTopic = `${topicPrefix}${dataTopic}`;
            this.unsubscribe(fullTopic);
        });
    }

    // Disconnect from MQTT broker
    disconnect() {
        if (this.client) {
            this.client.end();
            this.isConnected = false;
            console.log('MQTT client disconnected');
        }
        if (this.influxDB) {
            this.influxDB.close();
            console.log('InfluxDB client closed');
        }
    }

    // Get connection status
    getConnectionStatus() {
        return {
            connected: this.isConnected,
            subscribedTopics: Array.from(this.subscribedTopics)
        };
    }
}

// Create singleton instance
const mqttService = new MQTTService();

module.exports = mqttService;