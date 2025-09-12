const db = require('../models/database');
const { validateXid, addTimestamps, createLink } = require('../utils/helpers');
const mqttService = require('../services/mqttService');

const GardensController = {
    getAllGardens: (req, res) => {
        const { end_dated } = req.query;
        const gardens = Array.from(db.gardens.values());

        let filteredGardens = gardens;
        if (!end_dated || end_dated === 'false') {
            filteredGardens = gardens.filter(garden => !garden.end_date);
        }

        res.json({
            items: filteredGardens.map(garden => ({
                ...garden,
                links: [
                    createLink('self', `/gardens/${garden.id}`),
                    createLink('health', `/gardens/${garden.id}/health`),
                    createLink('plants', `/gardens/${garden.id}/plants`),
                    createLink('zones', `/gardens/${garden.id}/zones`),
                    createLink('action', `/gardens/${garden.id}/action`)
                ],
                plants: createLink('collection', `/gardens/${garden.id}/plants`),
                zones: createLink('collection', `/gardens/${garden.id}/zones`),
                num_plants: Array.from(db.plants.values()).filter(p => p.garden_id === garden.id && !p.end_date).length,
                num_zones: Array.from(db.zones.values()).filter(z => z.garden_id === garden.id && !z.end_date).length,
                health: garden.health_status || {
                    status: 'N/A',
                    details: 'No recent health data from ESP32',
                    last_contact: null
                },
                temperature_humidity_data: {
                    temperature_celsius: garden.temperature_data?.celsius || null,
                    humidity_percentage: garden.humidity_data?.percentage || null
                }
            }))
        });
    },

    createGarden: async (req, res) => {
        const { name, topic_prefix, max_zones, light_schedule } = req.body;

        if (!name) {
            return res.status(400).json({ error: 'Name is required' });
        }

        const { generateXid } = require('../utils/helpers');
        const garden = {
            id: generateXid(),
            name,
            topic_prefix: topic_prefix || name.toLowerCase().replace(/\s+/g, '_'),
            max_zones: max_zones || 0,
            light_schedule,
            ...addTimestamps({})
        };

        db.gardens.set(garden.id, garden);

        // Subscribe to MQTT topics for this new garden
        // if (mqttService.isConnected) {
        //     mqttService.subscribeToGarden(garden);
        // }

        res.status(201).json({
            ...garden,
            links: [
                createLink('self', `/gardens/${garden.id}`),
                createLink('health', `/gardens/${garden.id}/health`),
                createLink('plants', `/gardens/${garden.id}/plants`),
                createLink('zones', `/gardens/${garden.id}/zones`),
                createLink('action', `/gardens/${garden.id}/action`)
            ],
            plants: createLink('collection', `/gardens/${garden.id}/plants`),
            zones: createLink('collection', `/gardens/${garden.id}/zones`),
            num_plants: 0,
            num_zones: 0,
            health: {
                status: 'N/A',
                details: 'Waiting for ESP32 connection',
                last_contact: null
            },
            temperature_humidity_data: {
                temperature_celsius: null,
                humidity_percentage: null
            }
        });
    },

    getGarden: (req, res) => {
        const { gardenID } = req.params;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        res.json({
            ...garden,
            links: [
                createLink('self', `/gardens/${garden.id}`),
                createLink('health', `/gardens/${garden.id}/health`),
                createLink('plants', `/gardens/${garden.id}/plants`),
                createLink('zones', `/gardens/${garden.id}/zones`),
                createLink('action', `/gardens/${garden.id}/action`)
            ],
            plants: createLink('collection', `/gardens/${garden.id}/plants`),
            zones: createLink('collection', `/gardens/${garden.id}/zones`),
            num_plants: Array.from(db.plants.values()).filter(p => p.garden_id === garden.id && !p.end_date).length,
            num_zones: Array.from(db.zones.values()).filter(z => z.garden_id === garden.id && !z.end_date).length,
            health: garden.health_status || {
                status: 'N/A',
                details: 'No recent health data from ESP32',
                last_contact: null
            },
            temperature_humidity_data: {
                temperature_celsius: garden.temperature_data?.celsius || null,
                humidity_percentage: garden.humidity_data?.percentage || null
            }
        });
    },

    updateGarden: async (req, res) => {
        const { gardenID } = req.params;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        const oldTopicPrefix = garden.topic_prefix;

        const updatedGarden = {
            ...garden,
            ...req.body,
            id: gardenID // Prevent ID modification
        };

        db.gardens.set(gardenID, updatedGarden);

        // If topic_prefix changed, update MQTT subscriptions
        // if (mqttService.isConnected && oldTopicPrefix !== updatedGarden.topic_prefix) {
        //     mqttService.unsubscribeFromGarden({ ...garden, topic_prefix: oldTopicPrefix });
        //     mqttService.subscribeToGarden(updatedGarden);

        // Send config update to ESP32 if connected
        // try {
        //     await mqttService.sendConfigUpdate(updatedGarden, {
        //         topic_prefix: updatedGarden.topic_prefix,
        //         light_schedule: updatedGarden.light_schedule,
        //         max_zones: updatedGarden.max_zones
        //     });
        // } catch (error) {
        //     console.error('Failed to send config update to ESP32:', error);
        // }
        // }

        res.json({
            ...updatedGarden,
            links: [
                createLink('self', `/gardens/${garden.id}`),
                createLink('health', `/gardens/${garden.id}/health`),
                createLink('plants', `/gardens/${garden.id}/plants`),
                createLink('zones', `/gardens/${garden.id}/zones`),
                createLink('action', `/gardens/${garden.id}/action`)
            ],
            plants: createLink('collection', `/gardens/${garden.id}/plants`),
            zones: createLink('collection', `/gardens/${garden.id}/zones`),
            num_plants: Array.from(db.plants.values()).filter(p => p.garden_id === garden.id && !p.end_date).length,
            num_zones: Array.from(db.zones.values()).filter(z => z.garden_id === garden.id && !z.end_date).length,
            health: garden.health_status || {
                status: 'N/A',
                details: 'No recent health data from ESP32',
                last_contact: null
            }
        });
    },

    endDateGarden: async (req, res) => {
        const { gardenID } = req.params;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        garden.end_date = new Date().toISOString();
        db.gardens.set(gardenID, garden);

        // Unsubscribe from MQTT topics
        // if (mqttService.isConnected) {
        //     mqttService.unsubscribeFromGarden(garden);
        // }

        res.json({
            ...garden,
            links: [
                createLink('self', `/gardens/${garden.id}`)
            ]
        });
    },

    gardenAction: async (req, res) => {
        const { gardenID } = req.params;
        const action = req.body;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        if (garden.end_date) {
            return res.status(400).json({ error: 'Cannot perform actions on end-dated garden' });
        }

        try {
            // Handle different garden actions
            // if (action.light) {
            //     await mqttService.sendLightCommand(
            //         garden,
            //         action.light.state,
            //         action.light.for_duration
            //     );
            //     console.log(`Light command sent to garden ${garden.name}:`, action.light);
            // }

            // if (action.stop) {
            //     await mqttService.sendStopAllCommand(garden);
            //     console.log(`Stop all command sent to garden ${garden.name}`);
            // }

            res.status(202).json({
                message: 'Action command sent to ESP32',
                garden_id: gardenID,
                action: action
            });

        } catch (error) {
            console.error('Failed to send action to ESP32:', error);
            res.status(500).json({
                error: 'Failed to communicate with garden controller',
                details: error.message
            });
        }
    },

    // New endpoint to get garden health status
    getGardenHealth: (req, res) => {
        const { gardenID } = req.params;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const garden = db.gardens.get(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        res.json({
            garden_id: gardenID,
            health: garden.health_status || {
                status: 'N/A',
                details: 'No recent health data from ESP32',
                last_contact: null
            },
            mqtt_status: mqttService.getConnectionStatus(),
            temperature: garden.temperature_data || null,
            humidity: garden.humidity_data || null,
            light_status: garden.light_status || null
        });
    }
};

module.exports = GardensController;