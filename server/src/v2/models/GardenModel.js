const mongoose = require('mongoose');

// XID validation pattern from OpenAPI spec
const xidPattern = /^[0-9a-v]{20}$/;

// Garden Schema - following OpenAPI Garden + GardenResponse
const gardenSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true,
        index: true,
        validate: {
            validator: function (v) {
                return xidPattern.test(v);
            },
            message: 'ID must be a valid XID format (20 character string)'
        }
    },
    name: {
        type: String,
        required: true,
        trim: true
    },
    topic_prefix: {
        type: String,
        required: true,
        trim: true,
        index: true,
        validate: {
            validator: function (v) {
                // Avoid spaces and characters: [$#*>+/]
                return !/[\s$#*>+/]/.test(v);
            },
            message: 'Topic prefix cannot contain spaces or characters: [$#*>+/]'
        }
    },
    max_zones: {
        type: Number,
        required: true,
        min: 0,
        default: 0
    },
    light_schedule: {
        duration: {
            type: String,
            validate: {
                validator: function (v) {
                    // Validate duration format (e.g., "14h", "30m", "1h30m")
                    return !v || /^\d+[hms](\d+[ms])?$/.test(v);
                },
                message: 'Duration must be in valid format (e.g., "14h", "30m")'
            }
        },
        start_time: {
            type: String,
            validate: {
                validator: function (v) {
                    // Validate time format (e.g., "23:00:00-07:00")
                    return !v || /^\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/.test(v);
                },
                message: 'Start time must be in format "HH:MM:SS±HH:MM"'
            }
        },
        adhoc_on_time: Date,
        temperature_humidity_sensor: {
            type: Boolean,
            default: false
        }
    },
    // Response-only fields for GardenResponse
    health: {
        status: {
            type: String,
            enum: ['UP', 'DOWN', 'N/A'],
            default: 'N/A'
        },
        details: {
            type: String,
            default: 'No recent health data from garden controller'
        },
        last_contact: Date
    },
    temperature_humidity_data: {
        temperature_celsius: Number,
        humidity_percentage: Number,
        timestamp: Date
    },
    next_light_action: {
        time: Date,
        state: {
            type: String,
            enum: ['ON', 'OFF', '']
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
gardenSchema.index({ topic_prefix: 1, end_date: 1 });
module.exports = mongoose.model('Garden', gardenSchema);