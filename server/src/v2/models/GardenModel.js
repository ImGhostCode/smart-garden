const { Schema, model } = require('mongoose');
const config = require('../config/app.config');
const ZoneModel = require('./ZoneModel');
const PlantModel = require('./PlantModel');

const gardenSchema = new Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    topic_prefix: {
        type: String,
        required: true,
        trim: true,
        index: true,
        unique: true,
        validate: {
            validator: function (v) {
                // Avoid spaces and characters: [$#*>+/]
                return !/[\s$#*>+/]/.test(v);
            },
            message: 'Topic prefix cannot contain spaces or characters: [$#*>+/]'
        }
    },
    max_zones: {
        type: Number,
        required: true,
        min: 1,
        default: 1
    },
    light_schedule: {
        duration_ms: {
            type: Number,
            validate: {
                validator: function (v) {
                    return !v || Number.isInteger(v) && v >= config.minLightDuration && v <= config.maxLightDuration;
                },
                message: `Duration must be between ${config.minLightDuration}ms and ${config.maxLightDuration}ms`
            },
            default: null
        },
        start_time: {
            type: String,
            validate: {
                validator: function (v) {
                    // Validate time format (e.g., "23:00:00")
                    return !v || /^\d{2}:\d{2}:\d{2}$/.test(v);
                },
                message: 'Start time must be in format "HH:MM:SS"'
            },
            default: null
        },
        adhoc_on_time: {
            type: Date,
            validate: {
                validator: function (v) {
                    return !v || v instanceof Date;
                },
                message: 'Adhoc on time must be a valid date'
            }
        }
    },
    end_date: {
        type: Date,
        default: null
    },
    controller_config: {
        valve_pins: { type: [Number], default: [] },
        pump_pins: { type: [Number], default: [] },
        light_pin: { type: Number, default: null },
        temp_humidity_pin: { type: Number, default: null },
        temp_hum_interval_ms: { type: Number, default: 5000 }, // in minutes
    },
    notification_client_id: {
        type: Schema.Types.ObjectId,
        ref: 'NotificationClient',
        default: null
    },
    notification_settings: {
        controller_startup: { type: Boolean, default: false },
        light_schedule: { type: Boolean, default: false },
        downtime_ms: { type: Number, default: null }, // in milliseconds
        watering_started: { type: Boolean, default: false },
        watering_completed: { type: Boolean, default: false }
    }
}, {
    timestamps: true
});

gardenSchema.methods.getNotificationSettings = function () {
    return this.notification_settings || {};
}

gardenSchema.pre('findOneAndUpdate', async function (next) {
    const update = this.getUpdate();
    if (update.end_date) {
        await ZoneModel.updateMany(
            {
                garden_id: this.getQuery()._id,
                end_date: null
            },
            { end_date: new Date() }
        );
        await PlantModel.updateMany(
            {
                garden_id: this.getQuery()._id,
                end_date: null
            },
            { end_date: new Date() }
        );

    }
    next();
});

// Add compound indexes for better query performance
// gardenSchema.index({ _id: 1, topic_prefix: 1, end_date: 1 });
module.exports = model('Garden', gardenSchema);