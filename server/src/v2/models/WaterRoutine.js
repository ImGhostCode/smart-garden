const { Schema, model } = require('mongoose');
const config = require('../config/app.config');

// WaterRoutineStep specifies a Zone and Duration to water
const waterRoutineStepSchema = new Schema({
    zone_id: {
        type: Schema.Types.ObjectId,
        ref: 'Zone',
        required: true
    },
    duration_ms: {
        type: Number,
        validate: {
            validator: function (v) {
                return Number.isInteger(v) && v >= config.minWaterDuration && v <= config.maxWaterDuration;
            },
            message: `Duration must be between ${config.minWaterDuration}ms and ${config.maxWaterDuration}ms`
        }
    }
}, { _id: false });

const waterRoutineSchema = new Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    steps: {
        type: [waterRoutineStepSchema],
        validate: {
            validator: function (v) {
                return v.length > 0;
            },
            message: 'At least one step is required in the water routine'
        }
    },
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

module.exports = model('WaterRoutine', waterRoutineSchema);