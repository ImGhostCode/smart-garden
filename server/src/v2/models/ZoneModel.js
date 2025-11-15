const { Schema, model } = require('mongoose');
const { xidPattern } = require('../utils/validation');

// Zone Schema
const zoneSchema = new Schema({
    garden_id: {
        type: String,
        required: true,
        ref: 'Garden',
        index: true,
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'Garden ID must be a valid XID format'
        }
    },
    name: {
        type: String,
        required: true,
        trim: true
    },
    details: {
        description: {
            type: String,
            trim: true
        },
        notes: {
            type: String,
            trim: true
        }
    },
    position: {
        type: Number,
        required: true,
        min: 0
    },
    water_schedule_ids: [{
        type: String,
        ref: 'WaterSchedule',
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'Water schedule ID must be a valid XID format'
        }
    }],
    skip_count: {
        type: Number,
        default: 0,
        min: 0
    },
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});
// Add compound indexes for better query performance
// zoneSchema.index({ garden_id: 1, position: 1, end_date: 1 });
// zoneSchema.index({ garden_id: 1, end_date: 1 });
module.exports = model('Zone', zoneSchema);