const { Schema, model } = require('mongoose');

const weatherClientConfigSchema = new Schema({
    type: {
        type: String,
        required: true,
    },
    // Map of configuration options specific to the weather client type
    options: {
        type: Object,
        required: true
    },
    end_date: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

module.exports = model('WeatherClientConfig', weatherClientConfigSchema);