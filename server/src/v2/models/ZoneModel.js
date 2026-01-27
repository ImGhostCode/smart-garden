const { Schema, model } = require('mongoose');
const { xidPattern } = require('../utils/validation');
const PlantModel = require('./PlantModel');

// Zone Schema
const zoneSchema = new Schema({
    garden_id: {
        type: Schema.Types.ObjectId,
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
        type: Schema.Types.ObjectId,
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

zoneSchema.pre('findOneAndUpdate', async function (next) {
    const update = this.getUpdate();
    if (update.end_date) {
        await PlantModel.updateMany(
            {
                zone_id: this.getQuery()._id,
                end_date: null
            },
            { end_date: new Date() }
        );
    }
    next();
});

// Add compound indexes for better query performance
// zoneSchema.index({ garden_id: 1, position: 1, end_date: 1 });
// zoneSchema.index({ garden_id: 1, end_date: 1 });
module.exports = model('Zone', zoneSchema);