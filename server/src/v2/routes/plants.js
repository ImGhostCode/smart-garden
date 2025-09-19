const express = require('express');
const router = express.Router();
const PlantsController = require('../controllers/plantsController');
const Joi = require('joi');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');

// Plants routes

// GET /gardens/:gardenID/plants
router.get('/:gardenID/plants',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
    })),
    PlantsController.getAllPlants);

// POST /gardens/:gardenID/plants
router.post('/:gardenID/plants',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    validateBody(schemas.createPlantRequest),
    PlantsController.addPlant);

// GET /gardens/:gardenID/plants/:plantID
router.get('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        plantID: schemas.pathParams.plantID
    })),
    PlantsController.getPlant);

// PATCH /gardens/:gardenID/plants/:plantID
router.patch('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        plantID: schemas.pathParams.plantID
    })),
    validateBody(schemas.updatePlantRequest),
    PlantsController.updatePlant);

// DELETE /gardens/:gardenID/plants/:plantID
router.delete('/:gardenID/plants/:plantID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        plantID: schemas.pathParams.plantID
    })),
    PlantsController.endDatePlant);

module.exports = router;