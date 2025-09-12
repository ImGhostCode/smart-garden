const mongoose = require('mongoose');

// XID validation pattern from OpenAPI spec
const xidPattern = /^[0-9a-v]{20}$/;

// Plant Schema - following OpenAPI Plant + PlantResponse
const plantSchema = new mongoose.Schema({
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
    zone_id: {
        type: String,
        required: true,
        ref: 'Zone',
        index: true,
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
    timestamps: {
        createdAt: 'created_at',
        updatedAt: 'updated_at'
    }
});

// Add compound indexes for better query performance
plantSchema.index({ garden_id: 1, end_date: 1 });
plantSchema.index({ zone_id: 1, end_date: 1 });
module.exports = mongoose.model('Plant', plantSchema);