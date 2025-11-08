const db = require('../models/database');
const cronScheduler = require('../services/cronScheduler');
const { getWeatherData } = require('../utils/weatherHelper');

const {
    createLink,
    millisToDuration,
    durationToMillis,
    validMonthToNumber
} = require('../utils/helpers');
const {
    getNextWaterDetails,
    isActiveTime,
    calculateEffectiveWateringDuration
} = require('../utils/waterScheduleHelpers');

const WaterSchedulesController = {
    getAllWaterSchedules: async (req, res) => {
        const { end_dated, exclude_weather_data } = req.query;

        const filters = {};
        if (!end_dated || end_dated === 'false') {
            filters.end_date = null;
        }

        try {
            const waterSchedules = await db.waterSchedules.getAll(filters);

            const items = await Promise.all(waterSchedules.map(async (schedule) => {

                let weatherData;
                if (schedule.hasWeatherControl() && schedule.end_date == null && exclude_weather_data !== 'true') {
                    weatherData = await getWeatherData(schedule);
                }
                const nextWaterDetails = await getNextWaterDetails(
                    schedule,
                    exclude_weather_data === 'true'
                );

                return {
                    ...schedule.toObject(),
                    links: [
                        createLink('self', `/water_schedules/${schedule.id}`)
                    ],
                    weather_data: weatherData,
                    next_water: nextWaterDetails
                };
            }));

            res.json({
                items
            });
        } catch (error) {
            console.error('Error fetching water schedules:', error);
            res.status(500).json({ error: 'Failed to fetch water schedules' });
        }

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
            // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
            if (startMonth === endMonth) {
                return res.status(400).json({ error: 'Active period start month must be different from end month' });
            }
        }

        try {
            const result = await db.waterSchedules.create(schedule);

            let weatherData;
            if (result.hasWeatherControl() && result.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(result);
            }
            let nextWaterDetails;

            try {
                // Auto-schedule the new water schedule with cron
                const cronScheduler = require('../services/cronScheduler');
                await cronScheduler.scheduleWaterAction(result);
                nextWaterDetails = await getNextWaterDetails(
                    result,
                    exclude_weather_data === 'true'
                );
            } catch (error) {
                console.error('Error calculating next water time:', error);
            }

            res.status(201).json({
                ...result.toObject(),
                links: [
                    createLink('self', `/water_schedules/${result.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            });
        } catch (error) {
            console.error('Error creating water schedule:', error);
            res.status(500).json({ error: 'Failed to create water schedule' });
        }

    },

    getWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            let weatherData;
            if (schedule.hasWeatherControl() && schedule.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(schedule);
            }
            const nextWaterDetails = await getNextWaterDetails(
                schedule,
                exclude_weather_data === 'true'
            );

            const response = {
                ...schedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${schedule.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            };

            res.json(response);

        } catch (error) {
            console.error('Error fetching water schedule:', error);
            res.status(500).json({ error: 'Failed to fetch water schedule' });
        }

    }, updateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { exclude_weather_data } = req.query;
        const { duration, interval, start_time, weather_control, active_period, name, description } = req.body;

        try {
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
            // Validate active_period months if provided
            if (active_period !== undefined) {
                const { start_month, end_month } = active_period;
                const startMonth = validMonthToNumber(start_month);
                const endMonth = validMonthToNumber(end_month);
                if (startMonth === null || endMonth === null) {
                    return res.status(400).json({ error: 'Active period months must be valid three-letter abbreviations (e.g., Jan, Feb)' });
                }
                // Example: start=Nov(11), end=Mar(3) is valid (spans year end)
                if (startMonth === endMonth) {
                    return res.status(400).json({ error: 'Active period start month must be different from end month' });
                }

                update.active_period = active_period;
            }

            const updatedSchedule = await db.waterSchedules.updateById(waterScheduleID, update);
            let weatherData;
            if (updatedSchedule.hasWeatherControl() && updatedSchedule.end_date == null && exclude_weather_data !== 'true') {
                weatherData = await getWeatherData(updatedSchedule);
            }
            let nextWaterDetails;

            try {
                // Reschedule the updated water schedule with cron
                const cronScheduler = require('../services/cronScheduler');
                await cronScheduler.resetWaterSchedule(updatedSchedule);
                nextWaterDetails = await getNextWaterDetails(
                    updatedSchedule,
                    exclude_weather_data === 'true'
                );
            } catch (error) {
                console.error('Error calculating next water time:', error);
            }

            res.json({
                ...updatedSchedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${schedule.id}`)
                ],
                weather_data: weatherData,
                next_water: nextWaterDetails
            });
        } catch (error) {
            console.error('Error updating water schedule:', error);
            res.status(500).json({ error: 'Failed to update water schedule' });
        }

    },

    endDateWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            const deletedWaterSchedule = await db.waterSchedules.deleteById(waterScheduleID);

            // Remove from cron scheduler
            const cronScheduler = require('../services/cronScheduler');
            const unscheduled = cronScheduler.removeJobById(waterScheduleID);

            res.json({
                ...deletedWaterSchedule.toObject(),
                links: [
                    createLink('self', `/water_schedules/${waterScheduleID}`)
                ],
                unscheduled: unscheduled
            });
        } catch (error) {
            console.error('Error updating water schedule:', error);
            res.status(500).json({ error: 'Failed to update water schedule' });
        }
    },

    // Execute a water schedule with advanced logic
    executeWaterSchedule: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { skip_count = 0, force_execution = false, simulate = false } = req.body;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            let weatherData;
            if (schedule.hasWeatherControl()) {
                weatherData = await getWeatherData(schedule);
            }
            const executedAt = new Date().toISOString();

            // Calculate effective watering parameters
            const effectiveWatering = calculateEffectiveWateringDuration(
                schedule, weatherData, skip_count
            );

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

            // Handle skip count logic
            let updatedSkipCount = skip_count;
            if (shouldWater && skip_count > 0 && !force_execution) {
                updatedSkipCount = Math.max(0, skip_count - 1);
            }

            // Prepare response
            const response = {
                ...schedule.toObject(),
                execution: {
                    will_execute: shouldWater,
                    reason: executionReason,
                    duration_ms: finalDuration,
                    duration_formatted: millisToDuration(finalDuration),
                    original_duration_ms: durationToMillis(schedule.duration),
                    scale_factor: scaleFactor,
                    weather_adjustments: effectiveWatering.adjustments || [],
                    skip_count: updatedSkipCount,
                    is_simulation: simulate,
                    force_execution: force_execution,
                    executed_at: executedAt,
                    is_active_period: isActiveTime(schedule)
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
                                await cronScheduler.executeWaterAction(garden, zone, schedule, {
                                    duration: finalDuration,
                                    scaleFactor: scaleFactor,
                                    reason: executionReason,
                                    weather_data: weatherData
                                });
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

            res.json(response);

        } catch (error) {
            console.error('Error executing water schedule:', error);
            res.status(500).json({
                error: 'Failed to execute water schedule',
                details: error.message
            });
        }
    },

    // Get execution preview for a water schedule
    previewExecution: async (req, res) => {
        const { waterScheduleID } = req.params;
        const { skip_count, include_zones } = req.query;

        try {
            const schedule = await db.waterSchedules.getById(waterScheduleID);
            if (!schedule) {
                return res.status(404).json({ error: 'Water schedule not found' });
            }

            let weatherData;
            if (schedule.hasWeatherControl()) {
                weatherData = await getWeatherData(schedule);
            }
            const skipCount = skip_count ? parseInt(skip_count, 10) : 0;
            const includeZones = include_zones === 'true';

            // Calculate what would happen if executed now
            const effectiveWatering = calculateEffectiveWateringDuration(
                schedule, weatherData, skipCount
            );

            const currentTime = new Date();
            const isInActivePeriod = isActiveTime(schedule, currentTime);

            // Prepare preview response
            const preview = {
                will_execute: effectiveWatering.duration > 0,
                reason: effectiveWatering.reason,
                duration_ms: effectiveWatering.duration,
                duration_formatted: millisToDuration(effectiveWatering.duration),
                original_duration_ms: durationToMillis(schedule.duration),
                original_duration_formatted: millisToDuration(durationToMillis(schedule.duration)),
                scale_factor: effectiveWatering.scaleFactor,
                weather_adjustments: effectiveWatering.adjustments || [],
                skip_count: skipCount,
                is_active_period: isInActivePeriod,
                preview_time: currentTime.toISOString(),
                force_execution_duration: millisToDuration(durationToMillis(schedule.duration))
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
                            if (zone.water_schedule_ids && zone.water_schedule_ids.includes(waterScheduleID)) {
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
                    console.error('Error fetching zone information:', zoneError);
                    affectedZones = { error: 'Could not fetch zone information' };
                }
            }

            // Enhanced schedule information
            const scheduleInfo = {
                id: schedule._id.toString(),
                name: schedule.name,
                description: schedule.description,
                interval: schedule.interval,
                start_time: schedule.start_time,
                duration: schedule.duration,
                weather_control: schedule.weather_control || null,
                active_period: schedule.active_period || null,
            };

            const response = {
                water_schedule_id: waterScheduleID,
                preview: preview,
                current_weather: weatherData,
                schedule_info: scheduleInfo,
                links: [
                    createLink('self', `/water_schedules/${waterScheduleID}`),
                    createLink('execute', `/water_schedules/${waterScheduleID}/execute`),
                    createLink('update', `/water_schedules/${waterScheduleID}`)
                ]
            };

            if (affectedZones) {
                response.affected_zones = affectedZones;
            }

            res.json(response);

        } catch (error) {
            console.error('Error generating execution preview:', error);
            res.status(500).json({
                error: 'Failed to generate execution preview',
                details: error.message
            });
        }
    }
};

module.exports = WaterSchedulesController;