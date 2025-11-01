const mongoose = require('mongoose');
const { durationPattern, timePattern } = require('../utils/validation');

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
    },
    client_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'WeatherClientConfig',
        required: true
    }
}, { _id: false });

const weatherControlSchema = new mongoose.Schema({
    rain_control: scaleControlSchema,
    temperature_control: scaleControlSchema
}, { _id: false });


const activePeriodSchema = new mongoose.Schema({
    start_month: {
        type: String,
        required: true,
        enum: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    },
    end_month: {
        type: String,
        required: true,
        enum: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    }
}, { _id: false });


// WaterSchedule Schema
const waterScheduleSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
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
                // return /^\d+(ms|s|m|h)$/.test(v);
                return durationPattern.test(v);
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
                // return /^\d+(ms|s|m|h)$/.test(v);
                return durationPattern.test(v);
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
                // return /^\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/.test(v);
                return timePattern.test(v);
            },
            message: 'Start time must be in format "HH:MM:SS±HH:MM"'
        }
    },
    weather_control: weatherControlSchema,
    active_period: activePeriodSchema,
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});
// Add compound indexes for better query performance
// waterScheduleSchema.index({ end_date: 1 });
module.exports = mongoose.model('WaterSchedule', waterScheduleSchema);