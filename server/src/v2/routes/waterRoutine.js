const { Router } = require('express');
const Joi = require('joi');
const router = Router();
const WaterRoutineController = require('../controllers/waterRoutineController');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');

// Water Routine Routes
router.get('/',
    validateQuery(Joi.object({
        end_dated: Joi.string().valid('true', 'false')
    })),
    WaterRoutineController.getAllWaterRoutines);

// Create a new water routine
router.post('/',
    validateBody(schemas.createWaterRoutineRequest),
    WaterRoutineController.createWaterRoutine);

// Get a water routine by ID
router.get('/:waterRoutineID',
    validateParams(Joi.object({
        waterRoutineID: schemas.pathParams.id
    })),
    WaterRoutineController.getWaterRoutine);

// Update a water routine by ID
router.put('/:waterRoutineID',
    validateParams(Joi.object({
        waterRoutineID: schemas.pathParams.id
    })),
    validateBody(schemas.updateWaterRoutineRequest),
    WaterRoutineController.updateWaterRoutine);

// Delete (soft delete) a water routine by ID
router.delete('/:waterRoutineID',
    validateParams(Joi.object({
        waterRoutineID: schemas.pathParams.id
    })),
    WaterRoutineController.deleteWaterRoutine);

router.post('/:waterRoutineID/run',
    validateParams(Joi.object({
        waterRoutineID: schemas.pathParams.id
    })),
    WaterRoutineController.runWaterRoutine);

module.exports = router;