const mongoose = require('mongoose');

const gardenSchema = new mongoose.Schema({
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
        unique: true,
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
        min: 1,
        default: 1
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
        // adhoc_on_time: Date,
        // temperature_humidity_sensor: {
        //     type: Boolean,
        //     default: false
        // }
    },
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
    // temperature_humidity_data: {
    //     temperature_celsius: Number,
    //     humidity_percentage: Number,
    //     timestamp: Date
    // },
    // next_light_action: {
    //     time: Date,
    //     state: {
    //         type: String,
    //         enum: ['ON', 'OFF', '']
    //     }
    // },
    end_date: {
        type: Date,
        default: null
    },
    controller_config: {
        valvePins: { type: [Number], default: [] },
        pumpPins: { type: [Number], default: [] },
        lightPin: { type: Number, default: null },
        tempHumidityPin: { type: Number, default: null },
        tempHumidityInterval: { type: Number, default: 5000 }, // in minutes
    }
}, {
    timestamps: true
});
// Add compound indexes for better query performance
// gardenSchema.index({ _id: 1, topic_prefix: 1, end_date: 1 });
module.exports = mongoose.model('Garden', gardenSchema);