const db = require('../models/database');
const { validateXid, createLink, generateXid, getMockWeatherData, getNextWaterTime } = require('../utils/helpers');

const WaterSchedulesController = {
    getAllWaterSchedules: (req, res) => {
        const { end_dated, exclude_weather_data } = req.query;

        const schedules = Array.from(db.waterSchedules.values());

        let filteredSchedules = schedules;
        if (!end_dated || end_dated === 'false') {
            filteredSchedules = schedules.filter(schedule => !schedule.end_date);
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            items: filteredSchedules.map(schedule => ({
                ...schedule,
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

    addWaterSchedule: (req, res) => {
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, name, description } = req.body;

        if (!duration || !interval || !start_time) {
            return res.status(400).json({ error: 'Duration, interval, and start_time are required' });
        }

        const schedule = {
            id: generateXid(),
            duration,
            interval,
            start_time,
            weather_control,
            name,
            description
        };

        db.waterSchedules.set(schedule.id, schedule);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.status(201).json({
            ...schedule,
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

    getWaterSchedule: (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;

        if (!validateXid(waterScheduleID)) {
            return res.status(400).json({ error: 'Invalid water schedule ID format' });
        }

        const schedule = db.waterSchedules.get(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...schedule,
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

    updateWaterSchedule: (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;

        if (!validateXid(waterScheduleID)) {
            return res.status(400).json({ error: 'Invalid water schedule ID format' });
        }

        const schedule = db.waterSchedules.get(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        const updatedSchedule = {
            ...schedule,
            ...req.body,
            id: waterScheduleID
        };

        db.waterSchedules.set(waterScheduleID, updatedSchedule);

        const weatherData = exclude_weather_data !== 'true' ? getMockWeatherData() : undefined;

        res.json({
            ...updatedSchedule,
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

    endDateWaterSchedule: (req, res) => {
        const { waterScheduleID } = req.params;

        if (!validateXid(waterScheduleID)) {
            return res.status(400).json({ error: 'Invalid water schedule ID format' });
        }

        const schedule = db.waterSchedules.get(waterScheduleID);
        if (!schedule) {
            return res.status(404).json({ error: 'Water schedule not found' });
        }

        schedule.end_date = new Date().toISOString();
        db.waterSchedules.set(waterScheduleID, schedule);

        res.json({
            ...schedule,
            links: [
                createLink('self', `/water_schedules/${schedule.id}`)
            ]
        });
    }
};

module.exports = WaterSchedulesController;