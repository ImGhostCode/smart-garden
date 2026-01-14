const { Schema, model } = require('mongoose');
const config = require('../config/app.config');

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
                    return Number.isInteger(v) && v >= config.minLightDuration && v <= config.maxLightDuration;
                },
                message: `Duration must be between ${config.minLightDuration}ms and ${config.maxLightDuration}ms`
            }
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
    }
}, {
    timestamps: true
});
// Add compound indexes for better query performance
// gardenSchema.index({ _id: 1, topic_prefix: 1, end_date: 1 });
module.exports = model('Garden', gardenSchema);