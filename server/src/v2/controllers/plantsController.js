const db = require('../models/database');
const { validateXid, addTimestamps, createLink, generateXid, getNextWaterTime } = require('../utils/helpers');

const PlantsController = {
    getAllPlants: (req, res) => {
        const { gardenID } = req.params;
        const { end_dated } = req.query;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        const plants = Array.from(db.plants.values()).filter(plant => plant.garden_id === gardenID);

        let filteredPlants = plants;
        if (!end_dated || end_dated === 'false') {
            filteredPlants = plants.filter(plant => !plant.end_date);
        }

        res.json({
            plants: filteredPlants.map(plant => ({
                ...plant,
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getNextWaterTime()
            }))
        });
    },

    addPlant: (req, res) => {
        const { gardenID } = req.params;
        const { name, zone_id, details } = req.body;

        if (!validateXid(gardenID)) {
            return res.status(400).json({ error: 'Invalid garden ID format' });
        }

        if (!name || !zone_id) {
            return res.status(400).json({ error: 'Name and zone_id are required' });
        }

        const plant = {
            id: generateXid(),
            garden_id: gardenID,
            name,
            zone_id,
            details,
            ...addTimestamps({})
        };

        db.plants.set(plant.id, plant);

        res.status(201).json({
            ...plant,
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getNextWaterTime()
        });
    },

    getPlant: (req, res) => {
        const { gardenID, plantID } = req.params;

        if (!validateXid(gardenID) || !validateXid(plantID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const plant = db.plants.get(plantID);
        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        res.json({
            ...plant,
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getNextWaterTime()
        });
    },

    updatePlant: (req, res) => {
        const { gardenID, plantID } = req.params;

        if (!validateXid(gardenID) || !validateXid(plantID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const plant = db.plants.get(plantID);
        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        const updatedPlant = {
            ...plant,
            ...req.body,
            id: plantID,
            garden_id: gardenID
        };

        db.plants.set(plantID, updatedPlant);

        res.json({
            ...updatedPlant,
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                createLink('garden', `/gardens/${gardenID}`),
                createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
            ],
            next_water_time: getNextWaterTime()
        });
    },

    endDatePlant: (req, res) => {
        const { gardenID, plantID } = req.params;

        if (!validateXid(gardenID) || !validateXid(plantID)) {
            return res.status(400).json({ error: 'Invalid ID format' });
        }

        const plant = db.plants.get(plantID);
        if (!plant || plant.garden_id !== gardenID) {
            return res.status(404).json({ error: 'Plant not found' });
        }

        plant.end_date = new Date().toISOString();
        db.plants.set(plantID, plant);

        res.json({
            ...plant,
            links: [
                createLink('self', `/gardens/${gardenID}/plants/${plant.id}`)
            ]
        });
    }
};

module.exports = PlantsController;