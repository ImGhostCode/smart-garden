const mqtt = require('mqtt');
const EventEmitter = require('events');
const db = require('../models/database');
const { generateXid } = require('../utils/helpers');
const influxDBService = require('./influxdbService');

class MQTTService extends EventEmitter {
    constructor() {
        super();
        this.client = null;
        this.isConnected = false;
        this.subscribedTopics = new Set();

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
            // this.subscribeToDataTopics();
            this.subscribe(`+${this.TOPICS.DATA.HEALTH}`);
            this.subscribe(`+${this.TOPICS.DATA.TEMPERATURE}`);
            this.subscribe(`+${this.TOPICS.DATA.HUMIDITY}`);
            this.subscribe(`+${this.TOPICS.DATA.WATER}`);
            this.subscribe(`+${this.TOPICS.DATA.LIGHT}`);
            this.subscribe(`+${this.TOPICS.DATA.LOGGING}`);
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
    async handleIncomingMessage(topic, message) {
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
            const garden = await db.gardens.getAll({ topic_prefix: gardenPrefix, end_date: null });
            if (!garden || garden.length === 0) {
                console.warn(`Garden not found for topic prefix: ${gardenPrefix}`);
                return;
            }

            // Handle different data types
            this.processDataMessage(garden[0], dataType, messageStr);

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
    async handleHealthData(garden, message, timestamp) {
        try {
            // Update garden health in database

            await influxDBService.writeHealthData(garden.topic_prefix);

            // Emit event for real-time updates
            this.emit('healthUpdate', garden.id, message);

        } catch (error) {
            console.error('Error handling health data:', error);
        }
    }

    // Handle temperature data. Example message: "temperature value=23.5"
    async handleTemperatureData(garden, message, timestamp) {
        try {
            console.log('Temperature message:', message);
            const temperatureString = message.split('value=')[1];
            const temperature = parseFloat(temperatureString);
            if (!temperatureString || isNaN(temperature)) {
                console.warn('Invalid temperature data:', message);
                return;
            }
            await influxDBService.writeTemperatureData(garden.topic_prefix, temperature);
            this.emit('temperatureUpdate', garden.id, temperature);

        } catch (error) {
            console.error('Error parsing temperature data:', error);
        }
    }

    // Handle humidity data. Example message: "humidity value=55.2"
    async handleHumidityData(garden, message, timestamp) {
        try {
            console.log('Humidity message:', message);
            const humidityString = message.split('value=')[1];
            const humidity = parseFloat(humidityString);
            if (!humidityString || isNaN(humidity)) {
                console.warn('Invalid humidity data:', message);
                return;
            }
            await influxDBService.writeHumidityData(garden.topic_prefix, humidity);
            this.emit('humidityUpdate', garden.id, humidity);

        } catch (error) {
            console.error('Error parsing humidity data:', error);
        }
    }

    // Handle water event data. Example message: water,status=complete,zone=1,id=1,zone_id=1 millis=60000
    async handleWaterData(garden, message, timestamp) {
        try {
            console.log('Water message:', message);
            const status = message.split('status=')[1].split(',')[0];
            const zoneString = message.split('zone=')[1].split(',')[0];
            const zone = parseInt(zoneString);
            const id = message.split('id=')[1].split(',')[0];
            const zoneId = message.split('zone_id=')[1].split(' ')[0];
            const millisString = message.split('millis=')[1];
            const duration = parseInt(millisString);

            if (!status || isNaN(zone) || !id || isNaN(duration)) {
                console.warn('Invalid water data:', message);
                return;
            }
            await influxDBService.writeWaterData(garden.topic_prefix, status, zone, id, zoneId, duration);
            this.emit('waterEvent', garden.id, { status, zone, id, zoneId, duration });

        } catch (error) {
            console.error('Error parsing water data:', error);
        }
    }

    // Handle light data. Example message: {"state":"ON"} or {"state":"OFF"} or {"state":""}
    async handleLightData(garden, message, timestamp) {
        try {
            console.log('Light message:', message);
            const data = JSON.parse(message);
            const state = data.state; // "ON", "OFF", or ""

            await influxDBService.writeLightData(garden.topic_prefix, state);
            this.emit('lightUpdate', garden.id, state || 'TOGGLE');
        } catch (error) {
            console.error('Error parsing light data:', error);
        }
    }

    // Handle logs from ESP32. Example message: "logs message=\"garden-controller setup complete\"""
    async handleLogsData(garden, message, timestamp) {
        try {
            console.log('Logs message:', message);
            const logMessage = message.split('message=')[1].replace(/^"|"$/g, '');
            if (!logMessage) {
                console.warn('Invalid logs data:', message);
                return;
            }
            await influxDBService.writeLogData(garden.topic_prefix, logMessage);
            this.emit('logEvent', garden.id, logMessage);
        } catch (error) {
            console.error('Error parsing logs data:', error);
        }
    }

    // Command methods to send to ESP32

    // Send water command and log to InfluxDB
    async sendWaterCommand(garden, zoneId, zonePosition, duration, source) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.WATER}`;
        const eventId = generateXid();
        const command = {
            "duration": duration,
            "zone_id": zoneId,
            "position": zonePosition,
            "event_id": eventId,
            "source": source
        };
        // Write command to InfluxDB
        await influxDBService.writeWaterCommand(garden.topic_prefix, duration, eventId, zoneId, zonePosition, source);

        await this.publish(topic, command);
        return eventId;
    }

    // Send stop all command
    async sendStopAllAction(garden, all = false) {
        const topic = all ? `${garden.topic_prefix}${this.TOPICS.COMMANDS.STOP_ALL}` : `${garden.topic_prefix}${this.TOPICS.COMMANDS.STOP}`;
        await this.publish(topic, "no message");
    }

    // Send light command
    async sendLightAction(garden, state = "", forDuration = 0) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.LIGHT}`;
        const command = {
            "state": state, // "ON" or "OFF" or ""
            "for_duration": forDuration
        };

        await this.publish(topic, command);
    }

    // Send configuration update to ESP32
    async sendUpdateAction(garden, config) {
        const topic = `${garden.topic_prefix}${this.TOPICS.COMMANDS.UPDATE_CONFIG}`;
        const command = {
            "num_zones": config.valvePins.length,
            "valve_pins": config.valvePins,
            "pump_pins": config.pumpPins,
            "light": config.lightPin !== undefined,
            "light_pin": config.lightPin,
            "temp_humidity": config.tempHumidityPin !== undefined,
            "temp_humidity_pin": config.tempHumidityPin,
            "temp_humidity_interval": config.tempHumidityInterval
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