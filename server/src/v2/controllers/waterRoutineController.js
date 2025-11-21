const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const db = require('../models/database');
const { durationToMillis } = require('../utils/helpers');

const WaterRoutineController = {
    // Create a new water routine
    async createWaterRoutine(req, res, next) {
        try {
            const { name, steps } = req.body;
            const newRoutine = { name, steps };
            for (let i = 0; i < newRoutine.steps.length; i++) {
                const zone_id = newRoutine.steps[i].zone_id;
                const zone = await db.zones.getById(zone_id);
                if (!zone) {
                    throw new ApiError(404, `Unable to find zone: ${zone_id}`);
                }
            }

            const waterRoutine = await db.waterRoutines.create(newRoutine);
            return res.status(201).json(new ApiSuccess(201, 'Water routine created successfully', waterRoutine));
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
            const routines = await db.waterRoutines.getAll(filter);
            return res.status(200).json(new ApiSuccess(200, 'Water routines retrieved successfully', routines));
        } catch (error) {
            next(error);
        }
    },
    // Get a water routine by ID
    async getWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const routine = await db.waterRoutines.getById(waterRoutineID);
            if (!routine) {
                throw new ApiError(404, 'Water routine not found');
            }
            return res.status(200).json(new ApiSuccess(200, 'Water routine retrieved successfully', routine));
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
                    const zone = await db.zones.getById(zone_id);
                    if (!zone) {
                        throw new ApiError(404, `Unable to find zone: ${zone_id}`);
                    }
                }
                updated.steps = req.body.steps
            };

            const routine = await db.waterRoutines.updateById(waterRoutineID, updated);
            if (!routine) {
                throw new ApiError(404, 'Water routine not found or could not be updated');
            }
            return res.status(200).json(new ApiSuccess(200, 'Water routine updated successfully', routine));
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
            return res.status(200).json(new ApiSuccess(200, 'Water routine deleted successfully', routine));
        } catch (error) {
            next(error);
        }
    },

    // Run a water routine by ID
    async runWaterRoutine(req, res, next) {
        const { waterRoutineID } = req.params;
        try {
            const routine = await db.waterRoutines.getById(waterRoutineID);
            if (!routine) {
                throw new ApiError(404, 'Water routine not found');
            }
            for (const step of routine.steps) {
                console.log(`Watering Zone ID: ${step.zone_id} for Duration: ${step.duration}`);
                // Execute watering logic here
                const zone = await db.zones.getById(step.zone_id);
                if (!zone) {
                    console.warn(`Zone ID: ${step.zone_id} not found. Skipping step.`);
                    continue;
                }
                if (zone.end_date) {
                    console.warn(`Zone ID: ${step.zone_id} is end-dated. Skipping step.`);
                    continue;
                }

                const garden = await db.gardens.getById(zone.garden_id);
                if (!garden) {
                    console.warn(`Garden ID: ${zone.garden_id} not found for Zone ID: ${step.zone_id}. Skipping step.`);
                    continue;
                }
                const cronScheduler = require('../services/cronScheduler');
                await cronScheduler.executeWaterAction(garden, zone, durationToMillis(step.duration), "water_routine");
            }
            return res.status(202).json(new ApiSuccess(202, 'Water routine execution started', null));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = WaterRoutineController;