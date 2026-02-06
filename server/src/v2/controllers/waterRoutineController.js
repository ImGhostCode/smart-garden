const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const db = require('../models/database');
const { createLink } = require('../utils/helpers');

const WaterRoutineController = {
    // Create a new water routine
    async createWaterRoutine(req, res, next) {
        try {
            const { name, steps } = req.body;
            const newRoutine = { name, steps };
            for (let i = 0; i < newRoutine.steps.length; i++) {
                const zone_id = newRoutine.steps[i].zone_id;
                const zone = await db.zones.getById({ id: zone_id });
                if (!zone) {
                    throw new ApiError(404, `Unable to find zone: ${zone_id}`);
                }
            }

            const waterRoutine = await db.waterRoutines.create({ data: newRoutine, zone: true });
            return res.status(201).json(new ApiSuccess(201, 'Water routine created successfully', {
                id: waterRoutine._id.toString(),
                ...waterRoutine.toObject(),
                _id: undefined,
                steps: waterRoutine.steps.map(step => {
                    return {
                        ...step.toObject(),
                        zone_id: undefined,
                        zone: {
                            id: step.zone_id._id,
                            name: step.zone_id.name,
                        },
                    }
                },
                ),
                links: [
                    createLink('self', `/water-routines/${waterRoutine._id}`),
                ]
            }));
        } catch (error) {
            next(error);
        }
    },
    // Get all water routines
    async getAllWaterRoutines(req, res, next) {
        const { end_dated } = req.query;
        const filter = {};
        if (!end_dated || end_dated === 'false') {
            filter.end_date = null;
        }
        try {
            const routines = await db.waterRoutines.getAll({ filters: filter, zone: true });
            return res.status(200).json(new ApiSuccess(200, 'Water routines retrieved successfully', routines.map(routine => {
                return {
                    id: routine._id.toString(),
                    ...routine.toObject(),
                    _id: undefined,
                    steps: routine.steps
                        .filter(step => !step.zone_id.end_date) // filter out steps with end-dated zones
                        .map(step => {
                            return {
                                ...step.toObject(),
                                zone_id: undefined,
                                zone: {
                                    id: step.zone_id._id,
                                    name: step.zone_id.name,
                                },
                            }
                        }),
                    links: [
                        createLink('self', `/water-routines/${routine._id}`),
                    ]
                }
            })));
        } catch (error) {
            next(error);
        }
    },
    // Get a water routine by ID
    async getWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const routine = await db.waterRoutines.getById({ id: waterRoutineID, zone: true });
            if (!routine) {
                throw new ApiError(404, 'Water routine not found');
            }
            return res.status(200).json(new ApiSuccess(200, 'Water routine retrieved successfully', {
                id: routine._id.toString(),
                ...routine.toObject(),
                _id: undefined,
                steps: routine.steps
                    .filter(step => !step.zone_id.end_date) // filter out steps with end-dated zones
                    .map(step => {
                        return {
                            ...step.toObject(),
                            zone_id: undefined,
                            zone: {
                                id: step.zone_id._id,
                                name: step.zone_id.name,
                            },
                        }
                    }),
                links: [
                    createLink('self', `/water-routines/${routine._id}`),
                ]
            }));
        } catch (error) {
            next(error);
        }
    },
    // Update a water routine by ID
    async updateWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const updated = {};
            if (req.body.name) updated.name = req.body.name;
            if (req.body.steps) {
                for (let i = 0; i < req.body.steps.length; i++) {
                    const step = req.body.steps[i];
                    const zone_id = step.zone_id;
                    const zone = await db.zones.getById({ id: zone_id });
                    if (!zone) {
                        throw new ApiError(404, `Unable to find zone: ${zone_id}`);
                    }
                }
                updated.steps = req.body.steps
            };

            const routine = await db.waterRoutines.updateById({ id: waterRoutineID, data: updated, zone: true });
            if (!routine) {
                throw new ApiError(404, 'Water routine not found or could not be updated');
            }
            return res.status(200).json(new ApiSuccess(200, 'Water routine updated successfully', {
                id: routine._id.toString(),
                ...routine.toObject(),
                _id: undefined,
                steps: routine.steps
                    .filter(step => !step.zone_id.end_date) // filter out steps with end-dated zones
                    .map(step => {
                        return {
                            ...step.toObject(),
                            zone_id: undefined,
                            zone: {
                                id: step.zone_id._id,
                                name: step.zone_id.name,
                            },
                        }
                    }),
                links: [
                    createLink('self', `/water-routines/${routine._id}`),
                ]
            }));
        } catch (error) {
            next(error);
        }
    },
    // Delete (soft delete) a water routine by ID
    async deleteWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const routine = await db.waterRoutines.deleteById(waterRoutineID);
            if (!routine) {
                throw new ApiError(404, 'Water routine not found or could not be deleted');
            }
            return res.status(200).json(new ApiSuccess(200, 'Water routine deleted successfully', routine.id));
        } catch (error) {
            next(error);
        }
    },

    // Run a water routine by ID
    async runWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const routine = await db.waterRoutines.getById({ id: waterRoutineID });
            if (!routine) {
                throw new ApiError(404, 'Water routine not found');
            }
            for (const step of routine.steps) {
                console.log(`Watering Zone ID: ${step.zone_id} for Duration: ${step.duration_ms}`);
                // Execute watering logic here
                const zone = await db.zones.getById({ id: step.zone_id });
                if (!zone) {
                    console.warn(`Zone ID: ${step.zone_id} not found. Skipping step.`);
                    continue;
                }
                if (zone.end_date) {
                    console.warn(`Zone ID: ${step.zone_id} is end-dated. Skipping step.`);
                    continue;
                }

                const garden = await db.gardens.getById({ id: zone.garden_id });
                if (!garden) {
                    console.warn(`Garden ID: ${zone.garden_id} not found for Zone ID: ${step.zone_id}. Skipping step.`);
                    continue;
                }
                const cronScheduler = require('../services/cronScheduler');
                await cronScheduler.executeWaterAction(garden, zone, step.duration_ms, "water_routine");
            }
            return res.status(202).json(new ApiSuccess(202, 'Water routine execution started', null));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = WaterRoutineController;