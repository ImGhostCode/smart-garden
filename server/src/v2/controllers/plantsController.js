const db = require('../models/database');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const { createLink } = require('../utils/helpers');
const { getNextWaterDetails, getNextActiveWaterSchedule } = require('../utils/waterScheduleHelpers');

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

            return res.json(new ApiSuccess(200, 'Plants retrieved successfully', await Promise.all(plants.map(async (plant) => {
                const zone = await db.zones.getById(plant.zone_id);
                if (!zone || zone.garden_id !== gardenID) {
                    throw new ApiError(404, 'Zone not found');
                }

                const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
                let nextWaterDetails = {
                    time: null,
                };
                if (nextSchedule) {
                    nextWaterDetails = await getNextWaterDetails(nextSchedule, true);
                    // Apply skip count if present
                    if (zone.skip_count && zone.skip_count > 0 && nextWaterDetails.time) {
                        //A adjust the time based on skip count: skip_count * interval
                        nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * durationToMillis(nextSchedule.interval));
                    }
                }
                return {
                    ...plant.toObject(),
                    links: [
                        createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                        createLink('garden', `/gardens/${gardenID}`),
                        createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                    ],
                    next_water_time: nextWaterDetails.time
                }
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

            const zone = await db.zones.getById(plant.zone_id);
            if (!zone || zone.garden_id !== gardenID) {
                throw new ApiError(404, 'Zone not found');
            }

            const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
            let nextWaterDetails = {
                time: null,
            };
            if (nextSchedule) {
                nextWaterDetails = await getNextWaterDetails(nextSchedule, true);
                // Apply skip count if present
                if (zone.skip_count && zone.skip_count > 0 && nextWaterDetails.time) {
                    //A adjust the time based on skip count: skip_count * interval
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * durationToMillis(nextSchedule.interval));
                }
            }

            return res.json(new ApiSuccess(200, 'Plant retrieved successfully', {
                ...plant.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: nextWaterDetails.time
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
            const zone = await db.zones.getById(zone_id);
            if (zone_id) {
                if (!zone || zone.garden_id !== gardenID) {
                    throw new ApiError(400, 'Invalid zone_id for the specified garden');
                }
            }

            const update = {};
            if (name) update.name = name;
            if (zone_id) update.zone_id = zone_id;
            if (details) update.details = details;

            const result = await db.plants.updateById(plantID, update);

            const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
            let nextWaterDetails = {
                time: null,
            };
            if (nextSchedule) {
                nextWaterDetails = await getNextWaterDetails(nextSchedule, true);
                // Apply skip count if present
                if (zone.skip_count && zone.skip_count > 0 && nextWaterDetails.time) {
                    //A adjust the time based on skip count: skip_count * interval
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * durationToMillis(nextSchedule.interval));
                }
            }

            return res.json(new ApiSuccess(200, 'Plant updated successfully', {
                ...result.toObject(),
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant.id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id}`)
                ],
                next_water_time: nextWaterDetails.time
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