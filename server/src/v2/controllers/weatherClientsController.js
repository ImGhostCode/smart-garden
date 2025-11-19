const db = require('../models/database');
const { createLink } = require('../utils/helpers');
const WeatherClient = require('../services/weatherClientService');
const { ApiError, ApiSuccess } = require('../utils/apiResponse');

const WeatherClientsController = {
    getAllWeatherClients: async (req, res, next) => {
        try {
            const { end_dated } = req.query;
            const filter = {};
            if (!end_dated || end_dated === 'false') {
                filter.end_date = null;
            }
            const clients = await db.weatherClientConfigs.getAll(filter);
            const response = new ApiSuccess(200,
                'Weather client configurations retrieved successfully',
                clients.map(client => {
                    return {
                        ...client.toObject(),
                        links: [
                            createLink('self', `/weather_clients/${client._id}`),
                        ]
                    }
                }),
            );
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },

    getWeatherClient: async (req, res, next) => {
        const { weatherClientID } = req.params;
        try {
            const client = await db.weatherClientConfigs.getById(weatherClientID);
            if (!client) {
                return new ApiError(404, 'Weather client configuration not found');
            }
            const response = new ApiSuccess(200, undefined, {
                ...client.toObject(),
                links: [
                    createLink('self', `/weather_clients/${client._id}`),
                ]
            });
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },

    addWeatherClient: async (req, res, next) => {
        try {
            const { type, options } = req.body;
            const clientData = { type, options };

            const newClient = await db.weatherClientConfigs.create(clientData);
            const response = new ApiSuccess(201, 'Weather client configuration created successfully', {
                ...newClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${newClient._id}`),
                ]
            });
            return res.status(201).json(response);
        } catch (error) {
            next(error);
        }
    },

    updateWeatherClient: async (req, res, next) => {
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
                throw new ApiError(404, 'Weather client configuration not found');
            }
            return res.json(new ApiSuccess(200, 'Weather client configuration updated successfully', {
                ...updatedClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${updatedClient._id}`),
                ]
            }));
        } catch (error) {
            next(error);
        }
    },

    endDateWeatherClient: async (req, res, next) => {
        const { weatherClientID } = req.params;
        try {
            const deletedClient = await db.weatherClientConfigs.deleteById(weatherClientID);
            if (!deletedClient) {
                throw new ApiError(404, 'Weather client configuration not found');
            }
            res.json(new ApiSuccess(200, 'Weather client configuration deleted successfully', {
                ...deletedClient.toObject(),
                links: [
                    createLink('self', `/weather_clients/${deletedClient._id}`),
                ],
            }));
        }
        catch (error) {
            next(error);
        }
    },
    testWeatherClient: async (req, res, next) => {
        const { weatherClientID } = req.params;
        try {
            const client = await db.weatherClientConfigs.getById(weatherClientID);
            if (!client) {
                throw new ApiError(404, 'Weather client configuration not found');
            }
            const weatherClient = new WeatherClient(client.toObject());
            const rainSinceMs = 72 * 60 * 60 * 1000; // Last 72 hours
            const totalRain = await weatherClient.getTotalRain(rainSinceMs);
            const avgHighTemperature = await weatherClient.getAverageHighTemperature(rainSinceMs);

            const response = new ApiSuccess(200, undefined, {
                rain: {
                    mm: totalRain,
                },
                temperature: {
                    celsius: avgHighTemperature,
                }
            });
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },
}

module.exports = WeatherClientsController;