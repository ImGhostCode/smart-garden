const db = require('../models/database');
const { validateXid, createLink, generateXid, getMockWeatherData, getNextWaterTime, validMonthToNumber } = require('../utils/helpers');

const WaterSchedulesController = {
    getAllWaterSchedules: async (req, res) => {
        const { end_dated, exclude_weather_data } = req.query;

        const filters = {};
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        const waterSchedules = await db.waterSchedules.getAll(filters);

        res.json({
            items: waterSchedules.map(schedule => ({
                ...schedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${schedule.id}`)
                ],
                weather_data: weatherData,
                next_water: {
                    time: getNextWaterTime(),
                    duration: schedule.duration,
                    water_schedule_id: schedule.id,
                    message: 'Next scheduled watering'
                }
            }))
        });
    },

    addWaterSchedule: async (req, res) => {
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        const schedule = {
            duration,
            interval,
            start_time,
            weather_control,
            active_period,
            name,
            description
        };

        // Validate active_period months if provided
        if (active_period) {
            const { start_month, end_month } = active_period;
            const startMonth = validMonthToNumber(start_month);
            const endMonth = validMonthToNumber(end_month);
            if (startMonth === null || endMonth === null) {
                return res.status(400).json({ error: 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)' });
            }
            if (startMonth >= endMonth) {
                return res.status(400).json({ error: 'Active period start month must be before end month' });
            }
        }

        const result = await db.waterSchedules.create(schedule);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.status(201).json({
            ...result.toObject(),
            links: [
                createLink('self', `/water_schedules/${result.id}`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: result.duration,
                water_schedule_id: result.id,
                message: 'Next scheduled watering'
            }
        });
    },

    getWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;


        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...schedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${schedule.id}`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: schedule.duration,
                water_schedule_id: schedule.id,
                message: 'Next scheduled watering'
            }
        });
    },

    updateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const update = {};

        if (duration !== undefined) update.duration = duration;
        if (interval !== undefined) update.interval = interval;
        if (start_time !== undefined) update.start_time = start_time;
        if (weather_control !== undefined) update.weather_control = weather_control;
        if (name !== undefined) update.name = name;
        if (description !== undefined) update.description = description;
        // if (active_period !== undefined) update.active_period = active_period;
        // Validate active_period months if provided
        if (active_period !== undefined) {
            const { start_month, end_month } = active_period;
            const startMonth = validMonthToNumber(start_month);
            const endMonth = validMonthToNumber(end_month);
            if (startMonth === null || endMonth === null) {
                return res.status(400).json({ error: 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)' });
            }
            if (startMonth >= endMonth) {
                return res.status(400).json({ error: 'Active period start month must be before end month' });
            }

            update.active_period = active_period;
        }

        const updatedSchedule = await db.waterSchedules.updateById(waterScheduleID, update);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...updatedSchedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${schedule.id}`)
            ],
            weather_data: weatherData,
            next_water: {
                time: getNextWaterTime(),
                duration: updatedSchedule.duration,
                water_schedule_id: schedule.id,
                message: 'Next scheduled watering'
            }
        });
    },

    endDateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;

        const schedule = await db.waterSchedules.getById(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const deletedWaterSchedule = await db.waterSchedules.deleteById(waterScheduleID);

        res.json({
            ...deletedWaterSchedule.toObject(),
            links: [
                createLink('self', `/water_schedules/${waterScheduleID}`)
            ]
        });
    }
};

module.exports = WaterSchedulesController;