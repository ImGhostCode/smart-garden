const { Router } = require('express');
const router = Router();
const ZonesController = require('../controllers/zonesController');
const Joi = require('joi');
const { validateBody, validateParams, validateQuery } = require('../middlewares/validationMiddleware');
const { schemas } = require('../utils/validation');

// Zones routes
// GET /:gardenID/zones - Get all zones (with optional query params)
router.get('/:gardenID/zones',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
        exclude_weater_data: schemas.queryParams.excludeWeatherData
    })),
    ZonesController.getAllZones
);

// POST /:gardenID/zones - Create a new zone
router.post('/:gardenID/zones',
    validateBody(schemas.createZoneRequest),
    ZonesController.addZone
);

// GET /:gardenID/zones/:zoneID - Get specific zone
router.get('/:gardenID/zones/:zoneID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        zoneID: schemas.pathParams.id,
    })),
    validateQuery(Joi.object({
        exclude_weater_data: schemas.queryParams.excludeWeatherData
    })),
    ZonesController.getZone
);

// PATCH /:gardenID/zones/:zoneID - Update zone
router.patch('/:gardenID/zones/:zoneID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        zoneID: schemas.pathParams.id
    })),
    validateQuery(Joi.object({
        exclude_weater_data: schemas.queryParams.excludeWeatherData
    })),
    validateBody(schemas.updateZoneRequest),
    ZonesController.updateZone
);

// DELETE /zones/:gardenID - End-date zone
router.delete('/:gardenID/zones/:zoneID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        zoneID: schemas.pathParams.id
    })),
    ZonesController.endDateZone
);

// POST /:gardenID/zones/:zoneId/action - Execute zone action
router.post('/:gardenID/zones/:zoneID/action',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        zoneID: schemas.pathParams.id
    })),
    validateBody(schemas.zoneAction),
    ZonesController.zoneAction
);

// GET /:gardenID/zones/:zoneID/history - Get zone history (with optional query params)
router.get('/:gardenID/zones/:zoneID/history',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.id,
        zoneID: schemas.pathParams.id
    })),
    validateQuery(Joi.object({
        range: schemas.queryParams.range.optional(),
        limit: schemas.queryParams.limit.optional()
    })),
    ZonesController.zoneHistory);

module.exports = router;