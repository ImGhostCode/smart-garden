const { Router } = require('express');
const router = Router();
const Joi = require('joi');
const { validateBody, validateParams, validateQuery } = require('../middlewares/validationMiddleware');
const { schemas } = require('../utils/validation');
const NotificationClientsController = require('../controllers/notificationController');

// Weather Clients routes

// GET / - Get all notification clients
router.get('/',
    validateQuery(Joi.object(schemas.queryParams).keys({
        end_dated: schemas.queryParams.endDated,
    })),
    NotificationClientsController.getAllNotificationClients);

// POST / - Create a new notification client
router.post('/',
    validateBody(schemas.createNotificationClientRequest),
    NotificationClientsController.addNotificationClient);

// GET /:notificationClientID - Get specific notification client
router.get('/:notificationClientID',
    validateParams(Joi.object({
        notificationClientID: schemas.pathParams.id
    })),
    NotificationClientsController.getNotificationClient);

// GET /:notificationClientID/test - Get sample data from specific notification client
router.post('/:notificationClientID/test',
    validateParams(Joi.object({
        notificationClientID: schemas.pathParams.id
    })),
    validateBody(schemas.testNotificationClientRequest),
    NotificationClientsController.testNotificationClient);

// PATCH /:notificationClientID - Update notification client
router.patch('/:notificationClientID',
    validateParams(Joi.object({
        notificationClientID: schemas.pathParams.id
    })),
    validateBody(schemas.updateNotificationClientRequest),
    NotificationClientsController.updateNotificationClient);

// DELETE /:notificationClientID - End-date notification client
router.delete('/:notificationClientID',
    validateParams(Joi.object({
        notificationClientID: schemas.pathParams.id
    })),
    NotificationClientsController.endDateNotificationClient);

module.exports = router;