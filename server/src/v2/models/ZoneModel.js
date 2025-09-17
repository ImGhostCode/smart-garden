const mongoose = require('mongoose');
// const { xidPattern } = require('../utils/validation');

// Zone Schema
const zoneSchema = new mongoose.Schema({
    garden_id: {
        type: String,
        required: true,
        ref: 'Garden',
        index: true,
        // validate: {
        //     validator: function (v) {
        //         return xidPattern.test(v);
        //     },
        //     message: 'Garden ID must be a valid XID format'
        // }
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
    // Additional fields for sensor data and status (not in OpenAPI but useful)
    // sensor_data: {
    //     soil_moisture: {
    //         value: Number,
    //         timestamp: Date,
    //         status: {
    //             type: String,
    //             enum: ['dry', 'moist', 'wet', 'unknown'],
    //             default: 'unknown'
    //         }
    //     },
    //     temperature: {
    //         celsius: Number,
    //         timestamp: Date
    //     },
    //     light_level: {
    //         lux: Number,
    //         timestamp: Date
    //     }
    // },
    // pump_status: {
    //     is_active: {
    //         type: Boolean,
    //         default: false
    //     },
    //     last_watered: Date,
    //     duration_seconds: Number
    // },
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
module.exports = mongoose.model('Zone', zoneSchema);