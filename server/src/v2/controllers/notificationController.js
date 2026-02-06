const db = require('../models/database');
const { createLink } = require('../utils/helpers');
const NotificationClient = require('../services/notificationClient');
const { ApiError, ApiSuccess } = require('../utils/apiResponse');

const NotificationClientController = {
    getAllNotificationClients: async (req, res, next) => {
        try {
            const { end_dated } = req.query;
            const filter = {};
            if (!end_dated || end_dated === 'false') {
                filter.end_date = null;
            }
            const clients = await db.notificationClients.getAll(filter);
            const response = new ApiSuccess(200,
                'Notification clients retrieved successfully',
                clients.map(client => {
                    return {
                        id: client._id.toString(),
                        ...client.toObject(),
                        _id: undefined,
                        links: [
                            createLink('self', `/notification_clients/${client._id}`),
                        ]
                    }
                }),
            );
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },

    getNotificationClient: async (req, res, next) => {
        const { notificationClientID } = req.params;

        try {
            const client = await db.notificationClients.getById(notificationClientID);
            if (!client) {
                throw new ApiError(404, 'Notification client not found');
            }
            const response = new ApiSuccess(200, 'Notification client retrieved successfully', {
                id: client._id.toString(),
                ...client.toObject(),
                _id: undefined,
                links: [
                    createLink('self', `/notification_clients/${client._id}`),
                ]
            });
            return res.json(response);
        } catch (error) {
            next(error);
        }
    },

    addNotificationClient: async (req, res, next) => {
        try {
            const { type, name, options } = req.body;
            const clientData = { type, name, options };

            const newClient = await db.notificationClients.create(clientData);
            const response = new ApiSuccess(201, 'Notification client created successfully', {
                id: newClient._id.toString(),
                ...newClient.toObject(),
                _id: undefined,
                links: [
                    createLink('self', `/notification_clients/${newClient._id}`),
                ]
            });
            return res.status(201).json(response);
        } catch (error) {
            console.error(error);
            next(error);
        }
    },

    updateNotificationClient: async (req, res, next) => {
        const { notificationClientID } = req.params;
        const {
            type, options, name
        } = req.body;

        const updates = {};
        if (type) updates.type = type;
        if (name) updates.name = name;
        if (type === "pushover" && options) {
            if (options.user) updates['options.user'] = options.user;
            if (options.token) updates['options.token'] = options.token;
            if (options.device_name) updates['options.device_name'] = options.device_name;
        } else if (type === "fake" && options) {
            updates['options.create_error'] = options.create_error;
            updates['options.send_message_error'] = options.send_message_error;
        }

        try {
            const updatedClient = await db.notificationClients.updateById(notificationClientID, updates);
            if (!updatedClient) {
                throw new ApiError(404, 'Notification client not found');
            }

            return res.json(new ApiSuccess(200, 'Notification client updated successfully', {
                id: updatedClient._id.toString(),
                ...updatedClient.toObject(),
                _id: undefined,
                links: [
                    createLink('self', `/notification_clients/${updatedClient._id}`),
                ]
            }));
        } catch (error) {
            next(error);
        }
    },

    endDateNotificationClient: async (req, res, next) => {
        const { notificationClientID } = req.params;
        try {
            const deletedClient = await db.notificationClients.deleteById(notificationClientID);
            if (!deletedClient) {
                throw new ApiError(404, 'Notification client not found');
            }
            res.json(new ApiSuccess(200, 'Notification client deleted successfully', deletedClient.id));
        }
        catch (error) {
            next(error);
        }
    },
    testNotificationClient: async (req, res, next) => {
        const { notificationClientID } = req.params;
        const { title, message } = req.body;
        try {
            const client = await db.notificationClients.getById(notificationClientID);
            if (!client) {
                throw new ApiError(404, 'Notification client not found');
            }
            const notificationClient = new NotificationClient(client.toObject());
            await notificationClient.sendMessage(title, message);
            res.json(new ApiSuccess(200, 'Notification sent successfully'));
        } catch (error) {
            next(error);
        }
    },
}

module.exports = NotificationClientController;