const { Router } = require('express');
const Joi = require('joi');
const router = Router();
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
        gardenID: schemas.pathParams.id
    })),
    GardensController.getGarden
);

// PATCH /gardens/:gardenID - Update garden
router.patch('/:gardenID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    validateBody(schemas.updateGardenRequest),
    GardensController.updateGarden
);

// DELETE /gardens/:gardenID - End-date garden
router.delete('/:gardenID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    GardensController.endDateGarden
);

// POST /gardens/:gardenID/action - Execute garden action
router.post('/:gardenID/action',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    validateBody(schemas.gardenAction),
    GardensController.gardenAction
);

// Light Schedule Routes
// POST /gardens/:gardenID/light-schedule - Schedule light actions
router.post('/:gardenID/light-schedule',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    GardensController.scheduleLightActions
);

// PUT /gardens/:gardenID/light-schedule/reset - Reset light schedule
router.put('/:gardenID/light-schedule/reset',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id
    })),
    GardensController.resetLightSchedule
);

module.exports = router;