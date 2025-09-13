const mongoService = require('../services/mongoService');
const Garden = require('./GardenModel');
const Plant = require('./PlantModel');
const Zone = require('./ZoneModel');
const WaterSchedule = require('./WaterScheduleModel');
const WaterHistory = require('./WaterHistoryModel');

// MongoDB database interface
const db = {
    // Connection management
    connect: async (uri) => {
        await mongoService.connect(uri);
    },

    disconnect: async () => {
        await mongoService.disconnect();
    },

    getConnectionStatus: () => {
        return mongoService.getConnectionStatus();
    },

    // Models - direct access to Mongoose models
    models: {
        Garden,
        Plant,
        Zone,
        WaterSchedule,
        WaterHistory
    },

    // Enhanced helper methods for easier controller usage
    gardens: {
        async getAll(filters = {}) {
            return await Garden.find(filters).sort({ created_at: -1 });
        },

        async getById(id) {
            return await Garden.findOne({ _id: id, end_date: null });
        },

        async create(data) {
            const garden = new Garden(
                data
            );
            return await garden.save({ timestamps: true });
        },

        async updateById(id, data) {
            return await Garden.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await Garden.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },

        // Legacy Map-style interface for backward compatibility
        async get(id) {
            return await this.getById(id);
        },

        async set(id, data) {
            const existingGarden = await Garden.findOne({ id });
            if (existingGarden) {
                return await Garden.findOneAndUpdate({ id }, data, { new: true });
            } else {
                const garden = new Garden({ ...data, id });
                return await garden.save();
            }
        },

        async values() {
            return await this.getAll();
        }
    },

    plants: {
        async getAll(filters = {}) {
            const query = { end_date: null, ...filters };
            return await Plant.find(query).sort({ created_at: -1 });
        },

        async getById(id) {
            return await Plant.findOne({ id, end_date: null });
        },

        async getByGardenId(garden_id) {
            return await Plant.find({ garden_id, end_date: null }).sort({ created_at: -1 });
        },

        async create(data) {
            const plant = new Plant(data);
            return await plant.save();
        },

        async updateById(id, data) {
            return await Plant.findOneAndUpdate(
                { id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await Plant.findOneAndUpdate(
                { id },
                { end_date: new Date() },
                { new: true }
            );
        },

        // Legacy interface
        async get(id) {
            return await this.getById(id);
        },

        async set(id, data) {
            const existingPlant = await Plant.findOne({ id });
            if (existingPlant) {
                return await Plant.findOneAndUpdate({ id }, data, { new: true });
            } else {
                const plant = new Plant({ ...data, id });
                return await plant.save();
            }
        },

        async values() {
            return await this.getAll();
        }
    },

    zones: {
        async getAll(filters = {}) {
            const query = { end_date: null, ...filters };
            return await Zone.find(query).sort({ position: 1 });
        },

        async getById(id) {
            return await Zone.findOne({ id, end_date: null });
        },

        async getByGardenId(garden_id) {
            return await Zone.find({ garden_id, end_date: null }).sort({ position: 1 });
        },

        async create(data) {
            const zone = new Zone(data);
            return await zone.save();
        },

        async updateById(id, data) {
            return await Zone.findOneAndUpdate(
                { id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await Zone.findOneAndUpdate(
                { id },
                { end_date: new Date() },
                { new: true }
            );
        },

        // // Legacy interface
        async get(id) {
            return await this.getById(id);
        },

        async set(id, data) {
            const existingZone = await Zone.findOne({ id });
            if (existingZone) {
                return await Zone.findOneAndUpdate({ id }, data, { new: true });
            } else {
                const zone = new Zone({ ...data, id });
                return await zone.save();
            }
        },

        async values() {
            return await this.getAll();
        }
    },

    waterSchedules: {
        async getAll(filters = {}) {
            const query = { end_date: null, ...filters };
            return await WaterSchedule.find(query).sort({ created_at: -1 });
        },

        async getById(id) {
            return await WaterSchedule.findOne({ id, end_date: null });
        },

        async getByGardenId(garden_id) {
            return await WaterSchedule.find({ garden_id, end_date: null }).sort({ priority: -1 });
        },

        async create(data) {
            const schedule = new WaterSchedule(data);
            return await schedule.save();
        },

        async updateById(id, data) {
            return await WaterSchedule.findOneAndUpdate(
                { id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await WaterSchedule.findOneAndUpdate(
                { id },
                { end_date: new Date() },
                { new: true }
            );
        },

        // Legacy interface
        async get(id) {
            return await this.getById(id);
        },

        async set(id, data) {
            const existingSchedule = await WaterSchedule.findOne({ id });
            if (existingSchedule) {
                return await WaterSchedule.findOneAndUpdate({ id }, data, { new: true });
            } else {
                const schedule = new WaterSchedule({ ...data, id });
                return await schedule.save();
            }
        },

        async values() {
            return await this.getAll();
        }
    },

    waterHistory: {
        async getAll(filters = {}) {
            return await WaterHistory.find(filters).sort({ start_time: -1 });
        },

        async getById(id) {
            return await WaterHistory.findOne({ id });
        },

        async getByZoneId(zone_id, limit = 50) {
            return await WaterHistory.find({ zone_id })
                .sort({ start_time: -1 })
                .limit(limit);
        },

        async create(data) {
            const history = new WaterHistory(data);
            return await history.save();
        },

        // Legacy interface
        async get(id) {
            return await this.getById(id);
        },

        async set(id, data) {
            const history = new WaterHistory({ ...data, id });
            return await history.save();
        },

        async values() {
            return await this.getAll();
        }
    }
};

module.exports = db;