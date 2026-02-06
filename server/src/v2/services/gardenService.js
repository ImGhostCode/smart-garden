const { ApiError } = require('../utils/apiResponse');
const influxdbClient = require('./influxdbService');

class GardenService {
    async getGardenHealth(garden) {
        try {
            const lastContact = await influxdbClient.getLastContact(garden.topic_prefix);
            if (!lastContact) {
                return {
                    status: 'DOWN',
                    details: 'no last contact time available'
                };
            }

            const now = new Date();
            const diffMs = now - new Date(lastContact);
            const diffMinutes = diffMs / (1000 * 60);
            const status = diffMinutes < 5 ? 'UP' : 'DOWN';

            return {
                status: status,
                last_contact: lastContact,
                details: `last contact from Garden was ${Math.floor(diffMinutes)} minutes ago`
            };
        } catch (error) {
            return {
                status: 'N/A',
                details: error.message
            };
        }
    }

    async executeGardenAction(garden, action) {
        if (action.light) {
            try {
                await this.executeLightAction(garden, action.light);
            } catch (error) {
                throw new ApiError(error.code, `Unable to execute LightAction: ${error.message}`);
            }
        }
        if (action.stop) {
            try {
                await this.executeStopAction(garden, action.stop);
            } catch (error) {
                throw new ApiError(error.code, `Unable to execute StopAction: ${error.message}`);
            }
        }
        if (action.update) {
            try {
                await this.executeUpdateAction(garden, action.update);
            } catch (error) {
                throw new ApiError(error.code, `Unable to execute UpdateAction: ${error.message}`);
            }
        }
    }

    async executeLightAction(garden, light) {
        const mqttService = require('./mqttService');
        await mqttService.sendLightAction(garden, light.state, null);
        if (light.for_duration_ms) {
            const cronScheduler = require('./cronScheduler');
            await cronScheduler.scheduleLightDelay(garden, light.state, light.for_duration_ms);
        }
    }

    async executeStopAction(garden, stop) {
        const mqttService = require('./mqttService');
        await mqttService.sendStopAllAction(garden, stop.all);
    }

    async executeUpdateAction(garden, update) {
        const mqttService = require('./mqttService');
        await mqttService.sendUpdateAction(garden, update.controller_config);
    }
}

module.exports = new GardenService();