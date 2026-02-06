const db = require('../models/database');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const { createLink, intervalToMillis } = require('../utils/helpers');
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
            const plants = await db.plants.getAll({ filters: filters, zone: true, garden: true });

            return res.json(new ApiSuccess(200, 'Plants retrieved successfully', await Promise.all(plants.map(async (plant) => {
                let nextWaterDetails = {
                    time: null,
                };

                if (!plant.end_date) {
                    const zone = await db.zones.getById({ id: plant.zone_id._id.toString() });
                    if (zone && zone.garden_id._id.toString() === gardenID) {
                        // throw new ApiError(404, 'Zone not found');

                        const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
                        if (nextSchedule) {
                            nextWaterDetails = await getNextWaterDetails(nextSchedule, true);
                            // Apply skip count if present
                            if (zone.skip_count && zone.skip_count > 0 && nextWaterDetails.time) {
                                //A adjust the time based on skip count: skip_count * interval
                                nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * intervalToMillis(nextSchedule.interval));
                            }
                        }
                    }
                }
                return {
                    id: plant._id.toString(),
                    ...plant.toObject(),
                    _id: undefined,
                    garden_id: undefined,
                    garden: {
                        id: plant.garden_id._id,
                        name: plant.garden_id.name,
                    },
                    zone_id: undefined,
                    zone: {
                        id: plant.zone_id._id,
                        name: plant.zone_id.name,
                    },
                    links: [
                        createLink('self', `/gardens/${gardenID}/plants/${plant._id}`),
                        createLink('garden', `/gardens/${gardenID}`),
                        createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id._id}`)
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
            const garden = await db.gardens.getById({ id: gardenID });
            if (!garden) {
                throw new ApiError(404, 'Garden not found');
            }

            // Check if zone exists and belongs to the garden
            const zone = await db.zones.getById({ id: zone_id });
            if (!zone || zone.garden_id.toString() !== gardenID) {
                throw new ApiError(400, 'Invalid zone_id for the specified garden');
            }

            const plant = {
                garden_id: gardenID,
                name,
                zone_id,
                details,
            };

            const result = await db.plants.create({ data: plant, zone: true, garden: true });

            res.status(201).json(new ApiSuccess(201, 'Plant added successfully', {
                id: result._id.toString(),
                ...result.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    id: result.garden_id._id,
                    name: result.garden_id.name,
                },
                zone_id: undefined,
                zone: {
                    id: result.zone_id._id,
                    name: result.zone_id.name,
                },
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant._id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id._id}`)
                ],
            }));
        } catch (error) {
            next(error);
        }
    },

    getPlant: async (req, res, next) => {
        const { gardenID, plantID } = req.params;

        try {
            const plant = await db.plants.getById({ id: plantID, zone: true, garden: true });

            if (!plant || plant.garden_id._id.toString() !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            const zone = await db.zones.getById({ id: plant.zone_id._id.toString() });
            if (!zone || zone.garden_id.toString() !== gardenID) {
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
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * intervalToMillis(nextSchedule.interval));
                }
            }

            return res.json(new ApiSuccess(200, 'Plant retrieved successfully', {
                id: plant._id.toString(),
                ...plant.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    id: plant.garden_id._id,
                    name: plant.garden_id.name,
                },
                zone_id: undefined,
                zone: {
                    id: plant.zone_id._id,
                    name: plant.zone_id.name,
                },
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant._id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id._id}`)
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
            const plant = await db.plants.getById({ id: plantID, zone: true, garden: true });
            if (!plant || plant.garden_id._id.toString() !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            // Check if zone exists and belongs to the garden (if zone_id is being updated)
            const zone = await db.zones.getById({ id: zone_id });
            if (zone_id) {
                if (!zone || zone.garden_id.toString() !== gardenID) {
                    throw new ApiError(400, 'Invalid zone_id for the specified garden');
                }
            }

            const update = {};
            if (name) update.name = name;
            if (zone_id) update.zone_id = zone_id;
            if (details) update.details = details;

            const result = await db.plants.updateById({ id: plantID, data: update, zone: true, garden: true });

            const nextSchedule = await getNextActiveWaterSchedule(zone.water_schedule_ids || []);
            let nextWaterDetails = {
                time: null,
            };
            if (nextSchedule) {
                nextWaterDetails = await getNextWaterDetails(nextSchedule, true);
                // Apply skip count if present
                if (zone.skip_count && zone.skip_count > 0 && nextWaterDetails.time) {
                    //A adjust the time based on skip count: skip_count * interval
                    nextWaterDetails.time = new Date(nextWaterDetails.time.getTime() + zone.skip_count * intervalToMillis(nextSchedule.interval));
                }
            }

            return res.json(new ApiSuccess(200, 'Plant updated successfully', {
                id: result._id.toString(),
                ...result.toObject(),
                _id: undefined,
                garden_id: undefined,
                garden: {
                    id: result.garden_id._id,
                    name: result.garden_id.name,
                },
                zone_id: undefined,
                zone: {
                    id: result.zone_id._id,
                    name: result.zone_id.name,
                },
                links: [
                    createLink('self', `/gardens/${gardenID}/plants/${plant._id}`),
                    createLink('garden', `/gardens/${gardenID}`),
                    createLink('zone', `/gardens/${gardenID}/zones/${plant.zone_id._id}`)
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
            const plant = await db.plants.getById({ id: plantID });
            if (!plant || plant.garden_id.toString() !== gardenID) {
                throw new ApiError(404, 'Plant not found');
            }

            const result = await db.plants.deleteById(plantID);

            res.json(new ApiSuccess(200, 'Plant end date set successfully', result.id));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = PlantsController;