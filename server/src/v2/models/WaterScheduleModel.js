const { Schema, model } = require('mongoose');
const { durationPattern, timePattern } = require('../utils/validation');

const scaleControlSchema = new Schema({
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
        type: Schema.Types.ObjectId,
        ref: 'WeatherClientConfig',
        required: true
    }
}, { _id: false });

// Scale calculates and returns the multiplier based on the input value
/* 
    Example:
    baseline_value = 20 (degrees)
    factor = 1.5
    range = 10
    actualValue = 25

    diff = 25 - 20 = 5
    r = 10
    (5 / 10) * 1.5 + 1 = 1.75
*/
scaleControlSchema.methods.scale = function (actualValue) {
    let diff = actualValue - this.baseline_value;
    let r = this.range;
    if (diff > r) {
        diff = r;
    }
    if (diff < -r) {
        diff = -r;
    }
    return (diff / r) * (this.factor) + 1;
}

// InvertedScaleDownOnly calculates and returns the multiplier based on the input value, but is inverted
// so higher input values cause scaling < 1. Also it will only scale in this direction
/*
    Example:
    baseline_value = 50 (mm of rain)
    factor = 0.5
    range = 20
    actualValue = 60
    diff = 60 - 50 = 10
    r = 20
    1 - (10 / 20) * (1 - 0.5) = 0.75
*/
scaleControlSchema.methods.invertedScaleDownOnly = function (actualValue) {
    // If the baseline is not reached, just scale 1
    if (actualValue < this.baseline_value) {
        return 1;
    }
    let diff = actualValue - this.baseline_value;
    let r = this.range;
    if (diff > r) {
        diff = r;
    }
    return 1 - (diff / r) * (1 - this.factor);
}

const weatherControlSchema = new Schema({
    rain_control: scaleControlSchema,
    temperature_control: scaleControlSchema
}, { _id: false });


const activePeriodSchema = new Schema({
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
const waterScheduleSchema = new Schema({
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


// HasRainControl is used to determine if rain conditions should be checked before watering the Zone
waterScheduleSchema.methods.hasRainControl = function () {
    return this.weather_control != null &&
        this.weather_control.rain_control != null;
}

// HasTemperatureControl is used to determine if configuration is available for environmental scaling
waterScheduleSchema.methods.hasTemperatureControl = function () {
    return this.weather_control != null &&
        this.weather_control.temperature_control != null;
}

waterScheduleSchema.methods.hasWeatherControl = function () {
    return this.hasRainControl() || this.hasTemperatureControl();
}

// Add compound indexes for better query performance
// waterScheduleSchema.index({ end_date: 1 });
module.exports = model('WaterSchedule', waterScheduleSchema);