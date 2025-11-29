const db = require('../models/database');
const cronScheduler = require('../services/cronScheduler');
const { getWeatherData } = require('../utils/weatherHelper');
const { ApiSuccess, ApiError } = require('../utils/apiResponse');
const {
    createLink,
    millisToDuration,
    durationToMillis,
    validMonthToNumber
} = require('../utils/helpers');
const {
    getNextWaterDetails,
    isActiveTime,
    calEffectiveWatering
} = require('../utils/waterScheduleHelpers');

const WaterSchedulesController = {
    getAllWaterSchedules: async (req, res, next) => {
        const { end_dated, exclude_weather_data } = req.query;

        const filters = {};
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        try {
            const waterSchedules = await db.waterSchedules.getAll(filters);

            const items = [];
            for (const schedule of waterSchedules) {
                let weatherData;
                if (schedule.hasWeatherControl() && schedule.end_date == null && exclude_weather_data !== 'true') {
                    weatherData = await getWeatherData(schedule);
                }
                const nextWaterDetails = await getNextWaterDetails(
                    schedule,
                    exclude_weather_data === 'true'
                );
                items.push({
                    ...schedule.toObject(),
                    links: [
                        createLink('self', `/water_schedules/${schedule.id}`)
                    ],
                    weather_data: weatherData,
                    next_water: nextWaterDetails
                });
            }

            return res.json(new ApiSuccess(200, 'Water schedules retrieved successfully', items));
        } catch (error) {
            next(error);
        }
    },

    addWaterSchedule: async (req, res, next) => {
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
                throw new ApiError(400, 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)');
            }
            // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
            if (startMonth === endMonth) {
                throw new ApiError(400, 'Active period start month must be different from end month');
            }
        }

        try {
            const result = await db.waterSchedules.create(schedule);

            let weatherData;
            let nextWaterDetails;
            if (result.hasWeatherControl() && result.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(result);
            }

            try {
                // Auto-schedule the new water schedule with cron
                await cronScheduler.scheduleWaterAction(result);
                nextWaterDetails = await getNextWaterDetails(
                    result,
                    exclude_weather_data === 'true'
                );
            } catch (error) {
                console.error('Error calculating next water time:', error);
            }

            return res.status(201).json(new ApiSuccess(201, 'Water schedule added successfully', {
                ...result.toObject(),
                links: [
                    createLink('self', `/water_schedules/${result.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            }));
        } catch (error) {
            next(error);
        }
    },

    getWaterSchedule: async (req, res, next) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            let weatherData;
            if (schedule.hasWeatherControl() && schedule.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(schedule);
            }
            const nextWaterDetails = await getNextWaterDetails(
                schedule,
                exclude_weather_data === 'true'
            );

            return res.json(new ApiSuccess(200, 'Water schedule retrieved successfully', {
                ...schedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${schedule.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            }));
        } catch (error) {
            next(error);
        }

    },

    updateWaterSchedule: async (req, res, next) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            const update = {};

            if (duration !== undefined) update.duration = duration;
            if (interval !== undefined) update.interval = interval;
            if (start_time !== undefined) update.start_time = start_time;
            if (weather_control !== undefined) update.weather_control = weather_control;
            if (name !== undefined) update.name = name;
            if (description !== undefined) update.description = description;
            // Validate active_period months if provided
            if (active_period !== undefined) {
                const { start_month, end_month } = active_period;
                const startMonth = validMonthToNumber(start_month);
                const endMonth = validMonthToNumber(end_month);
                if (startMonth === null || endMonth === null) {
                    throw new ApiError(400, 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)');
                }
                // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
                if (startMonth === endMonth) {
                    throw new ApiError(400, 'Active period start month must be different from end month');
                }

                update.active_period = active_period;
            }

            const updatedSchedule = await db.waterSchedules.updateById(waterScheduleID, update);
            let weatherData;
            let nextWaterDetails;

            if (updatedSchedule.hasWeatherControl() && updatedSchedule.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(updatedSchedule);
            }
            try {
                // Reschedule the updated water schedule with cron
                await cronScheduler.resetWaterSchedule(updatedSchedule);
                nextWaterDetails = await getNextWaterDetails(
                    updatedSchedule,
                    exclude_weather_data === 'true'
                );
            } catch (error) {
                console.error('Error calculating next water time:', error);
            }

            return res.json(new ApiSuccess(200, 'Water schedule updated successfully', {
                ...updatedSchedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${schedule.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            }));
        } catch (error) {
            next(error);
        }

    },

    endDateWaterSchedule: async (req, res, next) => {
        const { waterScheduleID } = req.params;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            const deletedWaterSchedule = await db.waterSchedules.deleteById(waterScheduleID);

            // Remove from cron scheduler
            const unscheduled = cronScheduler.removeJobById(waterScheduleID);

            res.json(new ApiSuccess(200, 'Water schedule end date set successfully', {
                ...deletedWaterSchedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${waterScheduleID}`)
                ],
                unscheduled: unscheduled
            }));
        } catch (error) {
            next(error);
        }
    },

    // Execute a water schedule with advanced logic
    executeWaterSchedule: async (req, res, next) => {
        const { waterScheduleID } = req.params;
        const { force_execution = false, simulate = false } = req.body;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                throw new ApiError(404, 'Water schedule not found');
            }

            let weatherData;
            const executedAt = new Date().toISOString();
            const isInActivePeriod = isActiveTime(schedule);
            if (isInActivePeriod && schedule.hasWeatherControl()) {
                weatherData = await getWeatherData(schedule);
            }
            const effectiveWatering = calEffectiveWatering(schedule, weatherData);

            // Determine execution logic
            let shouldWater = false;
            let executionReason = effectiveWatering.reason;
            let finalDuration = effectiveWatering.duration;
            let scaleFactor = effectiveWatering.scaleFactor;

            if (force_execution) {
                shouldWater = true;
                executionReason = 'forced_execution';
                if (effectiveWatering.duration === 0) {
                    finalDuration = durationToMillis(schedule.duration);
                    scaleFactor = 1.0;
                }
            } else {
                shouldWater = effectiveWatering.duration > 0;
            }

            // Prepare response
            const response = {
                schedule_info: schedule.toObject(),
                execution: {
                    will_execute: shouldWater,
                    reason: executionReason,
                    duration_ms: finalDuration,
                    duration_formatted: millisToDuration(finalDuration),
                    original_duration_ms: durationToMillis(schedule.duration),
                    original_duration_formatted: schedule.duration,
                    scale_factor: scaleFactor,
                    weather_adjustments: effectiveWatering.adjustments || [],
                    is_simulation: simulate,
                    force_execution: force_execution,
                    is_active_period: isInActivePeriod,
                    executed_at: executedAt,
                },
                weather_data: weatherData,
                links: [
                    createLink('self', `/water_schedules/${waterScheduleID}`)
                ]
            };

            // Execute or simulate
            if (simulate) {
                response.execution.note = 'Simulation completed - no actual watering performed';
            } else if (shouldWater) {
                try {
                    // Execute actual watering across all relevant zones
                    const gardens = await db.gardens.getAll({ end_date: null });
                    let zonesExecuted = 0;

                    for (const garden of gardens) {
                        const zones = await db.zones.getByGardenId(garden._id.toString());
                        for (const zone of zones) {
                            if (zone.water_schedule_ids && zone.water_schedule_ids.includes(waterScheduleID)) {
                                await cronScheduler.executeWaterAction(garden, zone, finalDuration, 'scheduled');
                                zonesExecuted++;
                            }
                        }
                    }

                    response.execution.note = `Watering executed successfully across ${zonesExecuted} zone(s)`;
                    response.execution.zones_executed = zonesExecuted;

                } catch (executionError) {
                    console.error('Error executing water action:', executionError);
                    response.execution.note = 'Watering execution failed';
                    response.execution.error = executionError.message;
                }
            } else {
                response.execution.note = `Watering skipped - ${executionReason.replace(/_/g, ' ')}`;
            }

            return res.json(new ApiSuccess(200, 'Water schedule executed successfully', response));
        } catch (error) {
            next(error);
        }
    },

    // Get execution preview for a water schedule
    previewExecution: async (req, res, next) => {
        const { waterScheduleID } = req.params;
        const { include_zones } = req.query;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                throw new ApiError(404, 'Water schedule not found');
            }


            const includeZones = include_zones === 'true';
            const currentTime = new Date();
            const isInActivePeriod = isActiveTime(schedule, currentTime);
            let weatherData;
            if (isInActivePeriod && schedule.hasWeatherControl()) {
                weatherData = await getWeatherData(schedule);
            }
            const effectiveWatering = calEffectiveWatering(schedule, weatherData);

            // Prepare preview response
            const preview = {
                will_execute: effectiveWatering.duration > 0,
                reason: effectiveWatering.reason,
                duration_ms: effectiveWatering.duration,
                duration_formatted: millisToDuration(effectiveWatering.duration),
                original_duration_ms: durationToMillis(schedule.duration),
                original_duration_formatted: schedule.duration,
                scale_factor: effectiveWatering.scaleFactor,
                weather_adjustments: effectiveWatering.adjustments || [],
                is_active_period: isInActivePeriod,
                preview_time: currentTime.toISOString(),
            };

            // Add zone information if requested
            let affectedZones = null;
            if (includeZones) {
                try {
                    const gardens = await db.gardens.getAll({ end_date: null });
                    const zones = [];

                    for (const garden of gardens) {
                        const gardenZones = await db.zones.getByGardenId(garden._id.toString());
                        for (const zone of gardenZones) {
                            if (
                                zone.skip_count === 0 &&
                                zone.water_schedule_ids && zone.water_schedule_ids.includes(waterScheduleID)) {
                                zones.push({
                                    zone_id: zone._id.toString(),
                                    zone_name: zone.name,
                                    garden_id: garden._id.toString(),
                                    garden_name: garden.name,
                                    will_execute: preview.will_execute
                                });
                            }
                        }
                    }

                    affectedZones = {
                        total_count: zones.length,
                        zones: zones
                    };
                } catch (zoneError) {
                    affectedZones = { error: 'Could not fetch zone information' };
                }
            }

            const response = {
                schedule_info: schedule.toObject(),
                preview: preview,
                weatherData: weatherData,
                links: [
                    createLink('self', `/water_schedules/${waterScheduleID}`),
                    createLink('execute', `/water_schedules/${waterScheduleID}/execute`),
                    createLink('update', `/water_schedules/${waterScheduleID}`)
                ]
            };

            if (affectedZones) {
                response.affected_zones = affectedZones;
            }

            return res.json(new ApiSuccess(200, 'Water schedule execution preview retrieved successfully', response));
        } catch (error) {
            next(error);
        }
    }
};

module.exports = WaterSchedulesController;