const express = require('express');
const router = express.Router();
const ZonesController = require('../controllers/zonesController');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');
const Joi = require('joi');

// Zones routes
// GET /:gardenID/zones - Get all zones (with optional query params)
router.get('/:gardenID/zones',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated
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
        gardenID: schemas.pathParams.gardenID,
        zoneID: schemas.pathParams.zoneID
    })),
    ZonesController.getZone
);

// PATCH /:gardenID/zones/:zoneID - Update zone
router.patch('/:gardenID/zones/:zoneID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        zoneID: schemas.pathParams.zoneID
    })),
    validateBody(schemas.updateZoneRequest),
    ZonesController.updateZone
);

// DELETE /zones/:gardenID - End-date zone
router.delete('/:gardenID/zones/:zoneID',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        zoneID: schemas.pathParams.zoneID
    })),
    ZonesController.endDateZone
);

// POST /:gardenID/zones/:zoneId/action - Execute zone action
router.post('/:gardenID/zones/:zoneID/action',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        zoneID: schemas.pathParams.zoneID
    })),
    validateBody(schemas.zoneAction),
    ZonesController.zoneAction
);

// GET /:gardenID/zones/:zoneID/history - Get zone history (with optional query params)
router.get('/:gardenID/zones/:zoneID/history',
    validateParams(Joi.object({
        gardenID: schemas.pathParams.gardenID,
        zoneID: schemas.pathParams.zoneID
    })),
    validateQuery(Joi.object({
        range: schemas.queryParams.range.optional(),
        limit: schemas.queryParams.limit.optional()
    })),
    ZonesController.zoneHistory);

module.exports = router;