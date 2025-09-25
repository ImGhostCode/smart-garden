const db = require('../models/database');
const { formatGardenResponse } = require('../utils/responseFormatters');
const mqttService = require('../services/mqttService');
const influxdbService = require('../services/influxdbService');
const e = require('express');

const GardensController = {
    getAllGardens: async (req, res) => {
        try {
            const { end_dated } = req.query;
            const filter = {};
            if (!end_dated || end_dated === 'false') {
                filter.end_date = null;
            }
            const gardens = await db.gardens.getAll(filter);

            // Get plant and zone counts for each garden
            const gardensWithCounts = await Promise.all(
                gardens.map(async (garden) => {
                    const [plantsCount, zonesCount,
                        lastContact, temHumData
                    ] = await Promise.all([
                        db.plants.getByGardenId(garden.id).then(plants =>
                            plants.filter(p => !p.end_date).length
                        ),
                        db.zones.getByGardenId(garden.id).then(zones =>
                            zones.filter(z => !z.end_date).length
                        ),
                        influxdbService.getLastContact(garden.topic_prefix).then(data => data),
                        influxdbService.getTemperatureAndHumidity(garden.topic_prefix).then(data => data)
                    ]);

                    const formattedGarden = formatGardenResponse(garden, req);
                    if (lastContact) {
                        formattedGarden.health = {
                            // Garden is considered "UP" if it's last contact was less than 5 minutes ago
                            status: (new Date() - new Date(lastContact)) < 5 * 60 * 1000 ? 'UP' : 'DOWN',
                            details: 'last contact from Garden was ' + Math.round((new Date() - new Date(lastContact)) / 60000) + ' minutes ago',
                            last_contact: lastContact
                        };
                    } else {
                        formattedGarden.health = {
                            status: 'DOWN',
                            details: 'no last contact time available',
                            last_contact: null
                        };
                    }
                    if (temHumData) {
                        formattedGarden.temperature_humidity_data = {
                            temperature_celsius: temHumData.temperature,
                            humidity_percentage: temHumData.humidity
                        };
                    }
                    formattedGarden.num_plants = plantsCount;
                    formattedGarden.num_zones = zonesCount;

                    return formattedGarden;
                })
            );

            res.json(gardensWithCounts);

        } catch (error) {
            console.error('Error getting gardens:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to retrieve gardens'
            });
        }
    },

    createGarden: async (req, res) => {
        try {
            const { name, topic_prefix, max_zones, light_schedule, controller_config } = req.body;

            if (controller_config != null && (controller_config.valvePins.length !== controller_config.pumpPins.length || controller_config.valvePins.length > max_zones)) {
                return res.status(400).json({ error: 'controller_config valvePins and pumpPins length must match and be less than or equal to max_zones' });
            }

            const newGarden = {
                name,
                topic_prefix,
                max_zones: max_zones,
                light_schedule,
                controller_config,
                end_date: null
            };

            const savedGarden = await db.gardens.create(newGarden);

            // Sent config to garden controller via MQTT
            if (controller_config) {
                try {
                    await mqttService.sendUpdateAction(savedGarden, controller_config);
                } catch (mqttError) {
                    console.error('MQTT error sending initial config:', mqttError);
                    // Proceed without failing the request
                }
            }
            // Format and return the response
            const formattedGarden = formatGardenResponse(savedGarden, req);
            formattedGarden.num_plants = 0;
            formattedGarden.num_zones = 0;

            res.status(201).json(formattedGarden);

        } catch (error) {
            console.error('Error creating garden:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to create garden'
            });
        }
    },

    getGarden: async (req, res) => {
        try {
            const { gardenID } = req.params;

            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                return res.status(404).json({ error: 'Garden not found' });
            }

            // Get plant and zone counts
            const [plantsCount, zonesCount, lastContact, temHumData] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                ),
                influxdbService.getLastContact(garden.topic_prefix).then(data => data),
                influxdbService.getTemperatureAndHumidity(garden.topic_prefix).then(data => data)
            ]);

            // Format response with HATEOAS links and counts
            const formattedGarden = formatGardenResponse(garden, req);
            if (lastContact) {
                formattedGarden.health = {
                    // Garden is considered "UP" if it's last contact was less than 5 minutes ago
                    status: (new Date() - new Date(lastContact)) < 5 * 60 * 1000 ? 'UP' : 'DOWN',
                    details: 'last contact from Garden was ' + Math.round((new Date() - new Date(lastContact)) / 60000) + ' minutes ago',
                    last_contact: lastContact
                };
            } else {
                formattedGarden.health = {
                    status: 'DOWN',
                    details: 'no last contact time available',
                    last_contact: null
                };
            }
            if (temHumData) {
                formattedGarden.temperature_humidity_data = {
                    temperature_celsius: temHumData.temperature,
                    humidity_percentage: temHumData.humidity
                };
            }
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            res.json(formattedGarden);

        } catch (error) {
            console.error('Error getting garden:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to retrieve garden'
            });
        }
    }, updateGarden: async (req, res) => {
        try {
            const { gardenID } = req.params;
            const { name, topic_prefix, max_zones, light_schedule, controller_config } = req.body;

            // Validate input fields if provided
            const updates = {};
            if (name !== undefined) {
                updates.name = name;
            }

            if (topic_prefix !== undefined) {
                updates.topic_prefix = topic_prefix;
            }

            if (max_zones !== undefined) {
                updates.max_zones = max_zones;
            }

            if (light_schedule !== undefined) {
                updates.light_schedule = light_schedule;
            }

            if (controller_config !== undefined) {
                updates.controller_config = controller_config;
            }

            if (max_zones !== undefined && controller_config !== undefined) {
                if (controller_config.valvePins.length !== controller_config.pumpPins.length) {
                    return res.status(400).json({ error: 'New controller_config valvePins and pumpPins length must match' });
                }
                if (controller_config.valvePins.length > max_zones || controller_config.pumpPins.length > max_zones) {
                    return res.status(400).json({ error: 'New controller_config valvePins and pumpPins length exceed new max_zones' });
                }
            } else if (max_zones !== undefined && controller_config === undefined) {
                const garden = await db.gardens.getById(gardenID);
                if (garden.controller_config) {
                    if (garden.controller_config.valvePins.length > max_zones || garden.controller_config.pumpPins.length > max_zones) {
                        return res.status(400).json({ error: 'Existing controller_config valvePins and pumpPins length exceed new max_zones' });
                    }
                }
            } else if (max_zones === undefined && controller_config !== undefined) {
                const garden = await db.gardens.getById(gardenID);
                if (garden) {
                    if (controller_config.valvePins.length !== controller_config.pumpPins.length) {
                        return res.status(400).json({ error: 'New controller_config valvePins and pumpPins length must match' });
                    }
                    if (controller_config.valvePins.length > garden.max_zones || controller_config.pumpPins.length > garden.max_zones) {
                        return res.status(400).json({ error: 'New controller_config valvePins and pumpPins length exceed existing max_zones' });
                    }
                }
            }

            const updatedGarden = await db.gardens.updateById(gardenID, updates);
            if (!updatedGarden) {
                return res.status(404).json({ error: 'Garden not found' });
            }

            if (controller_config)
                try {
                    await mqttService.sendUpdateAction(updatedGarden, controller_config);
                } catch (mqttError) {
                    console.error('MQTT error sending initial config:', mqttError);
                    // Proceed without failing the request
                }

            // Get plant and zone counts
            const [plantsCount, zonesCount, lastContact] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                ),
                influxdbService.getLastContact(updatedGarden.topic_prefix).then(data => data)
            ]);

            // Format response
            const formattedGarden = formatGardenResponse(updatedGarden, req);
            if (lastContact) {
                formattedGarden.health = {
                    // Garden is considered "UP" if it's last contact was less than 5 minutes ago
                    status: (new Date() - new Date(lastContact)) < 5 * 60 * 1000 ? 'UP' : 'DOWN',
                    details: 'last contact from Garden was ' + Math.round((new Date() - new Date(lastContact)) / 60000) + ' minutes ago',
                    last_contact: lastContact
                };
            } else {
                formattedGarden.health = {
                    status: 'DOWN',
                    details: 'no last contact time available',
                    last_contact: null
                };
            }
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            res.json(formattedGarden);

        } catch (error) {
            console.error('Error updating garden:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to update garden'
            });
        }
    },

    endDateGarden: async (req, res) => {
        try {
            const { gardenID } = req.params;

            // End-date the garden (soft delete)
            const endDatedGarden = await db.gardens.deleteById(gardenID);
            if (!endDatedGarden) {
                return res.status(404).json({ error: 'Garden not found' });
            }

            // Get plant and zone counts
            const [plantsCount, zonesCount, lastContact] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                ),
                influxdbService.getLastContact(endDatedGarden.topic_prefix).then(data => data)
            ]);

            // Format response
            const formattedGarden = formatGardenResponse(endDatedGarden, req);
            if (lastContact) {
                formattedGarden.health = {
                    // Garden is considered "UP" if it's last contact was less than 5 minutes ago
                    status: (new Date() - new Date(lastContact)) < 5 * 60 * 1000 ? 'UP' : 'DOWN',
                    details: 'last contact from Garden was ' + Math.round((new Date() - new Date(lastContact)) / 60000) + ' minutes ago',
                    last_contact: lastContact
                };
            } else {
                formattedGarden.health = {
                    status: 'DOWN',
                    details: 'no last contact time available',
                    last_contact: null
                };
            }
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            res.json(formattedGarden);

        } catch (error) {
            console.error('Error end-dating garden:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to end-date garden'
            });
        }
    },

    gardenAction: async (req, res) => {
        try {
            const { gardenID } = req.params;
            const { light, stop, update } = req.body;

            // Verify garden exists
            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                return res.status(404).json({ error: 'Garden not found' });
            }

            try {
                if (light) {
                    await mqttService.sendLightAction(garden, light.state, light.for_duration);
                }

                if (stop) {
                    await mqttService.sendStopAllAction(garden, stop.all);
                }

                if (update && update.config) {
                    await mqttService.sendUpdateAction(garden, update.controller_config);
                }

                res.status(202).json({
                    message: 'Action accepted and sent to garden controller'
                });

            } catch (mqttError) {
                console.error('MQTT action error:', mqttError);
                res.status(502).json({
                    error: 'Failed to communicate with garden controller',
                    message: mqttError.message
                });
            }

        } catch (error) {
            console.error('Error executing garden action:', error);
            res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to execute garden action'
            });
        }
    },
};

module.exports = GardensController;