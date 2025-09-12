const mongoose = require('mongoose');

// XID validation pattern from OpenAPI spec
const xidPattern = /^[0-9a-v]{20}$/;


// WaterHistory Schema - following OpenAPI WaterHistory
const waterHistorySchema = new mongoose.Schema({
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
        index: true
    },
    zone_id: {
        type: String,
        required: true,
        ref: 'Zone',
        index: true
    },
    water_schedule_id: {
        type: String,
        ref: 'WaterSchedule'
    },
    duration: {
        type: String,
        required: true,
        validate: {
            validator: function (v) {
                return /^\d+(ms|s|m|h)$/.test(v);
            },
            message: 'Duration must be in valid format (e.g., "15000ms")'
        }
    },
    record_time: {
        type: Date,
        required: true,
        index: true
    },
    trigger_type: {
        type: String,
        enum: ['scheduled', 'manual', 'sensor_triggered'],
        required: true
    },
    status: {
        type: String,
        enum: ['completed', 'failed', 'interrupted', 'in_progress'],
        default: 'completed'
    },
    notes: String
}, {
    timestamps: {
        createdAt: 'created_at',
        updatedAt: 'updated_at'
    }
});
// Add compound indexes for better query performance
waterHistorySchema.index({ zone_id: 1, record_time: -1 });
waterHistorySchema.index({ garden_id: 1, record_time: -1 });
module.exports = mongoose.model('WaterHistory', waterHistorySchema);