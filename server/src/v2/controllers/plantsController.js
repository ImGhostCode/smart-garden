const db = require('../models/database');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const { createLink, getMockNextWaterTime } = require('../utils/helpers');

const PlantsController = {
    getAllPlants: async (req, res, next) => {
        const { gardenID } = req.params;
        const { end_dated } = req.query;

        const filters = {
            garden_id: gardenID
        };
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        try {
            const plants = await db.plants.getAll(filters);

            return res.json(new ApiSuccess(200, 'Plants retrieved successfully', plants.map(plant => ({
                ...plant.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getMockNextWaterTime()
            }))));
        } catch (error) {
            next(error);
        }
    },

    addPlant: async (req, res, next) => {
        const { gardenID } = req.params;
        const { name, zone_id, details } = req.body;

        try {
            // Check if garden exists
            const garden = await db.gardens.getById(gardenID);
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            // Check if zone exists and belongs to the garden
            const zone = await db.zones.getById(zone_id);
            if (!zone || zone.garden_id !== gardenID) {
                throw new ApiError(400, 'Invalid zone_id for the specified garden');
            }

            const plant = {
                garden_id: gardenID,
                name,
                zone_id,
                details,
            };

            const result = await db.plants.create(plant);

            res.status(201).json(new ApiSuccess(201, 'Plant added successfully', {
                ...result.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getMockNextWaterTime()
            }));
        } catch (error) {
            next(error);
        }
    },

    getPlant: async (req, res, next) => {
        const { gardenID, plantID } = req.params;

        try {
            const plant = await db.plants.getById(plantID);

            if (!plant || plant.garden_id !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            return res.json(new ApiSuccess(200, 'Plant retrieved successfully', {
                ...plant.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getMockNextWaterTime()
            }));
        } catch (error) {
            next(error);
        }
    },

    updatePlant: async (req, res, next) => {
        const { gardenID, plantID } = req.params;
        const { name, zone_id, details } = req.body;

        try {
            // Check if plant exists and belongs to the garden
            const plant = await db.plants.getById(plantID);
            if (!plant || plant.garden_id !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            // Check if zone exists and belongs to the garden (if zone_id is being updated)
            if (zone_id) {
                const zone = await db.zones.getById(zone_id);
                if (!zone || zone.garden_id !== gardenID) {
                    throw new ApiError(400, 'Invalid zone_id for the specified garden');
                }
            }

            const update = {};
            if (name) update.name = name;
            if (zone_id) update.zone_id = zone_id;
            if (details) update.details = details;

            const result = await db.plants.updateById(plantID, update);

            return res.json(new ApiSuccess(200, 'Plant updated successfully', {
                ...result.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: getMockNextWaterTime()
            }));
        } catch (error) {
            next(error);
        }
    },

    endDatePlant: async (req, res, next) => {
        const { gardenID, plantID } = req.params;

        try {
            const plant = await db.plants.getById(plantID);
            if (!plant || plant.garden_id !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            const result = await db.plants.deleteById(plantID);

            res.json(new ApiSuccess(200, 'Plant end date set successfully', {
                ...result.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`)
                ]
            }));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = PlantsController;