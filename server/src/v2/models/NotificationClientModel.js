
const { Schema, model } = require('mongoose');
const GardenModel = require('./GardenModel');
const WaterScheduleModel = require('./WaterScheduleModel');
const NotificationClient = require('../services/notificationClient');

const fakeOptionSchema = new Schema({
    create_error: {
        type: String,
        default: null
    },
    send_message_error: {
        type: String,
        default: null
    }
});

const pushoverOptionSchema = new Schema({
    token: {
        type: String,
        required: true
    },
    user: {
        type: String,
        required: true
    },
    device_name: {
        type: String,
        default: null
    }
});

const notificationClientSchema = new Schema({
    type: {
        type: String,
        required: true,
    },
    name: {
        type: String,
        required: true,
    },
    options: {
        type: Object,
        required: true
    },
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

// Update garden, water schedule when deleting notification client
notificationClientSchema.pre('findOneAndUpdate', async function (next) {
    const update = this.getUpdate();
    if (update.end_date) {
        await GardenModel.updateMany(
            {
                id: this.getQuery()._id,
                end_date: null
            },
            { notification_client_id: null }
        );
        await WaterScheduleModel.updateMany(
            {
                id: this.getQuery()._id,
                end_date: null
            },
            { notification_client_id: null }
        );

    }
    next();
});

notificationClientSchema.methods.sendMessage = async function (title, msg) {
    const client = new NotificationClient(this);
    return await client.sendMessage(title, msg);
}

module.exports = model('NotificationClient', notificationClientSchema);