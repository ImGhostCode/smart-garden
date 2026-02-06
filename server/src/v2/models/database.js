const mongoService = require('../services/mongoService');
const Garden = require('./GardenModel');
const Plant = require('./PlantModel');
const Zone = require('./ZoneModel');
const WaterSchedule = require('./WaterScheduleModel');
const WeatherClientConfig = require('./WeatherClientConfigModel.js');
const WaterRoutine = require('./WaterRoutine.js');
const NotificationClientModel = require('./NotificationClientModel.js');

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
        WeatherClientConfig,
    },

    // Enhanced helper methods for easier controller usage
    gardens: {
        async getAll({ filters = {}, notification = false }) {
            let query = Garden.find(filters).sort({ created_at: -1 });
            if (notification) {
                query = query.populate({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await query;
        },

        async getById({ id, notification = false }) {
            let query = Garden.findOne({ _id: id, end_date: null });
            if (notification) {
                query = query.populate({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await query;
        },

        async create({ data, notification = false }) {
            const populateOptions = [];
            if (notification) {
                populateOptions.push({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            const garden = new Garden(data);
            return await (await garden.save({ timestamps: true })).populate(populateOptions);
        },

        async updateById({ id, data, notification = false }) {
            let populateOptions = [];
            if (notification) {
                populateOptions.push({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await Garden.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true, populate: populateOptions }
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
        async getAll({ filters = {}, garden = false, zone = false }) {
            let query = Plant.find(filters).sort({ created_at: -1 });
            if (zone) {
                query = query.populate({
                    path: 'zone_id',
                    select: '_id name',
                });
            }
            if (garden) {
                query = query.populate({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            return await query;
        },

        async getById({ id, garden = false, zone = false }) {
            let query = Plant.findOne({ _id: id, end_date: null });
            if (zone) {
                query = query.populate({
                    path: 'zone_id',
                    select: '_id name',
                });
            }
            if (garden) {
                query = query.populate({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            return await query;
        },

        async getByGardenId(garden_id) {
            return await Plant.find({ garden_id, end_date: null }).sort({ created_at: -1 });
        },

        async create({ data, garden = false, zone = false }) {
            const populateOptions = [];
            if (zone) {
                populateOptions.push({
                    path: 'zone_id',
                    select: '_id name',
                });
            }
            if (garden) {
                populateOptions.push({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            const plant = new Plant(data);
            return await (await plant.save()).populate(populateOptions);
        },

        async updateById({ id, data, garden = false, zone = false }) {
            let populateOptions = [];
            if (zone) {
                populateOptions.push({
                    path: 'zone_id',
                    select: '_id name',
                });
            }
            if (garden) {
                populateOptions.push({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            return await Plant.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true, populate: populateOptions }
            );
        },

        async deleteById(id) {
            return await Plant.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },

        // Delete many plants by zone_id
        async deleteByZoneId(zone_id) {
            return await Plant.updateMany(
                { zone_id, end_date: null },
                { end_date: new Date() }
            );
        },

        // Delete many plants by garden_id
        async deleteByGardenId(garden_id) {
            return await Plant.updateMany(
                { garden_id, end_date: null },
                { end_date: new Date() }
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
        async getAll({ filters, garden = false, waterSchedules = false }) {
            let query = Zone.find(filters).sort({ position: 1 });
            if (garden) {
                query = query.populate({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            if (waterSchedules) {
                query = query.populate({
                    path: 'water_schedule_ids',
                    select: '_id name description duration_ms interval start_time active_period end_date',
                });
            }
            return await query;
        },

        async getById({ id, garden = false, waterSchedules = false }) {
            let query = Zone.findOne({ _id: id, end_date: null });
            if (garden) {
                query = query.populate({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            if (waterSchedules) {
                query = query.populate({
                    path: 'water_schedule_ids',
                    select: '_id name description duration_ms interval start_time active_period end_date',
                });
            }
            return await query;
        },

        async getByGardenId(garden_id) {
            return await Zone.find({ garden_id, end_date: null }).sort({ position: 1 });
        },

        async create({ data, garden = false, waterSchedules = false }) {
            const populateOptions = [];
            if (garden) {
                populateOptions.push({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            if (waterSchedules) {
                populateOptions.push({
                    path: 'water_schedule_ids',
                    select: '_id name description duration_ms interval start_time active_period end_date',
                });
            }
            const zone = new Zone(data);
            return await (await zone.save()).populate(populateOptions);
        },

        async updateById({ id, data, garden = false, waterSchedules = false }) {
            let populateOptions = [];
            if (garden) {
                populateOptions.push({
                    path: 'garden_id',
                    select: '_id name',
                });
            }
            if (waterSchedules) {
                populateOptions.push({
                    path: 'water_schedule_ids',
                    select: '_id name description duration_ms interval start_time active_period end_date',
                });
            }
            return await Zone.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true, populate: populateOptions }
            );
        },

        async deleteById(id) {
            return await Zone.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },

        // Delete many zones by garden_id
        async deleteByGardenId(garden_id) {
            return await Zone.updateMany(
                { garden_id, end_date: null },
                { end_date: new Date() }
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
        async getAll({ filters = {}, notification = false }) {
            let query = WaterSchedule.find(filters).sort({ created_at: -1 });
            if (notification) {
                query = query.populate({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await query;
        },

        async getById({ id, notification = false }) {
            let query = WaterSchedule.findOne({ _id: id, end_date: null });
            if (notification) {
                query = query.populate({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await query;
        },

        async getByGardenId({ garden_id, notification = false }) {
            let query = WaterSchedule.find({ garden_id, end_date: null }).sort({ priority: -1 });
            if (notification) {
                query = query.populate({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await query;
        },

        async create({ data, notification = false }) {
            const populateOptions = [];
            if (notification) {
                populateOptions.push({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            const schedule = new WaterSchedule(data);
            return await (await schedule.save({ timestamps: true })).populate(populateOptions);
        },

        async updateById({ id, data, notification = false }) {
            let populateOptions = [];
            if (notification) {
                populateOptions.push({
                    'path': 'notification_client_id',
                    'select': '_id name type',
                });
            }
            return await WaterSchedule.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true, populate: populateOptions }
            );
        },

        async deleteById(id) {
            return await WaterSchedule.findOneAndUpdate(
                { _id: id },
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
    weatherClientConfigs: {
        async getAll(filters = {}) {
            return await WeatherClientConfig.find(filters);
        },

        async getById(id) {
            return await WeatherClientConfig.findOne({ _id: id, end_date: null });
        },

        async getByWaterScheduleId(waterScheduleId) {
            // return await WeatherClientConfig.find({ waterScheduleId, end_date: null });
        },

        async create(data) {
            const weatherClientConfig = new WeatherClientConfig(data);
            return await weatherClientConfig.save({ timestamps: true });
        },

        async updateById(id, data) {
            return await WeatherClientConfig.findOneAndUpdate(
                { _id: id, type: data.type, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await WeatherClientConfig.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },
    },
    notificationClients: {
        async getAll(filters = {}) {
            return await NotificationClientModel.find(filters);
        },

        async getById(id) {
            return await NotificationClientModel.findOne({ _id: id, end_date: null });
        },

        async create(data) {
            const notificationClientModel = new NotificationClientModel(data);
            return await notificationClientModel.save({ timestamps: true });
        },

        async updateById(id, data) {
            return await NotificationClientModel.findOneAndUpdate(
                { _id: id, type: data.type, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true }
            );
        },

        async deleteById(id) {
            return await NotificationClientModel.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },
    },
    waterRoutines: {
        async getAll({ filters, zone = false }) {
            let query = WaterRoutine.find(filters).sort({ created_at: -1 });
            if (zone) {
                query = query.populate({
                    path: 'steps.zone_id',
                    select: '_id name end_date',
                });
            }
            return await query;
        },

        async getById({ id, zone = false }) {
            let query = WaterRoutine.findOne({ _id: id, end_date: null });
            if (zone) {
                query = query.populate({
                    path: 'steps.zone_id',
                    select: '_id name end_date',
                });
            }
            return await query;
        },

        async create({ data, zone = false }) {
            const populateOptions = [];
            if (zone) {
                populateOptions.push({
                    path: 'steps.zone_id',
                    select: '_id name end_date',
                });
            }
            const waterRoutine = new WaterRoutine(data);
            return await (await waterRoutine.save()).populate(populateOptions);
        },

        async updateById({ id, data, zone = false }) {
            let populateOptions = [];
            if (zone) {
                populateOptions.push({
                    path: 'steps.zone_id',
                    select: '_id name end_date',
                });
            }
            return await WaterRoutine.findOneAndUpdate(
                { _id: id, end_date: null },
                { ...data, updated_at: new Date() },
                { new: true, populate: populateOptions }
            );
        },

        async deleteById(id) {
            return await WaterRoutine.findOneAndUpdate(
                { _id: id, end_date: null },
                { end_date: new Date() },
                { new: true }
            );
        },
    },
};

module.exports = db;