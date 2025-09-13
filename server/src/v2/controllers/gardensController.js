const db = require('../models/database');
const { formatGardenResponse } = require('../utils/responseFormatters');
const mqttService = require('../services/mqttService');

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
                    const [plantsCount, zonesCount] = await Promise.all([
                        db.plants.getByGardenId(garden.id).then(plants =>
                            plants.filter(p => !p.end_date).length
                        ),
                        db.zones.getByGardenId(garden.id).then(zones =>
                            zones.filter(z => !z.end_date).length
                        )
                    ]);

                    const formattedGarden = formatGardenResponse(garden, req);
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

            if (controller_config != null && (controller_config.valvePins.length !== max_zones || controller_config.pumpPins.length !== max_zones)) {
                return res.status(400).json({ error: 'controller_config valvePins and pumpPins length must match max_zones' });
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
            const [plantsCount, zonesCount] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                )
            ]);

            // Format response with HATEOAS links and counts
            const formattedGarden = formatGardenResponse(garden, req);
            formattedGarden.num_plants = plantsCount;
            formattedGarden.num_zones = zonesCount;

            // Add health information
            formattedGarden.health = garden.health || {
                status: 'N/A',
                details: 'Waiting for ESP32 connection',
                last_contact: null
            };
            formattedGarden.temperature_humidity_data = {
                temperature_celsius: null,
                humidity_percentage: null
            };

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

            if (controller_config != undefined && (controller_config.valvePins.length !== max_zones || controller_config.pumpPins.length !== max_zones)) {
                return res.status(400).json({ error: 'controller_config valvePins and pumpPins length must match max_zones' });
            }

            if (controller_config !== undefined) {
                updates.controller_config = controller_config;
            }

            const updatedGarden = await db.gardens.updateById(gardenID, updates);
            if (!updatedGarden) {
                return res.status(404).json({ error: 'Garden not found' });
            }

            // Get plant and zone counts
            const [plantsCount, zonesCount] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                )
            ]);

            // Format response
            const formattedGarden = formatGardenResponse(updatedGarden, req);
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
            const [plantsCount, zonesCount] = await Promise.all([
                db.plants.getByGardenId(gardenID).then(plants =>
                    plants.filter(p => !p.end_date).length
                ),
                db.zones.getByGardenId(gardenID).then(zones =>
                    zones.filter(z => !z.end_date).length
                )
            ]);

            // Format response
            const formattedGarden = formatGardenResponse(endDatedGarden, req);
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
                    await mqttService.sendLightAction(garden, light.state);
                }

                if (stop && stop.all) {
                    await mqttService.sendStopAllAction(garden);
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