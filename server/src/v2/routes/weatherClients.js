const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { schemas, validateBody, validateParams, validateQuery } = require('../utils/validation');
const WeatherClientsController = require('../controllers/weatherClientsController');

// Weather Clients routes

// GET / - Get all weather clients
router.get('/',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
    })),
    WeatherClientsController.getAllWeatherClients);

// POST / - Create a new weather client
router.post('/',
    validateBody(schemas.createWeatherClientRequest),
    WeatherClientsController.addWeatherClient);

// GET /:weatherClientID - Get specific weather client
router.get('/:weatherClientID',
    validateParams(Joi.object({
        weatherClientID: schemas.pathParams.weatherClientID
    })),
    WeatherClientsController.getWeatherClient);

// GET /:weatherClientID/test - Get sample data from specific weather client
router.get('/:weatherClientID/test',
    validateParams(Joi.object({
        weatherClientID: schemas.pathParams.weatherClientID
    })),
    WeatherClientsController.testWeatherClient);

// PATCH /:weatherClientID - Update weather client
router.patch('/:weatherClientID',
    validateParams(Joi.object({
        weatherClientID: schemas.pathParams.weatherClientID
    })),
    validateBody(schemas.updateWeatherClientRequest),
    WeatherClientsController.updateWeatherClient);

// DELETE /:weatherClientID - End-date weather client
router.delete('/:weatherClientID',
    validateParams(Joi.object({
        weatherClientID: schemas.pathParams.weatherClientID
    })),
    WeatherClientsController.endDateWeatherClient);

module.exports = router;