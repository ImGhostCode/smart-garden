const db = require('../models/database');
const { createLink, getMockNextWaterTime } = require('../utils/helpers');

const PlantsController = {
    getAllPlants: async (req, res) => {
        const { gardenID } = req.params;
        const { end_dated } = req.query;

        const filters = {
            garden_id: gardenID
        };
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        const plants = await db.plants.getAll(filters);

        res.json({
            items: plants.map(plant => ({
                ...plant.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getMockNextWaterTime()
            }))
        });
    },

    addPlant: async (req, res) => {
        const { gardenID } = req.params;
        const { name, zone_id, details } = req.body;

        // Check if garden exists
        const garden = await db.gardens.getById(gardenID);
        if (!garden) {
            return res.status(404).json({ error: 'Garden not found' });
        }

        // Check if zone exists and belongs to the garden
        const zone = await db.zones.getById(zone_id);
        if (!zone || zone.garden_id !== gardenID) {
            return res.status(400).json({ error: 'Invalid zone_id for the specified garden' });
        }

        const plant = {
            garden_id: gardenID,
            name,
            zone_id,
            details,
        };

        const result = await db.plants.create(plant);

        res.status(201).json({
            ...result.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getMockNextWaterTime()
        });
    },

    getPlant: async (req, res) => {
        const { gardenID, plantID } = req.params;

        const plant = await db.plants.getById(plantID);

        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        res.json({
            ...plant.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getMockNextWaterTime()
        });
    },

    updatePlant: async (req, res) => {
        const { gardenID, plantID } = req.params;
        const { name, zone_id, details } = req.body;


        // Check if plant exists and belongs to the garden
        const plant = await db.plants.getById(plantID);
        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        // Check if zone exists and belongs to the garden (if zone_id is being updated)
        if (zone_id) {
            const zone = await db.zones.getById(zone_id);
            if (!zone || zone.garden_id !== gardenID) {
                return res.status(400).json({ error: 'Invalid zone_id for the specified garden' });
            }
        }

        const update = {};
        if (name) update.name = name;
        if (zone_id) update.zone_id = zone_id;
        if (details) update.details = details;

        const result = await db.plants.updateById(plantID, update);

        res.json({
            ...result.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getMockNextWaterTime()
        });
    },

    endDatePlant: async (req, res) => {
        const { gardenID, plantID } = req.params;

        const plant = await db.plants.getById(plantID);
        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        const result = await db.plants.deleteById(plantID);

        res.json({
            ...result.toObject(),
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`)
            ]
        });
    }
};

module.exports = PlantsController;