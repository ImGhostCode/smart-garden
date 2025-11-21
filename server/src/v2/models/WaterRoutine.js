const { Schema, model } = require('mongoose');
const { durationPattern } = require('../utils/validation');

// WaterRoutineStep specifies a Zone and Duration to water
const waterRoutineStepSchema = new Schema({
    zone_id: {
        type: Schema.Types.ObjectId,
        ref: 'Zone',
        required: true
    },
    duration: {
        type: String,
        validate: {
            validator: function (v) {
                // Duration format validation (e.g., "15000ms", "15m", "1h")
                return durationPattern.test(v);
            },
            message: 'Duration must be in valid format (e.g., "15000ms", "15m")'
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