const mongoose = require('mongoose');
const { xidPattern } = require('../utils/validation');

// Plant Schema
const plantSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    garden_id: {
        type: String,
        required: true,
        ref: 'Garden',
        // index: true,
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'Garden ID must be a valid XID format'
        }
    },
    zone_id: {
        type: String,
        required: true,
        ref: 'Zone',
        // index: true,
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'Zone ID must be a valid XID format'
        }
    },
    details: {
        description: {
            type: String,
            trim: true
        },
        notes: {
            type: String,
            trim: true
        },
        time_to_harvest: {
            type: String,
            trim: true
        },
        count: {
            type: Number,
            min: 0
        }
    },
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

// Add compound indexes for better query performance
// plantSchema.index({ garden_id: 1, end_date: 1 });
// plantSchema.index({ zone_id: 1, end_date: 1 });
module.exports = mongoose.model('Plant', plantSchema);