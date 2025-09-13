const express = require('express');
const Joi = require('joi');
const router = express.Router();
const GardensController = require('../controllers/gardensController');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');

// Gardens routes with Joi validation

// GET /gardens - Get all gardens (with optional query params)
router.get('/',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated
    })),
    GardensController.getAllGardens
);

// POST /gardens - Create a new garden
router.post('/',
    validateBody(schemas.createGardenRequest),
    GardensController.createGarden
);

// GET /gardens/:gardenID - Get specific garden
router.get('/:gardenID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    GardensController.getGarden
);

// PATCH /gardens/:gardenID - Update garden
router.patch('/:gardenID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    validateBody(schemas.updateGardenRequest),
    GardensController.updateGarden
);

// DELETE /gardens/:gardenID - End-date garden
router.delete('/:gardenID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    GardensController.endDateGarden
);

// POST /gardens/:gardenID/action - Execute garden action
router.post('/:gardenID/action',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID
    })),
    validateBody(schemas.gardenAction),
    GardensController.gardenAction
);

module.exports = router;