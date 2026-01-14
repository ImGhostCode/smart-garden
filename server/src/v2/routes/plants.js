const { Router } = require('express');
const router = Router();
const PlantsController = require('../controllers/plantsController');
const Joi = require('joi');
const { validateBody, validateParams, validateQuery } = require('../middlewares/validationMiddleware');
const { schemas } = require('../utils/validation');

// Plants routes

// GET /gardens/:gardenID/plants
router.get('/:gardenID/plants',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
    })),
    PlantsController.getAllPlants);

// POST /gardens/:gardenID/plants
router.post('/:gardenID/plants',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    validateBody(schemas.createPlantRequest),
    PlantsController.addPlant);

// GET /gardens/:gardenID/plants/:plantID
router.get('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        plantID: schemas.pathParams.id
    })),
    PlantsController.getPlant);

// PATCH /gardens/:gardenID/plants/:plantID
router.patch('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        plantID: schemas.pathParams.id
    })),
    validateBody(schemas.updatePlantRequest),
    PlantsController.updatePlant);

// DELETE /gardens/:gardenID/plants/:plantID
router.delete('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        plantID: schemas.pathParams.id
    })),
    PlantsController.endDatePlant);

module.exports = router;