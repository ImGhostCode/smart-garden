const db = require('../models/database');
const { createLink } = require('../utils/helpers');

const WeatherClientsController = {
    getAllWeatherClients: async (req, res) => {
        try {
            const { end_dated } = req.query;
            const filter = {};
            if (!end_dated || end_dated === 'false') {
                filter.end_date = null;
            }
            const clients = await db.weatherClientConfigs.getAll(filter);
            res.json({
                items: clients.map(client => {
                    return {
                        ...client.toObject(),
                        links: [
                            createLink('self', `/weather_clients/${client._id}`),
                        ]
                    }
                }),
            });
        } catch (error) {
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Failed to retrieve weather client configurations'
            });
        }
    },

    getWeatherClient: async (req, res) => {
        const { weatherClientID } = req.params;
        try {
            const client = await db.weatherClientConfigs.getById(weatherClientID);
            if (!client) {
                return res.status(404).json({
                    error: 'Weather client configuration not found'
                });
            }
            res.json({
                ...client.toObject(),
                links: [
                    createLink('self', `/weather_clients/${client._id}`),
                ]
            });
        } catch (error) {
            res.status(500).json({
                error: 'Internal Server Error',
                messsgae: 'Failed to retrieve weather client configuration'
            });
        }
    },

    addWeatherClient: async (req, res) => {
        try {
            const { type, options } = req.body;
            const clientData = { type, options };

            const newClient = await db.weatherClientConfigs.create(clientData);
            res.status(201).json({
                ...newClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${newClient._id}`),
                ]
            });
        } catch (error) {
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Failed to create weather client configuration'
            });
        }
    },

    updateWeatherClient: async (req, res) => {
        const { weatherClientID } = req.params;
        const {
            type, options
        } = req.body;

        const updates = {};
        if (type !== undefined) updates.type = type;
        if (type === "netatmo" && options !== undefined) {
            if (options.station_id !== undefined) updates['options.station_id'] = options.station_id;
            if (options.station_name !== undefined) updates['options.station_name'] = options.station_name;
            if (options.rain_module_id !== undefined) updates['options.rain_module_id'] = options.rain_module_id;
            if (options.rain_module_type !== undefined) updates['options.rain_module_type'] = options.rain_module_type;
            if (options.outdoor_module_id !== undefined) updates['options.outdoor_module_id'] = options.outdoor_module_id;
            if (options.outdoor_module_type !== undefined) updates['options.outdoor_module_type'] = options.outdoor_module_type;
            if (options.authentication !== undefined) {
                if (options.authentication.access_token !== undefined) updates['options.authentication.access_token'] = options.authentication.access_token;
                if (options.authentication.refresh_token !== undefined) updates['options.authentication.refresh_token'] = options.authentication.refresh_token;
                if (options.authentication.expiration_date !== undefined) updates['options.authentication.expiration_date'] = options.authentication.expiration_date;
            };
            if (options.client_id !== undefined) updates['options.client_id'] = options.client_id;
            if (options.client_secret !== undefined) updates['options.client_secret'] = options.client_secret;
        } else if (type === "fake" && options !== undefined) {
            if (options.rain_mm !== undefined) updates['options.rain_mm'] = options.rain_mm;
            if (options.rain_interval !== undefined) updates['options.rain_interval'] = options.rain_interval;
            if (options.avg_high_temperature !== undefined) updates['options.avg_high_temperature'] = options.avg_high_temperature;
            if (options.error !== undefined) updates['options.error'] = options.error;
        }

        try {
            const updatedClient = await db.weatherClientConfigs.updateById(weatherClientID, updates);
            if (!updatedClient) {
                return res.status(404).json({
                    error: 'Weather client configuration not found'
                });
            }
            res.json({
                ...updatedClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${updatedClient._id}`),
                ]
            });
        } catch (error) {
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Failed to update weather client configuration'
            });
        }
    },

    endDateWeatherClient: async (req, res) => {
        const { weatherClientID } = req.params;
        try {
            const deletedClient = await db.weatherClientConfigs.deleteById(weatherClientID);
            if (!deletedClient) {
                return res.status(404).json({
                    error: 'Weather client configuration not found'
                });
            }
            res.json({
                ...deletedClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${deletedClient._id}`),
                ],
            });
        }
        catch (error) {
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Failed to delete weather client configuration'
            });
        }
    }
}

module.exports = WeatherClientsController;