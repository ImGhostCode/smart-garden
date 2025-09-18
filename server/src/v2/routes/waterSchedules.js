const express = require('express');
const router = express.Router();
const WaterSchedulesController = require('../controllers/waterSchedulesController');
const Joi = require('joi');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');
// Water Schedules routes

// GET /water_schedules - Get all water schedules (with optional query params)
router.get('/',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
        exclude_weather_data: schemas.queryParams.excludeWeatherData
    })),
    WaterSchedulesController.getAllWaterSchedules);


// POST /water_schedules - Create a new water schedule
router.post('/',
    validateQuery(Joi.object(schemas.queryParams).keys({
        exclude_weather_data: schemas.queryParams.excludeWeatherData
    })),
    validateBody(schemas.createWaterScheduleRequest),
    WaterSchedulesController.addWaterSchedule);

// GET /water_schedules/:waterScheduleID - Get specific water schedule
router.get('/:waterScheduleID',
    validateParams(Joi.object({
        waterScheduleID: schemas.pathParams.waterScheduleID
    })),
    validateQuery(Joi.object(schemas.queryParams).keys({
        exclude_weather_data: schemas.queryParams.excludeWeatherData
    })),
    WaterSchedulesController.getWaterSchedule);

// PATCH /water_schedules/:waterScheduleID - Update water schedule
router.patch('/:waterScheduleID',
    validateParams(Joi.object({
        waterScheduleID: schemas.pathParams.waterScheduleID
    })),
    validateQuery(Joi.object(schemas.queryParams).keys({
        exclude_weather_data: schemas.queryParams.excludeWeatherData
    })),
    validateBody(schemas.updateWaterScheduleRequest),
    WaterSchedulesController.updateWaterSchedule);

// DELETE /water_schedules/:waterScheduleID - End-date water schedule
router.delete('/:waterScheduleID',
    validateParams(Joi.object({
        waterScheduleID: schemas.pathParams.waterScheduleID
    })),
    validateQuery(Joi.object(schemas.queryParams).keys({
        exclude_weather_data: schemas.queryParams.excludeWeatherData
    })),
    WaterSchedulesController.endDateWaterSchedule);

module.exports = router;