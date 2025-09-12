const mongoose = require('mongoose');

// XID validation pattern from OpenAPI spec
const xidPattern = /^[0-9a-v]{20}$/;

const scaleControlSchema = new mongoose.Schema({
    baseline_value: {
        type: Number,
        required: true
    },
    factor: {
        type: Number,
        required: true,
        min: 0,
        max: 1
    },
    range: {
        type: Number,
        required: true
    }
}, { _id: false });

const weatherControlSchema = new mongoose.Schema({
    rain_control: scaleControlSchema,
    temperature_control: scaleControlSchema
}, { _id: false });


// WaterSchedule Schema - following OpenAPI WaterSchedule + WaterScheduleResponse
const waterScheduleSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true,
        index: true,
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'ID must be a valid XID format'
        }
    },
    name: {
        type: String,
        trim: true
    },
    description: {
        type: String,
        trim: true
    },
    duration: {
        type: String,
        required: true,
        validate: {
            validator: function (v) {
                // Duration format validation (e.g., "15000ms", "15m", "1h")
                return /^\d+(ms|s|m|h)$/.test(v);
            },
            message: 'Duration must be in valid format (e.g., "15000ms", "15m")'
        }
    },
    interval: {
        type: String,
        required: true,
        validate: {
            validator: function (v) {
                // Duration format validation for intervals (e.g., "72h", "24h")
                return /^\d+(ms|s|m|h)$/.test(v);
            },
            message: 'Interval must be in valid duration format (e.g., "72h")'
        }
    },
    start_time: {
        type: String,
        required: true,
        validate: {
            validator: function (v) {
                // Time format validation
                return /^\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/.test(v);
            },
            message: 'Start time must be in format "HH:MM:SS±HH:MM"'
        }
    },
    weather_control: weatherControlSchema,
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: {
        createdAt: 'created_at',
        updatedAt: 'updated_at'
    }
});
// Add compound indexes for better query performance
waterScheduleSchema.index({ end_date: 1 });
module.exports = mongoose.model('WaterSchedule', waterScheduleSchema);