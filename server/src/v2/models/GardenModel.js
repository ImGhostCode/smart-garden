const { Schema, model } = require('mongoose');

const gardenSchema = new Schema({
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
                    return !v || /^(\d+h)?(\d+m)?(\d+s)?$/.test(v);
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
            },
            default: null
        },
        adhoc_on_time: {
            type: String,
            validate: {
                validator: function (v) {
                    // Validate time format (e.g., "23:00:00-07:00")
                    return !v || /^\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/.test(v);
                },
                message: 'Adhoc on time must be in format "HH:MM:SS±HH:MM"'
            }
        }
    },
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
module.exports = model('Garden', gardenSchema);